module SimulationEngine

using Random
using Statistics

export monte_carlo_mean, simulate_growth,
       bootstrap_ci, probabilistic_sensitivity,
       tornado_sensitivity, scenario_analysis,
       simulate_claims, discrete_event_patient_flow

"""
Monte Carlo simulation returning mean of sampled values.
"""
function monte_carlo_mean(dist_sampler::Function, n::Int)
    n > 0 || throw(ArgumentError("n must be positive"))
    samples = [dist_sampler() for _ in 1:n]
    return mean(samples)
end

"""
Simulate compounded growth over time.
"""
function simulate_growth(initial::Real, rate::Real, periods::Int)
    values = Float64[]
    current = initial
    for _ in 1:periods
        current *= (1 + rate)
        push!(values, current)
    end
    return values
end

"""
    bootstrap_ci(data, statistic=mean; n_boot=1000, ci_level=0.95, rng=nothing)

Bootstrap confidence interval for any scalar statistic.

- `statistic`: function applied to a bootstrap resample (default: mean)
- `ci_level`: confidence level (default 0.95)

Returns `(lower, upper, bootstrap_distribution)`.

Useful for constructing CIs around cost, PMPM, or financial ratios without
distributional assumptions.
"""
function bootstrap_ci(data::AbstractVector{<:Real}, statistic::Function=mean;
                       n_boot::Int=1000, ci_level::Real=0.95,
                       rng::Union{AbstractRNG,Nothing}=nothing)
    n_boot > 0 || throw(ArgumentError("n_boot must be positive"))
    0 < ci_level < 1 || throw(ArgumentError("ci_level must be in (0,1)"))
    rng = isnothing(rng) ? MersenneTwister() : rng
    n = length(data)
    boot_stats = [statistic(data[rand(rng, 1:n, n)]) for _ in 1:n_boot]
    alpha = (1 - ci_level) / 2
    lower = quantile(boot_stats, alpha)
    upper = quantile(boot_stats, 1 - alpha)
    return (lower=lower, upper=upper, distribution=boot_stats)
end

"""
    probabilistic_sensitivity(base_value, param_samplers, value_function;
                               n_simulations=1000)

Generic probabilistic sensitivity analysis (PSA).

- `param_samplers`: Dict of parameter_name => sampler_function()
- `value_function(params::Dict)`: returns scalar outcome (e.g., NPV or ICER)

Returns `(mean_outcome, std_outcome, outcomes_vector)`.
"""
function probabilistic_sensitivity(base_value::Real,
                                    param_samplers::Dict{String, <:Function},
                                    value_function::Function;
                                    n_simulations::Int=1000)
    n_simulations > 0 || throw(ArgumentError("n_simulations must be positive"))
    outcomes = Float64[]
    for _ in 1:n_simulations
        sampled_params = Dict(k => f() for (k, f) in param_samplers)
        push!(outcomes, value_function(sampled_params))
    end
    return (mean_outcome=mean(outcomes), std_outcome=std(outcomes), outcomes=outcomes)
end

"""
    tornado_sensitivity(base_outcome, parameter_ranges, outcome_function)

One-way sensitivity analysis (tornado chart inputs).

- `parameter_ranges`: Dict of name => (low_value, high_value)
- `outcome_function(name, value)`: scalar outcome at the given parameter value

Returns results sorted by descending swing (widest bar at top).
"""
function tornado_sensitivity(base_outcome::Real,
                              parameter_ranges::Dict{String, Tuple{Float64, Float64}},
                              outcome_function::Function)
    results = NamedTuple[]
    for (name, (low, high)) in parameter_ranges
        low_out  = outcome_function(name, low)
        high_out = outcome_function(name, high)
        push!(results, (parameter=name, low_outcome=low_out, high_outcome=high_out,
                        swing=abs(high_out - low_out)))
    end
    sort!(results, by=r -> r.swing, rev=true)
    return results
end

