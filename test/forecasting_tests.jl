using Test

@testset "Forecasting Models" begin
    values = [10.0, 20.0, 30.0, 40.0]

    @test moving_average_forecast(values, 2, 3) == [35.0, 35.0, 35.0]
    @test linear_trend_forecast([10.0, 20.0, 30.0], 2) == [40.0, 50.0]
    @test forecast_series(values; method=:moving_average, window=2, horizon=2) == [35.0, 35.0]
    @test forecast_series([10.0, 20.0, 30.0]; method=:linear_trend, horizon=2) == [40.0, 50.0]

    @test_throws ArgumentError moving_average_forecast(values, 0, 2)
    @test_throws ArgumentError linear_trend_forecast([1.0], 2)
    @test_throws ArgumentError forecast_series(values; method=:unknown)
end
