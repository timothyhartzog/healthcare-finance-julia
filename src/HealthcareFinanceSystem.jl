"""
Compatibility wrapper module for legacy imports.

Prefer `using HealthcareFinance` for the canonical package API.
"""
module HealthcareFinanceSystem

include("HealthcareFinance.jl")
using .HealthcareFinance
include("accounting/accounting.jl")
include("reimbursement/reimbursement.jl")
include("forecasting/forecasting.jl")

using .Accounting
using .Reimbursement
using .Forecasting

# FinancialEngine
export npv, roi, operating_margin, cost_per_patient, break_even_units, payback_period,
       drg_revenue, weighted_payer_rate, net_collection_rate

# EconometricsEngine
export simple_linear_regression, predict_linear, r_squared, mean_absolute_error,
       ols_regression, predict_ols,
       logistic_regression, predict_logistic,
       difference_in_differences, two_stage_least_squares,
       coefficient_of_variation, vif_simple

# SimulationEngine
export monte_carlo_mean, monte_carlo_percentile,
       simulate_growth, simulate_stochastic_growth,
       one_way_sensitivity, tornado_values,
       scenario_npv,
       bootstrap_mean, bootstrap_ci

# ValueBasedCareEngine
export value_score, qalys,
       icer, cost_per_qaly_gained,
       hcc_risk_score, population_risk_index,
       readmission_rate, preventable_admissions_rate,
       hospital_acquired_condition_rate, composite_quality_score,
       quality_payment_adjustment, shared_savings,
       aco_net_savings, episode_spending_pmpm,
       sdoh_adjusted_outcomes

# ForecastingModels
export moving_average_forecast, linear_trend_forecast, forecast_series

# Accounting
export current_ratio, quick_ratio, cash_ratio,
       debt_to_equity, debt_to_assets, equity_multiplier, interest_coverage,
       gross_profit_margin, net_profit_margin, return_on_assets, return_on_equity,
       ebitda, ebitda_margin,
       asset_turnover, days_in_accounts_receivable, days_in_accounts_payable,
       inventory_turnover,
       occupancy_rate, average_length_of_stay, cost_per_discharge,
       revenue_per_adjusted_patient_day,
       overhead_rate, full_absorption_cost, contribution_margin_ratio,
       activity_based_cost,
       gross_profit, operating_income, net_income,
       free_cash_flow

# Reimbursement
export drg_payment, drg_outlier_payment, case_mix_index,
       apc_payment, rvu_payment,
       denial_rate, clean_claim_rate,
       collection_rate, bad_debt_rate,
       payer_mix_revenue, effective_reimbursement_rate,
       episode_payment_savings,
       cost_to_charge_ratio, estimated_cost_from_charges

# Forecasting
export simple_exponential_smoothing, holt_double_exponential, holt_winters_additive,
       weighted_moving_average,
       seasonal_indices, deseasonalize, reseasonalize,
       budget_variance, budget_variance_pct, flexible_budget_variance,
       rmse, mape, forecast_bias

end # module HealthcareFinanceSystem
