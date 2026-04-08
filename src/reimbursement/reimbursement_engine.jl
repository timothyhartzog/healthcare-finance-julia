module ReimbursementEngine

using Statistics

export drg_payment, ms_drg_payment, apr_drg_payment,
       opps_apc_payment, rbrvs_payment, rvu_to_payment,
       capitation_pmpm, pmpm_trend, payer_contract_net,
       days_in_ar, denial_rate, clean_claim_rate,
       cash_collection_efficiency, gross_collection_rate,
       bad_debt_rate, charity_care_rate, uncompensated_care_rate,
       revenue_cycle_scorecard

# ─── MS-DRG / IPPS ────────────────────────────────────────────────────────────

"""
    drg_payment(base_rate, drg_weight, cases; outlier_threshold=0.0, outlier_rate=0.8)

Compute inpatient PPS payment for a DRG.

- `base_rate`: hospital-specific blended operating+capital rate (\\$)
- `drg_weight`: MS-DRG relative weight
- `cases`: number of discharges
- `outlier_threshold`: cost above which outlier payments apply
- `outlier_rate`: marginal cost factor for outlier payments (default 80%)
"""
function drg_payment(base_rate::Real, drg_weight::Real, cases::Integer;
                     outlier_threshold::Real=0.0, outlier_rate::Real=0.8)
    base_rate > 0 || throw(ArgumentError("base_rate must be positive"))
    drg_weight > 0 || throw(ArgumentError("drg_weight must be positive"))
    cases >= 0 || throw(ArgumentError("cases must be non-negative"))
    base_payment = base_rate * drg_weight * cases
    outlier_payment = outlier_threshold > 0 ? outlier_threshold * outlier_rate * cases : 0.0
    return base_payment + outlier_payment
end

"""
    ms_drg_payment(base_rate, drg_weight, cases, cc_mcc_flag;
                   wage_index=1.0, dsh_adjustment=0.0, ime_adjustment=0.0)

Full MS-DRG IPPS payment with wage index, DSH, and IME adjustments.

- `cc_mcc_flag`: :none, :cc (complication/comorbidity), or :mcc (major CC)
- `wage_index`: area wage index (default 1.0)
- `dsh_adjustment`: disproportionate share hospital add-on (fraction)
- `ime_adjustment`: indirect medical education add-on (fraction)
"""
function ms_drg_payment(base_rate::Real, drg_weight::Real, cases::Integer,
                        cc_mcc_flag::Symbol;
                        wage_index::Real=1.0, dsh_adjustment::Real=0.0,
                        ime_adjustment::Real=0.0)
    cc_mcc_flag in (:none, :cc, :mcc) ||
        throw(ArgumentError("cc_mcc_flag must be :none, :cc, or :mcc"))
    weight_multiplier = cc_mcc_flag == :mcc ? 1.0 :   # weight already encodes MCC
                        cc_mcc_flag == :cc  ? 1.0 : 1.0
    # Labor share ~68.8% is adjusted by wage index; non-labor ~31.2% is not
    labor_share = 0.688
    adjusted_base = base_rate * (labor_share * wage_index + (1 - labor_share))
    base_payment  = adjusted_base * drg_weight * weight_multiplier * cases
    total = base_payment * (1 + dsh_adjustment + ime_adjustment)
    return total
end

"""
    apr_drg_payment(base_rate, drg_weight, severity_level, cases)

All-Patient Refined DRG payment (used by many Medicaid and commercial payers).

- `severity_level`: 1 (minor), 2 (moderate), 3 (major), 4 (extreme)
"""
function apr_drg_payment(base_rate::Real, drg_weight::Real,
                         severity_level::Integer, cases::Integer)
    severity_level in 1:4 || throw(ArgumentError("severity_level must be 1–4"))
    # Severity adjustors relative to base weight
    severity_adjustors = [0.60, 1.00, 1.50, 2.20]
    adjusted_weight = drg_weight * severity_adjustors[severity_level]
    return base_rate * adjusted_weight * cases
end

# ─── OPPS / APC ───────────────────────────────────────────────────────────────

