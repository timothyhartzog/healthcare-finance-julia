module SimulationEngine

using Random
using Statistics

export
    # Core sampling
    monte_carlo_mean, monte_carlo_percentile,
    # Growth / time series
    simulate_growth, simulate_stochastic_growth,
    # Sensitivity analysis
    one_way_sensitivity, tornado_values,
    # Scenario analysis
    scenario_npv,
    # Bootstrap
    bootstrap_mean, bootstrap_ci

# ---------------------------------------------------------------------------
# Core Monte Carlo
# ---------------------------------------------------------------------------

"""
Monte Carlo simulation returning mean of sampled values.
dist_sampler: zero-argument function returning a sample.
n: number of iterations.
"""
function monte_carlo_mean(dist_sampler::Function, n::Int)
    n > 0 || throw(ArgumentError("n must be positive"))
    samples = [dist_sampler() for _ in 1:n]
    return mean(samples)
end

"""
Monte Carlo simulation returning a specified percentile.
dist_sampler: zero-argument function returning a sample.
n: number of iterations.
p: percentile in [0, 100].
"""
function monte_carlo_percentile(dist_sampler::Function, n::Int, p::Real)
    n > 0 || throw(ArgumentError("n must be positive"))
    0 <= p <= 100 || throw(ArgumentError("p must be in [0, 100]"))
    samples = sort([dist_sampler() for _ in 1:n])
    idx = clamp(round(Int, p / 100 * n), 1, n)
    return samples[idx]
end

# ---------------------------------------------------------------------------
# Growth simulation
# ---------------------------------------------------------------------------

"""
Simulate deterministic compounded growth over periods.
Returns a vector of values at each period end.
"""
function simulate_growth(initial::Real, rate::Real, periods::Int)
    periods > 0 || throw(ArgumentError("periods must be positive"))
    values = Float64[]
    current = initial
    for _ in 1:periods
        current *= (1 + rate)
        push!(values, current)
    end
    return values
end

"""
Simulate stochastic compounded growth where the growth rate is drawn each period.
rate_sampler: zero-argument function returning a rate sample.
n_paths: number of simulation paths.
Returns a matrix (periods × n_paths) of simulated values.
"""
function simulate_stochastic_growth(
    initial::Real,
    rate_sampler::Function,
    periods::Int,
    n_paths::Int,
)
    periods > 0 || throw(ArgumentError("periods must be positive"))
    n_paths > 0 || throw(ArgumentError("n_paths must be positive"))

    result = Matrix{Float64}(undef, periods, n_paths)
    for path in 1:n_paths
        current = Float64(initial)
        for t in 1:periods
            current *= (1 + rate_sampler())
            result[t, path] = current
        end
    end
    return result
end

# ---------------------------------------------------------------------------
# Sensitivity analysis
# ---------------------------------------------------------------------------

"""
One-way sensitivity analysis.
base_fn: function(param_value) → scalar output metric.
base_value: central parameter value.
low_value: lower bound for the parameter.
high_value: upper bound for the parameter.
Returns a named tuple with (low_output, base_output, high_output).
"""
function one_way_sensitivity(
    base_fn::Function,
    base_value::Real,
    low_value::Real,
    high_value::Real,
)
    return (
        low_output  = base_fn(low_value),
        base_output = base_fn(base_value),
        high_output = base_fn(high_value),
    )
end

"""
Compute swing values for a tornado chart.
params: vector of named tuples (name, low, base, high).
base_fn: function(param_value) → scalar output.
Returns a vector of (name, swing) sorted descending by absolute swing.
"""
function tornado_values(
    params::AbstractVector,
    base_fn::Function,
)
    results = map(params) do p
        low_out  = base_fn(p.low)
        high_out = base_fn(p.high)
        swing = abs(high_out - low_out)
        (name = p.name, low_output = low_out, high_output = high_out, swing = swing)
    end
    return sort(results; by = r -> r.swing, rev = true)
end

# ---------------------------------------------------------------------------
# Scenario analysis
# ---------------------------------------------------------------------------

"""
Scenario NPV analysis.
rate: discount rate.
scenarios: vector of named tuples (name, cashflows, probability).
Returns a vector of (name, npv, probability) and the probability-weighted expected NPV.
"""
function scenario_npv(rate::Real, scenarios::AbstractVector)
    isempty(scenarios) && throw(ArgumentError("scenarios must not be empty"))
    results = map(scenarios) do s
        pv = sum(cf / (1 + rate)^t for (t, cf) in enumerate(s.cashflows))
        (name = s.name, npv = pv, probability = s.probability)
    end
    expected_npv = sum(r.npv * r.probability for r in results)
    return (scenarios = results, expected_npv = expected_npv)
end

# ---------------------------------------------------------------------------
# Bootstrap
# ---------------------------------------------------------------------------

"""
Bootstrap mean estimate.
data: observed data vector.
n_bootstrap: number of bootstrap resamples.
Returns the vector of bootstrap sample means.
"""
function bootstrap_mean(data::AbstractVector{<:Real}, n_bootstrap::Int; rng::AbstractRNG = Random.GLOBAL_RNG)
    isempty(data) && throw(ArgumentError("data must not be empty"))
    n_bootstrap > 0 || throw(ArgumentError("n_bootstrap must be positive"))
    n = length(data)
    return [mean(data[rand(rng, 1:n, n)]) for _ in 1:n_bootstrap]
end

"""
Bootstrap confidence interval for the mean.
Returns (lower, upper) bounds at the specified confidence level (default 0.95).
"""
function bootstrap_ci(
    data::AbstractVector{<:Real},
    n_bootstrap::Int;
    confidence::Real = 0.95,
    rng::AbstractRNG = Random.GLOBAL_RNG,
)
    0 < confidence < 1 || throw(ArgumentError("confidence must be in (0, 1)"))
    bm = bootstrap_mean(data, n_bootstrap; rng = rng)
    sorted_bm = sort(bm)
    α = 1 - confidence
    lo_idx = max(1, round(Int, (α / 2) * n_bootstrap))
    hi_idx = min(n_bootstrap, round(Int, (1 - α / 2) * n_bootstrap))
    return (lower = sorted_bm[lo_idx], upper = sorted_bm[hi_idx])
end

end # module SimulationEngine
