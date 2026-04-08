using Test

@testset "Econometrics Engine — extended" begin
    # RMSE
    @test rmse([1.0, 2.0, 3.0], [1.0, 2.0, 3.0]) ≈ 0.0
    @test rmse([1.0, 2.0, 3.0], [2.0, 3.0, 4.0]) ≈ 1.0

    # Pearson correlation
    @test pearson_correlation([1.0,2.0,3.0], [1.0,2.0,3.0]) ≈ 1.0
    @test pearson_correlation([1.0,2.0,3.0], [3.0,2.0,1.0]) ≈ -1.0
    @test_throws ArgumentError pearson_correlation([1.0,2.0], [1.0,2.0,3.0])

    # Coefficient of variation
    @test coefficient_of_variation([100.0, 100.0, 100.0]) ≈ 0.0
    @test_throws ArgumentError coefficient_of_variation([])

    # Multiple regression
    X = [1.0 1.0; 1.0 2.0; 1.0 3.0; 1.0 4.0]
    y = [2.0, 4.0, 6.0, 8.0]
    model = multiple_regression(X, y)
    @test model.r_squared ≈ 1.0  atol=1e-6
    @test model.coefficients[2] ≈ 2.0  atol=1e-6   # slope = 2

    preds = predict_multiple(model, X)
    @test preds ≈ y  atol=1e-6

    # Logistic regression (separable data)
    X_log = [1.0 0.0; 1.0 0.1; 1.0 0.9; 1.0 1.0]
    y_log = [0.0, 0.0, 1.0, 1.0]
    log_model = logistic_regression(X_log, y_log; max_iter=2000)
    @test length(log_model.coefficients) == 2

    preds_log = logistic_predict(log_model, X_log)
    @test length(preds_log.probabilities) == 4
    @test logistic_accuracy(y_log, preds_log.labels) >= 0.5   # at least random

    # DiD estimator
    did = difference_in_differences(80.0, 90.0, 75.0, 78.0)
    @test did ≈ (90-80) - (78-75)  atol=1e-6

    # Elasticity
    @test elasticity(-0.10, 0.05) ≈ -2.0
    @test_throws ArgumentError elasticity(-0.10, 0.0)
end
