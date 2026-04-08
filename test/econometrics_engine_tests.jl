include("../src/econometrics_engine.jl")
using .EconometricsEngine
using Test

@testset "EconometricsEngine" begin
    @testset "simple_linear_regression" begin
        x = [1.0, 2.0, 3.0, 4.0, 5.0]
        y = [2.0, 4.0, 6.0, 8.0, 10.0]
        m = simple_linear_regression(x, y)
        @test m.slope ≈ 2.0
        @test m.intercept ≈ 0.0 atol=1e-10
        preds = predict_linear(m, x)
        @test r_squared(y, preds) ≈ 1.0 atol=1e-10
        @test mean_absolute_error(y, preds) ≈ 0.0 atol=1e-10
    end

    @testset "simple_linear_regression errors" begin
        @test_throws ArgumentError simple_linear_regression([1.0], [1.0])
        @test_throws ArgumentError simple_linear_regression([1.0, 2.0], [1.0])
        @test_throws ArgumentError simple_linear_regression([1.0, 1.0], [1.0, 2.0])
    end

    @testset "ols_regression" begin
        X = hcat([1.0, 2.0, 3.0, 4.0, 5.0], [2.0, 0.5, 3.0, 1.5, 4.0])
        y = 3.0 .+ 2.0 .* X[:, 1] .- 1.0 .* X[:, 2]
        model = ols_regression(X, y)
        preds = predict_ols(model, X)
        @test r_squared(y, preds) ≈ 1.0 atol=1e-8
    end

    @testset "logistic_regression" begin
        X = hcat([1.0, 2.0, 3.0, 4.0, 5.0])
        y = [0.0, 0.0, 1.0, 1.0, 1.0]
        model = logistic_regression(X, y; lr=0.5, epochs=2000)
        probs = predict_logistic(model, X)
        @test all(0 .<= probs .<= 1)
        @test probs[end] > probs[1]
    end

    @testset "difference_in_differences" begin
        did = difference_in_differences(10.0, 15.0, 10.0, 12.0)
        @test did ≈ 3.0
    end

    @testset "two_stage_least_squares" begin
        n = 50
        z = collect(1.0:n)
        x = 0.5 .* z .+ randn(n) .* 0.1
        y = 2.0 .* x .+ randn(n) .* 0.1
        result = two_stage_least_squares(x, z, y)
        @test isfinite(result.iv_estimate)
        @test result.iv_estimate ≈ 2.0 atol=0.5
    end

    @testset "coefficient_of_variation" begin
        @test coefficient_of_variation([1.0, 2.0, 3.0]) > 0
        @test_throws ArgumentError coefficient_of_variation(Float64[])
    end

    @testset "vif_simple" begin
        x1 = [1.0, 2.0, 3.0, 4.0, 5.0]
        x2 = x1 .+ randn(5) .* 0.1
        @test vif_simple(x1, x2) > 1
    end
end
