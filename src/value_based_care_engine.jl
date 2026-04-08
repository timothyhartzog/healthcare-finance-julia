module ValueBasedCareEngine

export value_score, qalys,
       mssp_shared_savings, mssp_shared_losses, aco_benchmark,
       total_cost_of_care, tcoc_pmpm,
       hedis_composite_score, care_gap_closure_roi,
       star_rating_score, readmission_reduction_savings,
       bundled_payment_gainshare, sdoh_financial_impact

function value_score(outcomes::Real, cost::Real)
    cost == 0 && throw(ArgumentError("cost cannot be zero"))
    return outcomes / cost
end

function qalys(years::Real, quality_weight::Real)
    return years * quality_weight
end

# ─── MSSP / ACO ───────────────────────────────────────────────────────────────

"""
    aco_benchmark(historical_expenditures, trend_rate, risk_adjustment_factor=1.0)

Set an ACO expenditure benchmark from historical per-capita spending.

- `historical_expenditures`: baseline per-beneficiary-per-year spending
- `trend_rate`: annual spending trend (e.g., 0.04 = 4%)
- `risk_adjustment_factor`: HCC-based risk score adjustment

Returns the prospective benchmark PBPY.
"""
function aco_benchmark(historical_expenditures::Real, trend_rate::Real,
                        risk_adjustment_factor::Real=1.0)
    historical_expenditures > 0 ||
        throw(ArgumentError("historical_expenditures must be positive"))
    risk_adjustment_factor > 0 ||
        throw(ArgumentError("risk_adjustment_factor must be positive"))
    return historical_expenditures * (1 + trend_rate) * risk_adjustment_factor
end

"""
    mssp_shared_savings(benchmark, actual_expenditures, assigned_beneficiaries,
                         shared_savings_rate; minimum_savings_rate=0.02)

Compute Medicare Shared Savings Program (MSSP) shared savings payment.

- `shared_savings_rate`: fraction of savings ACO retains (e.g., 0.50 for Track 1)
- `minimum_savings_rate`: minimum savings threshold before sharing (e.g., 0.02 = 2%)

Returns shared savings payment (0 if below MSR).
"""
function mssp_shared_savings(benchmark::Real, actual_expenditures::Real,
                               assigned_beneficiaries::Integer,
                               shared_savings_rate::Real;
                               minimum_savings_rate::Real=0.02)
    benchmark > 0 || throw(ArgumentError("benchmark must be positive"))
    0 < shared_savings_rate <= 1 ||
        throw(ArgumentError("shared_savings_rate must be in (0,1]"))
    total_benchmark = benchmark * assigned_beneficiaries
    total_actual    = actual_expenditures * assigned_beneficiaries
    savings = total_benchmark - total_actual
    savings_rate = savings / total_benchmark
    savings_rate < minimum_savings_rate && return 0.0
    return savings * shared_savings_rate
end

"""
    mssp_shared_losses(benchmark, actual_expenditures, assigned_beneficiaries,
                        shared_loss_rate; minimum_loss_rate=0.02)

Compute MSSP shared losses under two-sided risk tracks.
"""
function mssp_shared_losses(benchmark::Real, actual_expenditures::Real,
                              assigned_beneficiaries::Integer,
                              shared_loss_rate::Real;
                              minimum_loss_rate::Real=0.02)
    benchmark > 0 || throw(ArgumentError("benchmark must be positive"))
    0 < shared_loss_rate <= 1 ||
        throw(ArgumentError("shared_loss_rate must be in (0,1]"))
    total_benchmark = benchmark * assigned_beneficiaries
    total_actual    = actual_expenditures * assigned_beneficiaries
    losses = total_actual - total_benchmark
    losses <= 0 && return 0.0
    loss_rate = losses / total_benchmark
    loss_rate < minimum_loss_rate && return 0.0
    return losses * shared_loss_rate
end

# ─── Total Cost of Care ───────────────────────────────────────────────────────

"""
    total_cost_of_care(inpatient, outpatient, professional, pharmacy, other=0.0)

Sum all service categories into total cost of care (TCOC).
"""
function total_cost_of_care(inpatient::Real, outpatient::Real, professional::Real,
                              pharmacy::Real, other::Real=0.0)
    return inpatient + outpatient + professional + pharmacy + other
end

"""
    tcoc_pmpm(total_cost_of_care_val, member_months)

Total cost of care expressed as per-member-per-month.
"""
function tcoc_pmpm(total_cost_of_care_val::Real, member_months::Real)
    member_months > 0 || throw(ArgumentError("member_months must be positive"))
    return total_cost_of_care_val / member_months
end

# ─── HEDIS / Quality ──────────────────────────────────────────────────────────

"""
    hedis_composite_score(measure_rates, weights)

Weighted composite HEDIS quality score.

- `measure_rates`: vector of measure performance rates (0–1)
- `weights`: importance weights (sum to 1)
"""
function hedis_composite_score(measure_rates::AbstractVector{<:Real},
                                 weights::AbstractVector{<:Real})
    length(measure_rates) == length(weights) ||
        throw(ArgumentError("measure_rates and weights must have same length"))
    abs(sum(weights) - 1.0) > 1e-6 && throw(ArgumentError("weights must sum to 1"))
    return sum(r * w for (r, w) in zip(measure_rates, weights))
end