"""
    opps_apc_payment(conversion_factor, apc_relative_weight, visits;
                     copay_reduction=0.0, pass_through=0.0)

Hospital Outpatient Prospective Payment System (OPPS) APC payment.

- `conversion_factor`: CMS national conversion factor (\\$/RVW)
- `apc_relative_weight`: relative payment weight for the APC
- `visits`: number of outpatient encounters
- `copay_reduction`: amount deducted for beneficiary cost-sharing
- `pass_through`: device/drug pass-through amount per visit
"""
function opps_apc_payment(conversion_factor::Real, apc_relative_weight::Real,
                          visits::Integer;
                          copay_reduction::Real=0.0, pass_through::Real=0.0)
    conversion_factor > 0 || throw(ArgumentError("conversion_factor must be positive"))
    apc_relative_weight > 0 || throw(ArgumentError("apc_relative_weight must be positive"))
    visits >= 0 || throw(ArgumentError("visits must be non-negative"))
    per_visit = conversion_factor * apc_relative_weight - copay_reduction + pass_through
    return per_visit * visits
end

# ─── RBRVS / RVU ──────────────────────────────────────────────────────────────

"""
    rvu_to_payment(work_rvu, pe_rvu, mp_rvu, conversion_factor;
                   gpci_work=1.0, gpci_pe=1.0, gpci_mp=1.0)

Convert RVU components to Medicare physician fee schedule payment.

- `work_rvu`: physician work relative value unit
- `pe_rvu`: practice expense RVU
- `mp_rvu`: malpractice RVU
- `conversion_factor`: CMS conversion factor (\\$/RVU)
- `gpci_*`: geographic practice cost index adjustments
"""
function rvu_to_payment(work_rvu::Real, pe_rvu::Real, mp_rvu::Real,
                        conversion_factor::Real;
                        gpci_work::Real=1.0, gpci_pe::Real=1.0, gpci_mp::Real=1.0)
    conversion_factor > 0 || throw(ArgumentError("conversion_factor must be positive"))
    total_rvu = work_rvu * gpci_work + pe_rvu * gpci_pe + mp_rvu * gpci_mp
    return total_rvu * conversion_factor
end

"""
    rbrvs_payment(work_rvu, pe_rvu, mp_rvu, conversion_factor, units;
                  gpci_work=1.0, gpci_pe=1.0, gpci_mp=1.0)

Total RBRVS physician fee schedule payment for multiple service units.
"""
function rbrvs_payment(work_rvu::Real, pe_rvu::Real, mp_rvu::Real,
                       conversion_factor::Real, units::Integer;
                       gpci_work::Real=1.0, gpci_pe::Real=1.0, gpci_mp::Real=1.0)
    units >= 0 || throw(ArgumentError("units must be non-negative"))
    per_unit = rvu_to_payment(work_rvu, pe_rvu, mp_rvu, conversion_factor;
                              gpci_work=gpci_work, gpci_pe=gpci_pe, gpci_mp=gpci_mp)
    return per_unit * units
end

# ─── Capitation / PMPM ────────────────────────────────────────────────────────

"""
    capitation_pmpm(total_expenditure, member_months)

Per-member-per-month capitation rate.
"""
function capitation_pmpm(total_expenditure::Real, member_months::Real)
    member_months > 0 || throw(ArgumentError("member_months must be positive"))
    return total_expenditure / member_months
end

"""
    pmpm_trend(base_pmpm, trend_rate, months)

Project PMPM forward using a monthly compound trend rate.
"""
function pmpm_trend(base_pmpm::Real, trend_rate::Real, months::Integer)
    months >= 0 || throw(ArgumentError("months must be non-negative"))
    return base_pmpm * (1 + trend_rate)^months
end

# ─── Payer Contract Analytics ─────────────────────────────────────────────────

"""
    payer_contract_net(charges, allowed_rate, payer_share, patient_copay)

Net revenue under a payer contract.

- `charges`: gross charges billed
- `allowed_rate`: fraction of charges the payer allows (e.g., 0.45)
- `payer_share`: fraction of allowed amount paid by payer (e.g., 0.80)
- `patient_copay`: patient cost-sharing per encounter
"""
function payer_contract_net(charges::Real, allowed_rate::Real,
                            payer_share::Real, patient_copay::Real)
    0 < allowed_rate <= 1 || throw(ArgumentError("allowed_rate must be in (0,1]"))
    0 < payer_share <= 1 || throw(ArgumentError("payer_share must be in (0,1]"))
    patient_copay >= 0 || throw(ArgumentError("patient_copay must be non-negative"))
    allowed = charges * allowed_rate
    payer_payment = allowed * payer_share
    return payer_payment + patient_copay
