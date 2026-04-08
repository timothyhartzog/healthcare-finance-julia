module BudgetingEngine

using Statistics

export operating_budget, flex_budget, volume_variance, price_variance,
       efficiency_variance, mix_variance, rate_volume_variance,
       capital_budget_rank, zero_based_budget_score,
       rolling_forecast_update, budget_to_actual_variance

# ─── Operating Budget ─────────────────────────────────────────────────────────

"""
    operating_budget(fixed_costs, variable_cost_per_unit, expected_volume,
                     price_per_unit; other_revenue=0.0)

Simple departmental operating budget.

Returns a named tuple with revenue, variable costs, total costs, and operating income.
"""
function operating_budget(fixed_costs::Real, variable_cost_per_unit::Real,
                           expected_volume::Real, price_per_unit::Real;
                           other_revenue::Real=0.0)
    fixed_costs >= 0 || throw(ArgumentError("fixed_costs must be non-negative"))
    expected_volume >= 0 || throw(ArgumentError("expected_volume must be non-negative"))
    revenue         = price_per_unit * expected_volume + other_revenue
    variable_costs  = variable_cost_per_unit * expected_volume
    total_costs     = fixed_costs + variable_costs
    operating_income= revenue - total_costs
    contribution_margin = revenue - variable_costs
    return (
        revenue                = revenue,
        variable_costs         = variable_costs,
        fixed_costs            = fixed_costs,
        total_costs            = total_costs,
        contribution_margin    = contribution_margin,
        operating_income       = operating_income,
    )
end

"""
    flex_budget(fixed_costs, variable_cost_per_unit, actual_volume, price_per_unit;
                other_revenue=0.0)

Flexible budget adjusted to actual volume. Used for variance analysis.
"""
function flex_budget(fixed_costs::Real, variable_cost_per_unit::Real,
                     actual_volume::Real, price_per_unit::Real;
                     other_revenue::Real=0.0)
    return operating_budget(fixed_costs, variable_cost_per_unit, actual_volume,
                             price_per_unit; other_revenue=other_revenue)
end

# ─── Variance Analysis ────────────────────────────────────────────────────────

"""
    volume_variance(budgeted_contribution_margin_per_unit,
                    actual_volume, budgeted_volume)

Volume variance = budgeted CM/unit × (actual volume - budgeted volume).
Favorable when actual > budgeted.
"""
function volume_variance(budgeted_cm_per_unit::Real,
                          actual_volume::Real, budgeted_volume::Real)
    return budgeted_cm_per_unit * (actual_volume - budgeted_volume)
end

"""
    price_variance(actual_price, budgeted_price, actual_volume)

Price (rate) variance = (actual price - budgeted price) × actual volume.
"""
function price_variance(actual_price::Real, budgeted_price::Real, actual_volume::Real)
    return (actual_price - budgeted_price) * actual_volume
end

"""
    efficiency_variance(budgeted_cost_per_unit, actual_units_used,
                         standard_units_per_output, actual_output)

Efficiency variance = budgeted cost/unit × (actual inputs used - standard inputs).

Used in cost accounting for nursing hours, supply usage, etc.
"""
function efficiency_variance(budgeted_cost_per_unit::Real, actual_units_used::Real,
                               standard_units_per_output::Real, actual_output::Real)
    standard_inputs = standard_units_per_output * actual_output
    return budgeted_cost_per_unit * (actual_units_used - standard_inputs)
end

"""
    mix_variance(actual_volumes, budgeted_volumes, budgeted_margins)

Payer/service mix variance — impact of shifting volume composition.

Returns total mix variance and per-category mix variances.
"""
function mix_variance(actual_volumes::AbstractVector{<:Real},
                       budgeted_volumes::AbstractVector{<:Real},
                       budgeted_margins::AbstractVector{<:Real})
    length(actual_volumes) == length(budgeted_volumes) == length(budgeted_margins) ||
        throw(ArgumentError("all vectors must have same length"))
    total_actual   = sum(actual_volumes)
    total_budgeted = sum(budgeted_volumes)
    total_budgeted > 0 || throw(ArgumentError("sum of budgeted_volumes must be positive"))

    weighted_avg_budgeted_margin = sum(budgeted_volumes .* budgeted_margins) / total_budgeted
    variances = [total_actual * (budgeted_volumes[i]/total_budgeted - actual_volumes[i]/total_actual) *
                 weighted_avg_budgeted_margin for i in eachindex(actual_volumes)]
    return (total_mix_variance=sum(variances), per_category=variances)