"""
    star_rating_score(measure_scores, thresholds)

Convert measure scores to a CMS Star Rating (1–5 stars) using cut-point thresholds.

- `measure_scores`: vector of raw measure percentages
- `thresholds`: vector of (2-star, 3-star, 4-star, 5-star) cut points per measure

Returns vector of star ratings for each measure and the overall composite.
"""
function star_rating_score(measure_scores::AbstractVector{<:Real},
                             thresholds::AbstractVector{<:AbstractVector})
    length(measure_scores) == length(thresholds) ||
        throw(ArgumentError("measure_scores and thresholds must have same length"))
    stars = Int[]
    for (score, cuts) in zip(measure_scores, thresholds)
        length(cuts) == 4 || throw(ArgumentError("each threshold must have 4 cut points"))
        if score >= cuts[4]
            push!(stars, 5)
        elseif score >= cuts[3]
            push!(stars, 4)
        elseif score >= cuts[2]
            push!(stars, 3)
        elseif score >= cuts[1]
            push!(stars, 2)
        else
            push!(stars, 1)
        end
    end
    return (measure_stars=stars, composite_stars=round(Int, sum(stars) / length(stars)))
end

# ─── Care Gap / ROI ───────────────────────────────────────────────────────────

"""
    care_gap_closure_roi(gaps_closed, cost_per_closure, avoided_cost_per_gap,
                          program_cost)

Return on investment from closing care gaps (e.g., HbA1c, colorectal screening).

- `gaps_closed`: number of care gaps addressed
- `cost_per_closure`: average cost to close each gap
- `avoided_cost_per_gap`: expected downstream cost avoidance per closed gap
- `program_cost`: total program operating cost

Returns (net_benefit, roi).
"""
function care_gap_closure_roi(gaps_closed::Real, cost_per_closure::Real,
                               avoided_cost_per_gap::Real, program_cost::Real)
    program_cost > 0 || throw(ArgumentError("program_cost must be positive"))
    total_avoidance = gaps_closed * avoided_cost_per_gap
    total_intervention_cost = gaps_closed * cost_per_closure + program_cost
    net_benefit = total_avoidance - total_intervention_cost
    roi = net_benefit / total_intervention_cost
    return (net_benefit=net_benefit, roi=roi)
end

# ─── Readmission Reduction ────────────────────────────────────────────────────

"""
    readmission_reduction_savings(current_rate, target_rate, total_discharges,
                                   avg_readmission_cost)

Financial savings from reducing hospital readmission rate.

- `current_rate`: current 30-day all-cause readmission rate
- `target_rate`: target readmission rate after intervention
"""
function readmission_reduction_savings(current_rate::Real, target_rate::Real,
                                        total_discharges::Integer,
                                        avg_readmission_cost::Real)
    current_rate >= target_rate ||
        throw(ArgumentError("current_rate must be >= target_rate"))
    0 <= target_rate <= 1 || throw(ArgumentError("target_rate must be in [0,1]"))
    readmissions_avoided = (current_rate - target_rate) * total_discharges
    return readmissions_avoided * avg_readmission_cost
end

# ─── Bundled Payments ─────────────────────────────────────────────────────────

"""
    bundled_payment_gainshare(target_price, actual_episode_cost, gainshare_rate;
                               stop_loss_threshold=nothing)

BPCI-A / bundled payment gainsharing calculation.

- `target_price`: CMS-set target price for the episode
- `actual_episode_cost`: actual Medicare claims cost for the episode
- `gainshare_rate`: fraction of savings retained by the provider (e.g., 0.50)
- `stop_loss_threshold`: optional per-episode stop-loss cap

Returns net payment to/from CMS (positive = savings retained).
"""
function bundled_payment_gainshare(target_price::Real, actual_episode_cost::Real,
                                    gainshare_rate::Real;
                                    stop_loss_threshold::Union{Real,Nothing}=nothing)
    0 < gainshare_rate <= 1 ||
        throw(ArgumentError("gainshare_rate must be in (0,1]"))
    raw_savings = target_price - actual_episode_cost
    if !isnothing(stop_loss_threshold)
        raw_savings = max(raw_savings, -stop_loss_threshold)
    end
    return raw_savings * gainshare_rate
end

# ─── SDOH Financial Impact ────────────────────────────────────────────────────

"""
    sdoh_financial_impact(high_risk_members, intervention_cost_per_member,
                           utilization_reduction_rate, avg_annual_cost_per_member)

Estimate ROI of a social determinants of health (SDOH) intervention.

- `utilization_reduction_rate`: expected reduction in healthcare utilization (e.g., 0.15 = 15%)
"""
function sdoh_financial_impact(high_risk_members::Integer,
                                intervention_cost_per_member::Real,
                                utilization_reduction_rate::Real,
                                avg_annual_cost_per_member::Real)
    high_risk_members > 0 || throw(ArgumentError("high_risk_members must be positive"))
    0 <= utilization_reduction_rate <= 1 ||
        throw(ArgumentError("utilization_reduction_rate must be in [0,1]"))
    total_intervention_cost = high_risk_members * intervention_cost_per_member
    total_savings = high_risk_members * avg_annual_cost_per_member * utilization_reduction_rate
    net_impact = total_savings - total_intervention_cost
    roi = total_intervention_cost > 0 ? net_impact / total_intervention_cost : 0.0
    return (total_savings=total_savings, net_impact=net_impact, roi=roi)
end

end
