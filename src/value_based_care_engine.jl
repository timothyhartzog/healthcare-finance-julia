module ValueBasedCareEngine

using Statistics

export
    # Core value metrics
    value_score, qalys,
    # Cost-effectiveness
    icer, cost_per_qaly_gained,
    # Population health / risk
    hcc_risk_score, population_risk_index,
    # Quality / outcomes
    readmission_rate, preventable_admissions_rate,
    hospital_acquired_condition_rate, composite_quality_score,
    # Pay-for-performance
    quality_payment_adjustment, shared_savings,
    # ACO / bundled
    aco_net_savings, episode_spending_pmpm,
    # Social determinants weighting
    sdoh_adjusted_outcomes

# ---------------------------------------------------------------------------
# Core value metrics
# ---------------------------------------------------------------------------

"""
Value score = outcomes / cost.
Higher is better (more outcome per unit of cost).
"""
function value_score(outcomes::Real, cost::Real)
    cost == 0 && throw(ArgumentError("cost cannot be zero"))
    return outcomes / cost
end

"""
Quality-Adjusted Life Years = life_years * quality_weight.
quality_weight ∈ [0, 1] where 1 = perfect health.
"""
function qalys(years::Real, quality_weight::Real)
    return years * quality_weight
end

# ---------------------------------------------------------------------------
# Cost-effectiveness
# ---------------------------------------------------------------------------

"""
Incremental Cost-Effectiveness Ratio (ICER).
icer = (cost_new - cost_comparator) / (effect_new - effect_comparator)
Returns the cost per unit of additional effectiveness (e.g., cost per QALY).
"""
function icer(cost_new::Real, cost_comparator::Real, effect_new::Real, effect_comparator::Real)
    Δeffect = effect_new - effect_comparator
    Δeffect == 0 && throw(ArgumentError("incremental effect cannot be zero"))
    return (cost_new - cost_comparator) / Δeffect
end

"""
Cost per QALY gained = icer when effect is measured in QALYs.
Convenience wrapper identical to icer.
"""
function cost_per_qaly_gained(cost_new::Real, cost_comparator::Real, qaly_new::Real, qaly_comparator::Real)
    return icer(cost_new, cost_comparator, qaly_new, qaly_comparator)
end

# ---------------------------------------------------------------------------
# Population health / risk
# ---------------------------------------------------------------------------

"""
HCC risk score from a vector of condition weights.
CMS-HCC model: each HCC adds an additive coefficient to a demographic base score.
demo_score: demographic baseline score.
hcc_weights: additive weight for each HCC condition present.
"""
function hcc_risk_score(demo_score::Real, hcc_weights::AbstractVector{<:Real})
    return demo_score + sum(hcc_weights; init = 0.0)
end

"""
Population risk index = mean HCC risk score across a panel of patients.
risk_scores: vector of individual risk scores.
"""
function population_risk_index(risk_scores::AbstractVector{<:Real})
    isempty(risk_scores) && throw(ArgumentError("risk_scores must not be empty"))
    return mean(risk_scores)
end

# ---------------------------------------------------------------------------
# Quality / outcomes
# ---------------------------------------------------------------------------

"""
30-day readmission rate = readmissions / discharges.
"""
function readmission_rate(readmissions::Real, discharges::Real)
    discharges == 0 && throw(ArgumentError("discharges cannot be zero"))
    return readmissions / discharges
end

"""
Preventable admissions rate = preventable_admissions / total_population.
Ambulatory Care Sensitive Conditions (ACSC) measure.
"""
function preventable_admissions_rate(preventable_admissions::Real, total_population::Real)
    total_population == 0 && throw(ArgumentError("total_population cannot be zero"))
    return preventable_admissions / total_population
end

"""
Hospital-acquired condition (HAC) rate = hac_events / patient_days.
"""
function hospital_acquired_condition_rate(hac_events::Real, patient_days::Real)
    patient_days == 0 && throw(ArgumentError("patient_days cannot be zero"))
    return hac_events / patient_days