end

"""
    rate_volume_variance(actual_revenue, budgeted_revenue,
                          actual_volume, budgeted_volume, budgeted_price)

Decompose a total revenue variance into rate and volume components.

Returns `(total_variance, rate_variance, volume_variance_val)`.
"""
function rate_volume_variance(actual_revenue::Real, budgeted_revenue::Real,
                               actual_volume::Real, budgeted_volume::Real,
                               budgeted_price::Real)
    total_variance = actual_revenue - budgeted_revenue
    vol_var  = volume_variance(budgeted_price, actual_volume, budgeted_volume)
    rate_var = total_variance - vol_var
    return (total_variance=total_variance, rate_variance=rate_var,
            volume_variance=vol_var)
end

"""
    budget_to_actual_variance(budget, actual)

Simple budget-to-actual dollar and percentage variance.
Returns `(dollar_variance, pct_variance)`. Positive = favorable (under budget).
"""
function budget_to_actual_variance(budget::Real, actual::Real)
    budget == 0 && throw(ArgumentError("budget cannot be zero"))
    dollar_var = budget - actual
    pct_var = dollar_var / abs(budget)
    return (dollar_variance=dollar_var, pct_variance=pct_var)
end

# ─── Capital Budget Ranking ───────────────────────────────────────────────────

"""
    capital_budget_rank(projects; npv_weight=0.7, strategic_weight=0.3)

Rank capital projects by weighted score.

- `projects`: vector of named tuples with fields `name`, `npv`, `strategic_score` (0–10)
- Returns sorted vector of projects with composite scores.
"""
function capital_budget_rank(projects::AbstractVector;
                              npv_weight::Real=0.7, strategic_weight::Real=0.3)
    abs(npv_weight + strategic_weight - 1.0) > 1e-6 &&
        throw(ArgumentError("npv_weight + strategic_weight must equal 1"))
    isempty(projects) && throw(ArgumentError("projects cannot be empty"))

    # Normalise NPV to 0–10 scale
    npvs = [p.npv for p in projects]
    min_npv = minimum(npvs); max_npv = maximum(npvs)
    range_npv = max_npv - min_npv
    scored = map(projects) do p
        npv_norm = range_npv > 0 ? (p.npv - min_npv) / range_npv * 10 : 5.0
        score = npv_weight * npv_norm + strategic_weight * p.strategic_score
        (name=p.name, npv=p.npv, strategic_score=p.strategic_score, composite_score=score)
    end
    return sort(scored, by=p -> p.composite_score, rev=true)
end

# ─── Zero-Based Budget ────────────────────────────────────────────────────────

"""
    zero_based_budget_score(necessity_score, cost_effectiveness, strategic_alignment;
                             weights=(0.4, 0.3, 0.3))

Score a budget line item under zero-based budgeting (ZBB).

- Scores are 0–10; weighted sum returned.
- Use to prioritise which line items to fund from scratch.
"""
function zero_based_budget_score(necessity_score::Real, cost_effectiveness::Real,
                                   strategic_alignment::Real;
                                   weights::Tuple{Float64,Float64,Float64}=(0.4,0.3,0.3))
    all(0 <= s <= 10 for s in (necessity_score, cost_effectiveness, strategic_alignment)) ||
        throw(ArgumentError("all scores must be in [0,10]"))
    abs(sum(weights) - 1.0) > 1e-6 && throw(ArgumentError("weights must sum to 1"))
    return weights[1]*necessity_score + weights[2]*cost_effectiveness +
           weights[3]*strategic_alignment
end

# ─── Rolling Forecast ─────────────────────────────────────────────────────────

"""
    rolling_forecast_update(actuals_ytd, periods_elapsed, periods_total,
                             original_annual_budget)

Update the annual forecast using year-to-date actuals with run-rate projection.

Returns `(projected_annual, variance_to_budget)`.
"""
function rolling_forecast_update(actuals_ytd::Real, periods_elapsed::Integer,
                                   periods_total::Integer, original_annual_budget::Real)
    periods_elapsed > 0 || throw(ArgumentError("periods_elapsed must be positive"))
    periods_total > periods_elapsed ||
        throw(ArgumentError("periods_total must exceed periods_elapsed"))
    run_rate          = actuals_ytd / periods_elapsed
    projected_annual  = run_rate * periods_total
    variance          = original_annual_budget - projected_annual
    return (projected_annual=projected_annual,
            variance_to_budget=variance,
            pct_variance=variance / abs(original_annual_budget))
end

end # module
