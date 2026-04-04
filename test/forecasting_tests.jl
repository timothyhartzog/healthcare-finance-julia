include("../src/forecasting/forecasting.jl")
using .Forecasting
using Statistics
using Test

@testset "Forecasting" begin
    values = [100.0, 110.0, 108.0, 115.0, 120.0, 118.0, 125.0, 130.0]

    @testset "simple_exponential_smoothing" begin
        res = simple_exponential_smoothing(values, 0.3; horizon=3)
        @test length(res.smoothed) == length(values)
        @test length(res.forecast) == 3
        @test all(isfinite, res.smoothed)
        @test_throws ArgumentError simple_exponential_smoothing(values, 0.0)
        @test_throws ArgumentError simple_exponential_smoothing(values, 1.1)
    end

    @testset "holt_double_exponential" begin
        res = holt_double_exponential(values, 0.3, 0.2; horizon=4)
        @test length(res.forecast) == 4
        @test all(isfinite, res.forecast)
        @test_throws ArgumentError holt_double_exponential([1.0], 0.3, 0.2)
    end

    @testset "holt_winters_additive" begin
        seasonal_vals = [
            100.0, 120.0, 110.0, 90.0,
            105.0, 125.0, 115.0, 95.0,
        ]
        res = holt_winters_additive(seasonal_vals, 0.3, 0.1, 0.2, 4; horizon=4)
        @test length(res.forecast) == 4
        @test all(isfinite, res.forecast)
    end

    @testset "weighted_moving_average" begin
        f = weighted_moving_average(values, [1.0, 2.0, 3.0]; horizon=2)
        @test length(f) == 2
        @test f[1] > 0
        @test_throws ArgumentError weighted_moving_average(values, Float64[])
        @test_throws ArgumentError weighted_moving_average([1.0], [1.0, 2.0, 3.0])
    end

    @testset "seasonal_indices" begin
        seasonal_v = [80.0, 100.0, 120.0, 100.0, 80.0, 100.0, 120.0, 100.0]
        si = seasonal_indices(seasonal_v, 4)
        @test length(si) == 4
        @test sum(si) ≈ 4.0 atol=1e-8
    end

    @testset "deseasonalize and reseasonalize" begin
        v = [80.0, 100.0, 120.0, 100.0]
        idx = [0.8, 1.0, 1.2, 1.0]
        ds = deseasonalize(v, idx)
        rs = reseasonalize(ds, idx)
        @test rs ≈ v atol=1e-10
    end

    @testset "budget variance" begin
        @test budget_variance(1100.0, 1000.0) ≈ 100.0
        @test budget_variance_pct(1100.0, 1000.0) ≈ 0.1
        @test flexible_budget_variance(1100.0, 1050.0) ≈ 50.0
        @test_throws ArgumentError budget_variance_pct(1.0, 0.0)
    end

    @testset "accuracy metrics" begin
        actual   = [100.0, 110.0, 120.0]
        forecast = [102.0, 108.0, 118.0]
        @test rmse(actual, forecast) ≈ sqrt(mean([4.0, 4.0, 4.0]))
        @test mape(actual, forecast) < 0.05
        @test forecast_bias(actual, forecast) < 0
        @test_throws ArgumentError mape([0.0, 1.0], [0.0, 1.0])
    end
end
