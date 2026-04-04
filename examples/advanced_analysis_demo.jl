include("../src/financial_engine.jl")
include("../src/econometrics_engine.jl")
include("../src/simulation_engine.jl")
include("../src/value_based_care_engine.jl")

using .FinancialEngine
using .EconometricsEngine
using .SimulationEngine
using .ValueBasedCareEngine

println("--- Advanced Demo ---")

x = [1,2,3,4,5]
y = [2,4,5,4,5]
model = simple_linear_regression(x,y)
preds = predict_linear(model,x)
println("R2:", r_squared(y,preds))

println("Monte Carlo mean:", monte_carlo_mean(() -> rand(), 1000))

println("Value score:", value_score(0.8, 10000))

println("QALY:", qalys(10,0.9))