"""
    scenario_analysis(base_params, scenarios, outcome_function)

Multi-scenario financial analysis.

- `base_params`: Dict of base-case parameter values
- `scenarios`: Dict of scenario_name => Dict of param overrides
- `outcome_function(params::Dict)`: scalar outcome

Returns a Dict mapping scenario names to outcomes.
"""
function scenario_analysis(base_params::Dict{String, <:Real},
                            scenarios::Dict{String, Dict{String, Float64}},
                            outcome_function::Function)
    results = Dict{String, Float64}()
    results["base"] = outcome_function(base_params)
    for (name, overrides) in scenarios
        params = merge(base_params, overrides)
        results[name] = outcome_function(params)
    end
    return results
end

"""
    simulate_claims(n_members, freq_dist_sampler, sev_dist_sampler; seed=nothing)

Simulate aggregate claims for a health plan population.

- `n_members`: number of covered lives
- `freq_dist_sampler()`: returns integer claim count per member
- `sev_dist_sampler()`: returns claim amount for a single claim

Returns `(total_claims, claim_counts, total_paid)`.
"""
function simulate_claims(n_members::Integer,
                          freq_dist_sampler::Function,
                          sev_dist_sampler::Function;
                          seed::Union{Int, Nothing}=nothing)
    n_members > 0 || throw(ArgumentError("n_members must be positive"))
    !isnothing(seed) && Random.seed!(seed)
    claim_counts = [freq_dist_sampler() for _ in 1:n_members]
    total_claims = sum(claim_counts)
    total_paid = sum(sev_dist_sampler() for _ in 1:total_claims; init=0.0)
    return (total_claims=total_claims, claim_counts=claim_counts, total_paid=total_paid)
end

"""
    discrete_event_patient_flow(n_patients, arrival_rate, service_rate, n_servers;
                                 sim_duration=100.0, seed=nothing)

Simple M/M/c queue simulation for patient throughput (e.g., ED, OR scheduling).

- `arrival_rate`: patients per time unit (λ)
- `service_rate`: patients served per time unit per server (μ)
- `n_servers`: number of parallel servers (c)
- `sim_duration`: total simulation time units

Returns `(mean_wait, mean_queue_length, server_utilization, patients_served)`.
"""
function discrete_event_patient_flow(n_patients::Integer,
                                      arrival_rate::Real,
                                      service_rate::Real,
                                      n_servers::Integer;
                                      sim_duration::Real=100.0,
                                      seed::Union{Int, Nothing}=nothing)
    n_patients > 0 || throw(ArgumentError("n_patients must be positive"))
    arrival_rate > 0 || throw(ArgumentError("arrival_rate must be positive"))
    service_rate > 0 || throw(ArgumentError("service_rate must be positive"))
    n_servers > 0 || throw(ArgumentError("n_servers must be positive"))
    !isnothing(seed) && Random.seed!(seed)

    # Generate arrival times
    inter_arrivals = [-log(rand()) / arrival_rate for _ in 1:n_patients]
    arrival_times = cumsum(inter_arrivals)
    arrival_times = filter(t -> t <= sim_duration, arrival_times)
    n_actual = length(arrival_times)

    service_times = [-log(rand()) / service_rate for _ in 1:n_actual]

    # Simple server assignment: next available server
    server_free_at = zeros(Float64, n_servers)
    wait_times = Float64[]
    for i in 1:n_actual
        t_arrive = arrival_times[i]
        earliest_server = argmin(server_free_at)
        t_start  = max(t_arrive, server_free_at[earliest_server])
        wait     = t_start - t_arrive
        push!(wait_times, wait)
        server_free_at[earliest_server] = t_start + service_times[i]
    end

    total_busy = sum(service_times)
    utilization = total_busy / (n_servers * sim_duration)
    mean_wait   = isempty(wait_times) ? 0.0 : mean(wait_times)
    # Little's law: L = λ × W
    mean_queue  = arrival_rate * mean_wait

    return (mean_wait=mean_wait, mean_queue_length=mean_queue,
            server_utilization=min(1.0, utilization),
            patients_served=n_actual)
end

end
