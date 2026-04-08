"""
    module HealthcareFinance

Top-level public API for healthcare finance analytics.

# Example
```julia
using HealthcareFinance

margin = operating_margin(1_000_000.0, 800_000.0)
forecast = forecast_series([100.0, 120.0, 140.0]; method=:linear_trend, horizon=2)
irr_val  = irr([-500_000.0, 150_000.0, 200_000.0, 250_000.0])
savings  = mssp_shared_savings(12_000.0, 11_500.0, 5_000, 0.50)
```
"""
module HealthcareFinance

include("financial_engine.jl")
include("econometrics_engine.jl")
include("simulation_engine.jl")
include("value_based_care_engine.jl")
include("forecasting_models.jl")
include("accounting/accounting_engine.jl")
include("reimbursement/reimbursement_engine.jl")
include("actuarial/actuarial_engine.jl")
include("cost_effectiveness/cea_engine.jl")
include("budgeting/budgeting_engine.jl")

using .FinancialEngine
using .EconometricsEngine
using .SimulationEngine
using .ValueBasedCareEngine
using .ForecastingModels
using .AccountingEngine
using .ReimbursementEngine
using .ActuarialEngine
using .CostEffectivenessEngine
using .BudgetingEngine

# FinancialEngine
export npv, irr, mirr, roi, operating_margin, cost_per_patient, break_even_units,
       payback_period, discounted_payback_period,
       drg_revenue, weighted_payer_rate, net_collection_rate,
       wacc, debt_service_coverage_ratio, interest_coverage_ratio,
       profitability_index, modified_duration, lease_vs_buy

# ForecastingModels
export moving_average_forecast, linear_trend_forecast, forecast_series,
       holt_winters_additive, holt_winters_multiplicative,
       forecast_mape, forecast_rmse, seasonal_decompose, exponential_smoothing

# EconometricsEngine
export simple_linear_regression, predict_linear, r_squared, mean_absolute_error,
       multiple_regression, predict_multiple, rmse,
       logistic_regression, logistic_predict, logistic_accuracy,
       difference_in_differences, elasticity,
       coefficient_of_variation, pearson_correlation

# SimulationEngine
export monte_carlo_mean, simulate_growth,
       bootstrap_ci, probabilistic_sensitivity,
       tornado_sensitivity, scenario_analysis,
       simulate_claims, discrete_event_patient_flow

# ValueBasedCareEngine
export value_score, qalys,
       mssp_shared_savings, mssp_shared_losses, aco_benchmark,
       total_cost_of_care, tcoc_pmpm,
       hedis_composite_score, care_gap_closure_roi,
       star_rating_score, readmission_reduction_savings,
       bundled_payment_gainshare, sdoh_financial_impact

# AccountingEngine
export income_statement, balance_sheet_ratios, cash_flow_indirect,
       current_ratio, quick_ratio, debt_to_equity, equity_multiplier,
       days_cash_on_hand, long_term_debt_to_capitalization,
       straight_line_depreciation, macrs_depreciation_schedule,
       charitable_community_benefit_rate, net_assets_change,
       fund_accounting_summary, operating_leverage,
       ebitda, ebitda_margin, total_margin, operating_margin_hfma

# ReimbursementEngine
export drg_payment, ms_drg_payment, apr_drg_payment,
       opps_apc_payment, rbrvs_payment, rvu_to_payment,
       capitation_pmpm, pmpm_trend, payer_contract_net,
       days_in_ar, denial_rate, clean_claim_rate,
       cash_collection_efficiency, gross_collection_rate,
       bad_debt_rate, charity_care_rate, uncompensated_care_rate,
       revenue_cycle_scorecard

# ActuarialEngine
export claims_triangle_development, ibnr_reserve, loss_development_factors,
       hcc_risk_score, hcc_prospective_score,
       pmpm_by_category, medical_loss_ratio, admin_expense_ratio,
       premium_rate_development, community_rating_premium,
       utilization_rate, admissions_per_thousand, ed_visits_per_thousand,
       claim_frequency, claim_severity, pure_premium,
       credibility_weight, blended_rate

# CostEffectivenessEngine
export markov_cohort, markov_cycle_traces, icer,
       cea_dominant, budget_impact_analysis,
       net_monetary_benefit, willingness_to_pay_threshold,
       daly, life_years_gained, qaly_adjusted_life_years,
       decision_tree_ev, probabilistic_sensitivity_analysis,
       tornado_diagram_inputs

# BudgetingEngine
export operating_budget, flex_budget, volume_variance, price_variance,
       efficiency_variance, mix_variance, rate_volume_variance,
       capital_budget_rank, zero_based_budget_score,
       rolling_forecast_update, budget_to_actual_variance

end

