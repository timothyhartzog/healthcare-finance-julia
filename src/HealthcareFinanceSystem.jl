module HealthcareFinanceSystem

include("financial_engine.jl")
include("econometrics_engine.jl")
include("simulation_engine.jl")
include("value_based_care_engine.jl")

using .FinancialEngine
using .EconometricsEngine
using .SimulationEngine
using .ValueBasedCareEngine

export npv, roi, operating_margin, cost_per_patient, break_even_units, payback_period,
       drg_revenue, weighted_payer_rate, net_collection_rate,
       simple_linear_regression, predict_linear, r_squared, mean_absolute_error,
       monte_carlo_mean, simulate_growth,
       value_score, qalys

end
