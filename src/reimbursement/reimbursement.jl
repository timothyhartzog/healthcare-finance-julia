module Reimbursement

export drg_payment, drg_outlier_payment, case_mix_index,
       apc_payment, rvu_payment,
       denial_rate, clean_claim_rate,
       collection_rate, net_collection_rate, bad_debt_rate,
       payer_mix_revenue, effective_reimbursement_rate,
       episode_payment_savings,
       cost_to_charge_ratio, estimated_cost_from_charges

# ---------------------------------------------------------------------------
# DRG / Inpatient Prospective Payment System
# ---------------------------------------------------------------------------

"""
DRG payment = base_rate * drg_weight * (1 + dsh_adjustment + ime_adjustment).
dsh_adjustment: Disproportionate Share Hospital adjustment (decimal, e.g. 0.05).
ime_adjustment: Indirect Medical Education adjustment (decimal).
"""
function drg_payment(
    base_rate::Real,
    drg_weight::Real;
    dsh_adjustment::Real = 0.0,
    ime_adjustment::Real = 0.0,
)
    base_rate > 0 || throw(ArgumentError("base_rate must be positive"))
    drg_weight > 0 || throw(ArgumentError("drg_weight must be positive"))
    return base_rate * drg_weight * (1 + dsh_adjustment + ime_adjustment)
end

"""
DRG outlier payment for high-cost cases.
If actual_cost > (drg_payment + fixed_loss_threshold), the payer shares the excess.
Returns the additional outlier payment amount (zero if threshold not exceeded).
outlier_share: fraction of excess costs covered by payer (default 0.80 for Medicare).
"""
function drg_outlier_payment(
    actual_cost::Real,
    standard_drg_payment::Real,
    fixed_loss_threshold::Real;
    outlier_share::Real = 0.80,
)
    cutoff = standard_drg_payment + fixed_loss_threshold
    if actual_cost <= cutoff
        return 0.0
    end
    return outlier_share * (actual_cost - cutoff)
end

"""
Case mix index (CMI) = sum of all DRG weights for discharges / number of discharges.
drg_weights is a vector of weights for each discharge.
"""
function case_mix_index(drg_weights::AbstractVector{<:Real})
    isempty(drg_weights) && throw(ArgumentError("drg_weights must not be empty"))
    return sum(drg_weights) / length(drg_weights)
end

# ---------------------------------------------------------------------------
# Outpatient / Ambulatory Payment Classification (APC)
# ---------------------------------------------------------------------------

"""
APC payment = apc_base_rate * relative_weight * wage_adjustment.
wage_adjustment accounts for geographic labor cost differences (default 1.0).
"""
function apc_payment(
    apc_base_rate::Real,
    relative_weight::Real;
    wage_adjustment::Real = 1.0,
)
    apc_base_rate > 0 || throw(ArgumentError("apc_base_rate must be positive"))
    relative_weight > 0 || throw(ArgumentError("relative_weight must be positive"))
    return apc_base_rate * relative_weight * wage_adjustment
end

# ---------------------------------------------------------------------------
# Physician / Resource-Based Relative Value Scale (RBRVS)
# ---------------------------------------------------------------------------

"""
RVU payment = (work_rvu * work_gpci + pe_rvu * pe_gpci + mp_rvu * mp_gpci) * conversion_factor.
work_rvu: work relative value units.
pe_rvu: practice expense RVUs.
mp_rvu: malpractice RVUs.
*_gpci: Geographic Practice Cost Index adjustments (default 1.0).
conversion_factor: national conversion factor (e.g. ~32–34 USD for Medicare).
"""
function rvu_payment(
    work_rvu::Real,
    pe_rvu::Real,
    mp_rvu::Real,
    conversion_factor::Real;
    work_gpci::Real = 1.0,
    pe_gpci::Real = 1.0,
    mp_gpci::Real = 1.0,
)
    conversion_factor > 0 || throw(ArgumentError("conversion_factor must be positive"))
    adjusted = work_rvu * work_gpci + pe_rvu * pe_gpci + mp_rvu * mp_gpci
    return adjusted * conversion_factor
end

