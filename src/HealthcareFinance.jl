"""
    module HealthcareFinance

Top-level public API for healthcare finance analytics.

# Example
```julia
using HealthcareFinance

margin = operating_margin(1_000_000.0, 800_000.0)
forecast = forecast_series([100.0, 120.0, 140.0]; method=:linear_trend, horizon=2)
```
"""
module HealthcareFinance

include("financial_engine.jl")
include("econometrics_engine.jl")
include("simulation_engine.jl")
include("value_based_care_engine.jl")
include("forecasting_models.jl")

using .FinancialEngine
using .EconometricsEngine
using .SimulationEngine
using .ValueBasedCareEngine
using .ForecastingModels

export npv, roi, operating_margin, cost_per_patient, break_even_units, payback_period,
       drg_revenue, weighted_payer_rate, net_collection_rate,
       moving_average_forecast, linear_trend_forecast, forecast_series,
       simple_linear_regression, predict_linear, r_squared, mean_absolute_error,
       monte_carlo_mean, simulate_growth,
       value_score, qalys

end
