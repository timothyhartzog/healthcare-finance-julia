module CostEffectivenessEngine

using Statistics
using LinearAlgebra

export markov_cohort, markov_cycle_traces, icer,
       cea_dominant, budget_impact_analysis,
       net_monetary_benefit, willingness_to_pay_threshold,
       daly, life_years_gained, qaly_adjusted_life_years,
       decision_tree_ev, probabilistic_sensitivity_analysis,
       tornado_diagram_inputs

# ─── Markov Cohort Model ──────────────────────────────────────────────────────

"""
    markov_cohort(transition_matrix, initial_cohort, n_cycles; discount_rate=0.03)

Run a Markov cohort state-transition model.

- `transition_matrix`: n_states × n_states row-stochastic matrix
- `initial_cohort`: vector of length n_states (fractions or counts)
- `n_cycles`: number of model cycles (e.g., years)
- `discount_rate`: annual discount rate for outcomes

Returns a matrix of size (n_cycles+1) × n_states with cohort in each state per cycle.
"""
function markov_cohort(transition_matrix::Matrix{<:Real},
                       initial_cohort::AbstractVector{<:Real},
                       n_cycles::Integer;
                       discount_rate::Real=0.03)
    n_states = length(initial_cohort)
    size(transition_matrix) == (n_states, n_states) ||
        throw(ArgumentError("transition_matrix dimensions must match initial_cohort length"))
    n_cycles > 0 || throw(ArgumentError("n_cycles must be positive"))
    # Validate row-stochastic (each row sums to ~1)
    for i in 1:n_states
        abs(sum(transition_matrix[i, :]) - 1.0) > 1e-6 &&
            throw(ArgumentError("row $i of transition_matrix does not sum to 1"))
    end
    traces = zeros(Float64, n_cycles + 1, n_states)
    traces[1, :] = initial_cohort
    for t in 2:(n_cycles+1)
        traces[t, :] = traces[t-1, :] * transition_matrix
    end
    return traces
end

"""
    markov_cycle_traces(traces, utility_weights; discount_rate=0.03)

Convert Markov cohort traces to discounted QALYs per cycle.

- `utility_weights`: vector of utility values per health state
- Returns vector of discounted QALYs per cycle (length n_cycles).
"""
function markov_cycle_traces(traces::Matrix{Float64},
                              utility_weights::AbstractVector{<:Real};
                              discount_rate::Real=0.03)
    n_cycles, n_states = size(traces)
    n_cycles -= 1   # first row is cycle 0
    length(utility_weights) == n_states ||
        throw(ArgumentError("utility_weights length must match number of states"))
    qaly_per_cycle = Float64[]
    for t in 1:n_cycles
        cohort_in_cycle = (traces[t, :] + traces[t+1, :]) / 2   # half-cycle correction
        raw_qaly = dot(cohort_in_cycle, utility_weights)
        discounted = raw_qaly / (1 + discount_rate)^(t - 1)
        push!(qaly_per_cycle, discounted)
    end
    return qaly_per_cycle
end

# ─── ICER / Dominance ─────────────────────────────────────────────────────────

"""
    icer(delta_cost, delta_effectiveness)

Incremental cost-effectiveness ratio.

`ICER = ΔCost / ΔEffectiveness`

Throws if delta_effectiveness is zero (equal effectiveness).
"""
function icer(delta_cost::Real, delta_effectiveness::Real)
    delta_effectiveness == 0 &&
        throw(ArgumentError("delta_effectiveness is zero — strategies are equally effective"))
    return delta_cost / delta_effectiveness
end

"""
    cea_dominant(cost_a, effect_a, cost_b, effect_b)

Return a symbol indicating dominance relationship.

- `:a_dominates`: strategy A costs less AND is more effective
- `:b_dominates`: strategy B costs less AND is more effective
- `:a_extended_dominant`: A has higher ICER than acceptable (extended dominance)
- `:neither`: no dominance — compute ICER to compare
"""
function cea_dominant(cost_a::Real, effect_a::Real, cost_b::Real, effect_b::Real)
    if cost_a <= cost_b && effect_a >= effect_b
        return :a_dominates
    elseif cost_b <= cost_a && effect_b >= effect_a
        return :b_dominates
    else
        return :neither
    end
end

# ─── Net Monetary Benefit ─────────────────────────────────────────────────────

"""
    net_monetary_benefit(effectiveness, cost, wtp_threshold)

Net monetary benefit (NMB) = effectiveness × WTP - cost.
Strategy is cost-effective when NMB > 0.
"""
function net_monetary_benefit(effectiveness::Real, cost::Real, wtp_threshold::Real)
    wtp_threshold >= 0 || throw(ArgumentError("wtp_threshold must be non-negative"))
    return effectiveness * wtp_threshold - cost
end

"""
    willingness_to_pay_threshold(delta_cost, delta_effectiveness)

Maximum WTP threshold at which a strategy is cost-effective.
Same as ICER when ΔE > 0.
"""
function willingness_to_pay_threshold(delta_cost::Real, delta_effectiveness::Real)
    delta_effectiveness <= 0 &&
        throw(ArgumentError("delta_effectiveness must be positive"))
    return delta_cost / delta_effectiveness
end

# ─── Outcome Metrics ──────────────────────────────────────────────────────────

"""
    daly(years_life_lost, years_lived_with_disability, disability_weight)

Disability-adjusted life years (WHO methodology).
- `years_life_lost`: premature mortality component
- `disability_weight`: 0 (perfect health) to 1 (death)
"""
function daly(years_life_lost::Real, years_lived_with_disability::Real,
              disability_weight::Real)
    0 <= disability_weight <= 1 ||
        throw(ArgumentError("disability_weight must be in [0,1]"))
    return years_life_lost + years_lived_with_disability * disability_weight
