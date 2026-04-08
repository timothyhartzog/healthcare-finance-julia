"""
Compatibility wrapper module for legacy imports.

Prefer `using HealthcareFinance` for the canonical package API.
"""
module HealthcareFinanceSystem

include("HealthcareFinance.jl")
using .HealthcareFinance

export npv, roi, operating_margin, cost_per_patient, break_even_units, payback_period,
       drg_revenue, weighted_payer_rate, net_collection_rate,
       moving_average_forecast, linear_trend_forecast, forecast_series,
       simple_linear_regression, predict_linear, r_squared, mean_absolute_error,
       monte_carlo_mean, simulate_growth,
       value_score, qalys

end