end

# ─── Revenue Cycle KPIs ───────────────────────────────────────────────────────

"""
    days_in_ar(ending_ar_balance, average_daily_revenue)

Days in accounts receivable — measures collection speed.
Lower is better; typical hospital benchmark ≤ 50 days.
"""
function days_in_ar(ending_ar_balance::Real, average_daily_revenue::Real)
    average_daily_revenue > 0 ||
        throw(ArgumentError("average_daily_revenue must be positive"))
    return ending_ar_balance / average_daily_revenue
end

"""
    denial_rate(denied_claims, total_claims_submitted)

Claim denial rate. Industry benchmark < 5%.
"""
function denial_rate(denied_claims::Integer, total_claims_submitted::Integer)
    total_claims_submitted > 0 ||
        throw(ArgumentError("total_claims_submitted must be positive"))
    return denied_claims / total_claims_submitted
end

"""
    clean_claim_rate(claims_paid_first_submission, total_claims_submitted)

Fraction of claims paid on first submission without rework. Benchmark ≥ 95%.
"""
function clean_claim_rate(claims_paid_first_submission::Integer,
                          total_claims_submitted::Integer)
    total_claims_submitted > 0 ||
        throw(ArgumentError("total_claims_submitted must be positive"))
    return claims_paid_first_submission / total_claims_submitted
end

"""
    gross_collection_rate(payments_received, gross_charges)

Gross collection rate = payments / gross charges.
"""
function gross_collection_rate(payments_received::Real, gross_charges::Real)
    gross_charges > 0 || throw(ArgumentError("gross_charges must be positive"))
    return payments_received / gross_charges
end

"""
    cash_collection_efficiency(actual_cash_collected, net_revenue)

Cash collection efficiency = cash collected / net patient revenue. Benchmark ≥ 100%.
"""
function cash_collection_efficiency(actual_cash_collected::Real, net_revenue::Real)
    net_revenue > 0 || throw(ArgumentError("net_revenue must be positive"))
    return actual_cash_collected / net_revenue
end

"""
    bad_debt_rate(bad_debt_expense, gross_revenue)

Bad debt as a percentage of gross revenue.
"""
function bad_debt_rate(bad_debt_expense::Real, gross_revenue::Real)
    gross_revenue > 0 || throw(ArgumentError("gross_revenue must be positive"))
    return bad_debt_expense / gross_revenue
end

"""
    charity_care_rate(charity_care_cost, total_operating_expense)

Charity care as a percentage of total operating expense (IRS Form 990 Schedule H).
"""
function charity_care_rate(charity_care_cost::Real, total_operating_expense::Real)
    total_operating_expense > 0 ||
        throw(ArgumentError("total_operating_expense must be positive"))
    return charity_care_cost / total_operating_expense
end

"""
    uncompensated_care_rate(bad_debt_expense, charity_care_cost, gross_revenue)

Combined uncompensated care rate (bad debt + charity care) / gross revenue.
"""
function uncompensated_care_rate(bad_debt_expense::Real, charity_care_cost::Real,
                                 gross_revenue::Real)
    gross_revenue > 0 || throw(ArgumentError("gross_revenue must be positive"))
    return (bad_debt_expense + charity_care_cost) / gross_revenue
end

"""
    revenue_cycle_scorecard(; days_ar, denial_rt, clean_claim_rt, cash_efficiency)

Return a named tuple scoring revenue cycle performance against benchmarks.
Each score is a Symbol: :exceeds, :meets, or :below.
"""
function revenue_cycle_scorecard(; days_ar::Real, denial_rt::Real,
                                  clean_claim_rt::Real, cash_efficiency::Real)
    score_dar   = days_ar       <= 40 ? :exceeds : days_ar       <= 50 ? :meets : :below
    score_den   = denial_rt     <= 0.03 ? :exceeds : denial_rt   <= 0.05 ? :meets : :below
    score_ccr   = clean_claim_rt >= 0.98 ? :exceeds : clean_claim_rt >= 0.95 ? :meets : :below
    score_cash  = cash_efficiency >= 1.02 ? :exceeds : cash_efficiency >= 1.0 ? :meets : :below
    return (days_ar=score_dar, denial_rate=score_den,
            clean_claim_rate=score_ccr, cash_efficiency=score_cash)
end

end # module