end

"""
    life_years_gained(intervention_survival, comparator_survival)

Undiscounted life years gained from an intervention.
"""
function life_years_gained(intervention_survival::Real, comparator_survival::Real)
    return intervention_survival - comparator_survival
end

"""
    qaly_adjusted_life_years(life_years, utility_weight)

QALYs = life years × health utility weight (0=death, 1=perfect health).
"""
function qaly_adjusted_life_years(life_years::Real, utility_weight::Real)
    0 <= utility_weight <= 1 ||
        throw(ArgumentError("utility_weight must be in [0,1]"))
    return life_years * utility_weight
end

# ─── Budget Impact Analysis ───────────────────────────────────────────────────

"""
    budget_impact_analysis(eligible_population, uptake_rate,
                           new_therapy_cost, current_therapy_cost,
                           current_market_share; horizon_years=3)

Estimate budget impact of introducing a new therapy over a time horizon.

Returns a named tuple with per-year and cumulative budget impact.

- `uptake_rate`: fraction of eligible population adopting new therapy per year
- `current_market_share`: existing market share of new therapy (pre-launch)
"""
function budget_impact_analysis(eligible_population::Real, uptake_rate::Real,
                                 new_therapy_cost::Real, current_therapy_cost::Real,
                                 current_market_share::Real;
                                 horizon_years::Integer=3)
    0 <= uptake_rate <= 1 ||
        throw(ArgumentError("uptake_rate must be in [0,1]"))
    0 <= current_market_share <= 1 ||
        throw(ArgumentError("current_market_share must be in [0,1]"))
    horizon_years > 0 || throw(ArgumentError("horizon_years must be positive"))

    annual_impacts = Float64[]
    for yr in 1:horizon_years
        new_share   = min(1.0, current_market_share + uptake_rate * yr)
        old_share   = 1 - new_share
        new_cost_total = eligible_population * new_share * new_therapy_cost
        old_cost_total = eligible_population * old_share * current_therapy_cost
        # Counterfactual: everyone on current therapy
        counterfactual = eligible_population * current_therapy_cost
        push!(annual_impacts, (new_cost_total + old_cost_total) - counterfactual)
    end
    return (annual_impacts=annual_impacts,
            cumulative_impact=sum(annual_impacts),
            horizon_years=horizon_years)
end

# ─── Decision Tree ────────────────────────────────────────────────────────────

"""
    decision_tree_ev(outcomes, probabilities)

Expected value of a decision tree node.

- `outcomes`: vector of payoffs for each branch
- `probabilities`: vector of branch probabilities (must sum to 1)
"""
function decision_tree_ev(outcomes::AbstractVector{<:Real},
                           probabilities::AbstractVector{<:Real})
    length(outcomes) == length(probabilities) ||
        throw(ArgumentError("outcomes and probabilities must have same length"))
    abs(sum(probabilities) - 1.0) > 1e-6 &&
        throw(ArgumentError("probabilities must sum to 1"))
    return dot(outcomes, probabilities)
end

# ─── Probabilistic Sensitivity Analysis ──────────────────────────────────────

"""
    probabilistic_sensitivity_analysis(cost_sampler, effect_sampler, n_simulations;
                                        wtp_threshold=50_000.0)

Run PSA by sampling cost and effectiveness from distributions.

- `cost_sampler()`: function that returns a sampled incremental cost
- `effect_sampler()`: function that returns a sampled incremental effectiveness (QALYs)
- `wtp_threshold`: cost-effectiveness threshold (\\$/QALY)

Returns named tuple with ICERs, NMBs, and fraction cost-effective.
"""
function probabilistic_sensitivity_analysis(cost_sampler::Function,
                                             effect_sampler::Function,
                                             n_simulations::Integer;
                                             wtp_threshold::Real=50_000.0)
    n_simulations > 0 || throw(ArgumentError("n_simulations must be positive"))
    icers = Float64[]
    nmbs  = Float64[]
    for _ in 1:n_simulations
        dc = cost_sampler()
        de = effect_sampler()
        push!(nmbs, net_monetary_benefit(de, dc, wtp_threshold))
        if de != 0
            push!(icers, dc / de)
        end
    end
    frac_cost_effective = count(x -> x > 0, nmbs) / n_simulations
    return (icers=icers, nmbs=nmbs,
            mean_icer=isempty(icers) ? NaN : mean(icers),
            fraction_cost_effective=frac_cost_effective)
end

# ─── Tornado / One-Way Sensitivity ───────────────────────────────────────────

"""
    tornado_diagram_inputs(base_icer, parameter_ranges, icer_function)

Compute one-way sensitivity ICER range for each parameter.

- `base_icer`: ICER at base case
- `parameter_ranges`: Dict of parameter_name => (low, high) tuples
- `icer_function(param_name, value)`: function returning ICER at given parameter value

Returns a sorted vector of named tuples (parameter, low_icer, high_icer, range).
"""
function tornado_diagram_inputs(base_icer::Real,
                                 parameter_ranges::Dict{String, Tuple{Float64, Float64}},
                                 icer_function::Function)
    results = []
    for (param, (low, high)) in parameter_ranges
        icer_low  = icer_function(param, low)
        icer_high = icer_function(param, high)
        push!(results, (parameter=param, low_icer=icer_low, high_icer=icer_high,
                        swing=abs(icer_high - icer_low)))
    end
    sort!(results, by=r -> r.swing, rev=true)
    return results
end

end # module
