using Test

@testset "Econometrics Engine" begin
    x = [1.0, 2.0, 3.0, 4.0]
    y = [2.0, 4.0, 6.0, 8.0]

    model = simple_linear_regression(x, y)
    @test model.intercept ≈ 0.0
    @test model.slope ≈ 2.0

    y_pred = predict_linear(model, x)
    @test y_pred == y
    @test r_squared(y, y_pred) ≈ 1.0
    @test mean_absolute_error(y, y_pred) ≈ 0.0

    @test_throws ArgumentError simple_linear_regression([1.0], [2.0])
    @test_throws ArgumentError r_squared([1.0, 1.0], [1.0, 1.0])
end
