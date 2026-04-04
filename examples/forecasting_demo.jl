include("../src/forecasting_models.jl")
using .ForecastingModels

values = [100, 120, 130, 150, 170]

println("Moving Average Forecast:")
println(moving_average_forecast(values, 3, 5))

println("Linear Trend Forecast:")
println(linear_trend_forecast(values, 5))
