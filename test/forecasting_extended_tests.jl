using Test

@testset "Forecasting Models — extended" begin
    # Exponential smoothing
    vals = [100.0, 110.0, 105.0, 115.0, 120.0]
    sm = exponential_smoothing(vals; alpha=0.3)
    @test length(sm) == 5
    @test sm[1] ≈ 100.0

    # Holt-Winters additive
    # Create 3 full seasons of quarterly data (12 obs) plus some extra
    seasonal_data = [100.0, 110.0, 120.0, 105.0,
                     105.0, 115.0, 125.0, 110.0,
                     110.0, 120.0, 130.0, 115.0]
    hw_fc = holt_winters_additive(seasonal_data, 4, 4; alpha=0.2, beta=0.1, gamma=0.3)
    @test length(hw_fc) == 4

    # Holt-Winters multiplicative
    hw_mult = holt_winters_multiplicative(seasonal_data, 4, 4; alpha=0.2, beta=0.1, gamma=0.3)
    @test length(hw_mult) == 4

    # MAPE
    actual = [100.0, 200.0, 300.0]
    forecast = [110.0, 190.0, 310.0]
    @test forecast_mape(actual, forecast) > 0
    @test_throws ArgumentError forecast_mape([0.0, 1.0], [0.0, 1.0])

    # RMSE
    @test forecast_rmse(actual, forecast) > 0
    @test forecast_rmse(actual, actual) ≈ 0.0

    # Seasonal decompose
    long_data = repeat([100.0, 120.0, 90.0, 110.0], 4)   # 2 full seasons + padding
    decomp = seasonal_decompose(long_data, 4)
    @test length(decomp.trend) == 16
    @test length(decomp.seasonal) == 16
    @test length(decomp.residual) == 16

    # forecast_series dispatch
    @test length(forecast_series(vals; method=:exponential_smoothing, horizon=3)) == 3
    @test length(forecast_series(seasonal_data; method=:holt_winters_additive,
                                  horizon=4, season=4)) == 4
    @test_throws ArgumentError forecast_series(vals; method=:unknown)
end
