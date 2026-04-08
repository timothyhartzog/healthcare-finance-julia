"""
Hospital Financial Analysis Demo
=================================
End-to-end example using the HealthcareFinance toolkit to analyze
a health system's financial performance across all major domains.
"""

using HealthcareFinance

println("=" ^ 60)
println("HEALTHCARE FINANCE MODELING TOOLKIT — DEMO")
println("=" ^ 60)

# ─── 1. Income Statement & Profitability ─────────────────────────────────────
println("\n[1] INCOME STATEMENT ANALYSIS")
stmt = income_statement(
    350_000_000.0,   # gross revenue
    140_000_000.0,   # contractual adjustments
    3_500_000.0,     # bad debt
    7_000_000.0,     # charity care
    185_000_000.0;   # operating expenses
    other_income=8_000_000.0
)
println("  Net patient revenue:    \$$(round(stmt.net_patient_revenue/1e6, digits=1))M")
println("  Operating income:       \$$(round(stmt.operating_income/1e6, digits=1))M")
println("  Total margin:           $(round(stmt.total_margin*100, digits=1))%")

eb = ebitda(stmt.operating_income, 12_000_000.0)
println("  EBITDA:                 \$$(round(eb/1e6, digits=1))M")
println("  EBITDA margin:          $(round(ebitda_margin(eb, stmt.total_operating_revenue)*100,digits=1))%")

# ─── 2. Capital Investment Decision ───────────────────────────────────────────
println("\n[2] CAPITAL PROJECT ANALYSIS — NEW CARDIAC CATHETERIZATION LAB")
cfs = [-4_500_000.0, 800_000.0, 1_100_000.0, 1_400_000.0,
        1_600_000.0, 1_800_000.0, 1_500_000.0]
project_npv = npv(0.07, cfs)
project_irr = irr(cfs)
dscr_val    = debt_service_coverage_ratio(1_400_000.0, 800_000.0, 650_000.0)
println("  NPV @7%:  \$$(round(project_npv/1e3))K")
println("  IRR:      $(round(project_irr*100, digits=1))%")
println("  DSCR:     $(round(dscr_val, digits=2))x")
println("  WACC:     $(round(wacc(20_000_000.0, 5_000_000.0, 0.09, 0.045)*100,digits=2))%")

# ─── 3. MS-DRG Reimbursement ──────────────────────────────────────────────────
println("\n[3] MS-DRG PAYMENT ANALYSIS — CARDIAC SURGERY (DRG 231, weight 6.04)")
payment = ms_drg_payment(8_500.0, 6.04, 120, :mcc;
                          wage_index=1.08, dsh_adjustment=0.06, ime_adjustment=0.0)
println("  Total MS-DRG revenue:   \$$(round(payment/1e3))K")
println("  Per case:               \$$(round(payment/120))")
days_ar_val = days_in_ar(18_000_000.0, stmt.net_patient_revenue / 365)
println("  Days in AR:             $(round(days_ar_val, digits=1)) days")

# ─── 4. Actuarial: HCC Risk Score & PMPM ──────────────────────────────────────
println("\n[4] MEDICARE ADVANTAGE — HCC RISK ADJUSTMENT")
raf = hcc_risk_score(0.62, [0.318, 0.427, 0.210]; normalization_factor=1.0)
println("  Member RAF:             $(round(raf, digits=3))")
base_pmpm   = 900.0
risk_pmpm   = base_pmpm * raf
println("  Risk-adjusted revenue:  \$$(round(risk_pmpm, digits=2))/month")
mlr_val     = medical_loss_ratio(720.0, risk_pmpm)
println("  Medical loss ratio:     $(round(mlr_val*100, digits=1))%")

# ─── 5. ACO / MSSP Performance ────────────────────────────────────────────────
println("\n[5] ACO SHARED SAVINGS CALCULATION")
bench     = acо_benchmark(12_200.0, 0.035, 1.06)
savings   = mssp_shared_savings(bench, 11_400.0, 15_000, 0.50;
                                  minimum_savings_rate=0.02)
println("  ACO benchmark PBPY:     \$$(round(bench, digits=0))")
println("  Shared savings payment: \$$(round(savings/1e3))K")

rgap = care_gap_closure_roi(4_500, 30.0, 420.0, 75_000.0)
println("  Care gap closure ROI:   $(round(rgap.roi*100, digits=1))%")

# ─── 6. Cost-Effectiveness Analysis ──────────────────────────────────────────
println("\n[6] COST-EFFECTIVENESS — NEW DIABETES THERAPY")
icer_val = icer(18_000.0, 0.42)
nmb_val  = net_monetary_benefit(0.42, 18_000.0, 50_000.0)
println("  ICER:  \$$(round(icer_val, digits=0))/QALY")
println("  NMB @\$50K WTP: \$$(round(nmb_val, digits=0))")
println("  Cost-effective at \$50K/QALY: $(nmb_val > 0)")

# ─── 7. Budget Variance Analysis ──────────────────────────────────────────────
println("\n[7] Q1 BUDGET VARIANCE — CARDIOLOGY")
bav = budget_to_actual_variance(520_000.0, 498_000.0)
println("  Revenue variance:  \$$(round(bav.dollar_variance/1e3, digits=1))K ($(round(bav.pct_variance*100, digits=1))%)")
vol_var_val = volume_variance(105.0, 3350, 3500)
println("  Volume variance:   \$$(round(vol_var_val/1e3, digits=1))K")

# ─── 8. Forecasting — ED Volume ───────────────────────────────────────────────
println("\n[8] ED VOLUME FORECAST (HOLT-WINTERS ADDITIVE)")
ed_monthly = [8200.0, 7800.0, 8400.0, 9100.0,
               8300.0, 7900.0, 8500.0, 9200.0,
               8400.0, 8000.0, 8600.0, 9300.0]
fc = forecast_series(ed_monthly; method=:holt_winters_additive,
                      season=4, horizon=4, alpha=0.2, beta=0.1, gamma=0.25)
println("  Next 4 quarters forecast: ", round.(fc, digits=0))

println("\n" * "=" ^ 60)
println("Demo complete.")
