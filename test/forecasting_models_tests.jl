include("../src/forecasting_models.jl")
using .ForecastingModels
using Statistics
using Test

@testset "ForecastingModels" begin
    values = [100.0, 120.0, 130.0, 150.0, 170.0]

    @testset "moving_average_forecast" begin
        f = moving_average_forecast(values, 3, 2)
        @test length(f) == 2
        @test f[1] ≈ mean(values[end-2:end])
        @test_throws ArgumentError moving_average_forecast(values, 0, 1)
        @test_throws ArgumentError moving_average_forecast(values, 6, 1)
    end

    @testset "linear_trend_forecast" begin
        f = linear_trend_forecast(values, 3)
        @test length(f) == 3
        @test f[1] > values[end]
        @test_throws ArgumentError linear_trend_forecast([100.0], 1)
    end

    @testset "forecast_series dispatch" begin
        @test length(forecast_series(values; method=:moving_average, window=3, horizon=2)) == 2
        @test length(forecast_series(values; method=:linear_trend, horizon=3)) == 3
        @test_throws ArgumentError forecast_series(values; method=:unknown)
    end
end