# ---------------------------------------------------------------------------
# Revenue cycle analytics
# ---------------------------------------------------------------------------

"""
Denial rate = denied_claims / total_claims_submitted.
"""
function denial_rate(denied_claims::Real, total_claims_submitted::Real)
    total_claims_submitted == 0 && throw(ArgumentError("total_claims_submitted cannot be zero"))
    return denied_claims / total_claims_submitted
end

"""
Clean claim rate = clean_claims / total_claims_submitted.
A clean claim requires no additional information to process.
"""
function clean_claim_rate(clean_claims::Real, total_claims_submitted::Real)
    total_claims_submitted == 0 && throw(ArgumentError("total_claims_submitted cannot be zero"))
    return clean_claims / total_claims_submitted
end

"""
Days in A/R = net_ar / (net_patient_revenue / days_in_period).
Standard revenue cycle efficiency benchmark.
"""
function days_in_accounts_receivable(
    net_ar::Real,
    net_patient_revenue::Real;
    days_in_period::Int = 365,
)
    net_patient_revenue == 0 && throw(ArgumentError("net_patient_revenue cannot be zero"))
    return net_ar / (net_patient_revenue / days_in_period)
end

"""
Collection rate = collections / net_patient_revenue.
Gross collections divided by net patient revenue.
"""
function collection_rate(collections::Real, net_patient_revenue::Real)
    net_patient_revenue == 0 && throw(ArgumentError("net_patient_revenue cannot be zero"))
    return collections / net_patient_revenue
end

"""
Net collection rate = payments / (charges - contractual_adjustments).
"""
function net_collection_rate(payments::Real, charges::Real, contractual_adjustments::Real)
    denominator = charges - contractual_adjustments
    denominator == 0 && throw(ArgumentError("charges minus contractual adjustments cannot be zero"))
    return payments / denominator
end

"""
Bad debt rate = bad_debt_expense / net_patient_revenue.
"""
function bad_debt_rate(bad_debt_expense::Real, net_patient_revenue::Real)
    net_patient_revenue == 0 && throw(ArgumentError("net_patient_revenue cannot be zero"))
    return bad_debt_expense / net_patient_revenue
end

# ---------------------------------------------------------------------------
# Payer mix
# ---------------------------------------------------------------------------

"""
Total payer mix revenue from volumes, rates, and payer shares.
volumes: vector of patient volumes per payer.
rates: vector of reimbursement rates per payer.
Returns total revenue.
"""
function payer_mix_revenue(
    volumes::AbstractVector{<:Real},
    rates::AbstractVector{<:Real},
)
    length(volumes) == length(rates) ||
        throw(ArgumentError("volumes and rates must have same length"))
    return sum(v * r for (v, r) in zip(volumes, rates))
end

"""
Effective (blended) reimbursement rate across payers.
rates: reimbursement rate per payer.
shares: volume or revenue share per payer (should sum to 1.0).
"""
function effective_reimbursement_rate(
    rates::AbstractVector{<:Real},
    shares::AbstractVector{<:Real},
)
    length(rates) == length(shares) ||
        throw(ArgumentError("rates and shares must have same length"))
    return sum(r * s for (r, s) in zip(rates, shares))
end

# ---------------------------------------------------------------------------
# Bundled / episode-based payment
# ---------------------------------------------------------------------------

"""
Episode payment savings = target_price - actual_episode_cost.
Positive value indicates savings (shared with provider in many models).
"""
function episode_payment_savings(target_price::Real, actual_episode_cost::Real)
    return target_price - actual_episode_cost
end

# ---------------------------------------------------------------------------
# Cost-to-charge ratio
# ---------------------------------------------------------------------------

"""
Cost-to-charge ratio (CCR) = total_costs / total_charges.
Used to estimate actual costs from billed charges.
"""
function cost_to_charge_ratio(total_costs::Real, total_charges::Real)
    total_charges == 0 && throw(ArgumentError("total_charges cannot be zero"))
    return total_costs / total_charges
end

"""
Estimated cost from charges using the cost-to-charge ratio.
"""
function estimated_cost_from_charges(total_charges::Real, ccr::Real)
    return total_charges * ccr
end

end # module Reimbursement