end

"""
Composite quality score = weighted average of domain scores.
scores: vector of domain-level quality scores (e.g. 0–100 scale).
weights: importance weight for each domain (will be normalised).
"""
function composite_quality_score(
    scores::AbstractVector{<:Real},
    weights::AbstractVector{<:Real},
)
    length(scores) == length(weights) || throw(ArgumentError("scores and weights must have same length"))
    total_weight = sum(weights)
    total_weight == 0 && throw(ArgumentError("sum of weights cannot be zero"))
    return sum(s * w for (s, w) in zip(scores, weights)) / total_weight
end

# ---------------------------------------------------------------------------
# Pay-for-performance
# ---------------------------------------------------------------------------

"""
Quality payment adjustment multiplier for value-based programs.
base_payment: base reimbursement amount.
adjustment_factor: multiplicative adjustment (e.g. 1.02 = +2% bonus, 0.98 = -2% penalty).
Returns the adjusted payment.
"""
function quality_payment_adjustment(base_payment::Real, adjustment_factor::Real)
    adjustment_factor > 0 || throw(ArgumentError("adjustment_factor must be positive"))
    return base_payment * adjustment_factor
end

"""
Shared savings = max(0, (benchmark_spending - actual_spending)) * shared_savings_rate.
benchmark_spending: payer's risk-adjusted expenditure benchmark.
shared_savings_rate: fraction of savings earned by the provider (e.g. 0.50).
"""
function shared_savings(
    benchmark_spending::Real,
    actual_spending::Real;
    shared_savings_rate::Real = 0.50,
)
    0 < shared_savings_rate <= 1 || throw(ArgumentError("shared_savings_rate must be in (0, 1]"))
    savings = benchmark_spending - actual_spending
    return max(0.0, savings) * shared_savings_rate
end

# ---------------------------------------------------------------------------
# ACO / bundled
# ---------------------------------------------------------------------------

"""
ACO net savings (after minimum savings rate threshold).
total_savings: gross dollar savings vs. benchmark.
min_savings_rate: minimum savings rate that must be met to qualify for shared savings.
benchmark: total benchmark spending used to compute the savings rate.
shared_savings_rate: fraction of qualifying savings returned to the ACO.
"""
function aco_net_savings(
    total_savings::Real,
    benchmark::Real;
    min_savings_rate::Real = 0.02,
    shared_savings_rate::Real = 0.50,
)
    benchmark == 0 && throw(ArgumentError("benchmark cannot be zero"))
    savings_rate = total_savings / benchmark
    if savings_rate < min_savings_rate
        return 0.0
    end
    return total_savings * shared_savings_rate
end

"""
Episode spending per member per month (PMPM).
total_episode_spending: aggregate episode costs over the period.
member_months: total member-months in the denominator.
"""
function episode_spending_pmpm(total_episode_spending::Real, member_months::Real)
    member_months == 0 && throw(ArgumentError("member_months cannot be zero"))
    return total_episode_spending / member_months
end

# ---------------------------------------------------------------------------
# Social determinants of health
# ---------------------------------------------------------------------------

"""
SDOH-adjusted outcomes score.
raw_outcome_score: unadjusted clinical outcome metric.
sdoh_index: index measuring social risk burden (0 = no risk, 1 = highest risk).
sdoh_weight: how much SDOH risk adjusts the expected outcomes (default 0.1 = 10%).
Returns the expected (risk-adjusted) outcome score.
"""
function sdoh_adjusted_outcomes(
    raw_outcome_score::Real,
    sdoh_index::Real;
    sdoh_weight::Real = 0.1,
)
    0 <= sdoh_index <= 1 || throw(ArgumentError("sdoh_index must be between 0 and 1"))
    return raw_outcome_score * (1 - sdoh_weight * sdoh_index)
end

end # module ValueBasedCareEngine
