module EconometricsEngine

using Statistics
using LinearAlgebra

export simple_linear_regression, predict_linear, r_squared, mean_absolute_error,
       multiple_regression, predict_multiple, rmse,
       logistic_regression, logistic_predict, logistic_accuracy,
       difference_in_differences, elasticity,
       coefficient_of_variation, pearson_correlation

"""
Fit a simple linear regression y = a + b*x.
Returns a named tuple with intercept and slope.
"""
function simple_linear_regression(x::AbstractVector{<:Real}, y::AbstractVector{<:Real})
    length(x) == length(y) || throw(ArgumentError("x and y must have same length"))
    length(x) > 1 || throw(ArgumentError("at least two observations are required"))

    x̄ = mean(x)
    ȳ = mean(y)
    numerator = sum((xi - x̄) * (yi - ȳ) for (xi, yi) in zip(x, y))
    denominator = sum((xi - x̄)^2 for xi in x)
    denominator == 0 && throw(ArgumentError("x values must not all be identical"))

    slope = numerator / denominator
    intercept = ȳ - slope * x̄
    return (intercept = intercept, slope = slope)
end

"""
Predict values from a linear model.
"""
function predict_linear(model, x::AbstractVector{<:Real})
    return [model.intercept + model.slope * xi for xi in x]
end

"""
Coefficient of determination.
"""
function r_squared(y_true::AbstractVector{<:Real}, y_pred::AbstractVector{<:Real})
    length(y_true) == length(y_pred) || throw(ArgumentError("vectors must have same length"))
    ȳ = mean(y_true)
    ss_res = sum((yt - yp)^2 for (yt, yp) in zip(y_true, y_pred))
    ss_tot = sum((yt - ȳ)^2 for yt in y_true)
    ss_tot == 0 && throw(ArgumentError("true values must not all be identical"))
    return 1 - ss_res / ss_tot
end

"""
Mean absolute error.
"""
function mean_absolute_error(y_true::AbstractVector{<:Real}, y_pred::AbstractVector{<:Real})
    length(y_true) == length(y_pred) || throw(ArgumentError("vectors must have same length"))
    return mean(abs.(y_true .- y_pred))
end

"""
    rmse(y_true, y_pred)

Root mean squared error.
"""
function rmse(y_true::AbstractVector{<:Real}, y_pred::AbstractVector{<:Real})
    length(y_true) == length(y_pred) || throw(ArgumentError("vectors must have same length"))
    return sqrt(mean((y_true .- y_pred).^2))
end

"""
    pearson_correlation(x, y)

Pearson correlation coefficient between two equal-length vectors.
"""
function pearson_correlation(x::AbstractVector{<:Real}, y::AbstractVector{<:Real})
    length(x) == length(y) || throw(ArgumentError("x and y must have same length"))
    length(x) >= 2 || throw(ArgumentError("at least two observations required"))
    x̄ = mean(x); ȳ = mean(y)
    num = sum((xi - x̄) * (yi - ȳ) for (xi, yi) in zip(x, y))
    den = sqrt(sum((xi - x̄)^2 for xi in x) * sum((yi - ȳ)^2 for yi in y))
    den == 0 && throw(ArgumentError("standard deviation of x or y is zero"))
    return num / den
end

"""
    coefficient_of_variation(values)

Coefficient of variation = std / mean. Useful for comparing dispersion across
cost or utilization distributions.
"""
function coefficient_of_variation(values::AbstractVector{<:Real})
    isempty(values) && throw(ArgumentError("values cannot be empty"))
    μ = mean(values)
    μ == 0 && throw(ArgumentError("mean is zero — CV undefined"))
    return std(values) / μ
end

# ─── Multiple Linear Regression ───────────────────────────────────────────────

"""
    multiple_regression(X, y)

Ordinary least squares multiple regression via the normal equations.

- `X`: n × k design matrix (columns are predictors; include a column of 1s for intercept)
- `y`: n-vector of outcomes

Returns a named tuple with coefficients, fitted values, and R².
"""
function multiple_regression(X::Matrix{<:Real}, y::AbstractVector{<:Real})
    n, k = size(X)
    n == length(y) || throw(ArgumentError("X rows must equal length of y"))
    n > k || throw(ArgumentError("need more observations than predictors"))
    # Normal equations: β = (X'X)⁻¹ X'y
    XtX = X' * X
    det(XtX) ≈ 0 && throw(ArgumentError("X'X is singular — multicollinearity detected"))
    β = XtX \ (X' * y)
    ŷ = X * β
    ȳ = mean(y)
    ss_res = sum((yi - ypi)^2 for (yi, ypi) in zip(y, ŷ))
    ss_tot = sum((yi - ȳ)^2 for yi in y)
    r2 = ss_tot == 0 ? 1.0 : 1 - ss_res / ss_tot
    return (coefficients=β, fitted=ŷ, r_squared=r2, n=n, k=k)
end

"""
    predict_multiple(model, X_new)

Predict outcomes for new observations using a multiple regression model.
"""
function predict_multiple(model, X_new::Matrix{<:Real})
    size(X_new, 2) == length(model.coefficients) ||
        throw(ArgumentError("X_new columns must match number of coefficients"))
    return X_new * model.coefficients
end

# ─── Logistic Regression ──────────────────────────────────────────────────────

"""
    logistic_regression(X, y; learning_rate=0.1, max_iter=1000, tol=1e-6)

Binary logistic regression via gradient descent.

- `X`: n × k design matrix (include intercept column)
- `y`: n-vector of binary outcomes (0 or 1)

Returns a named tuple with coefficients and log-likelihood.

Useful for modeling readmission risk, denial probability, etc.
"""
function logistic_regression(X::Matrix{<:Real}, y::AbstractVector{<:Real};
                              learning_rate::Real=0.1, max_iter::Int=1000,
                              tol::Real=1e-6)
    n, k = size(X)
    n == length(y) || throw(ArgumentError("X rows must equal length of y"))
    all(yi in (0.0, 1.0, 0, 1) for yi in y) ||
        throw(ArgumentError("y must contain only 0 and 1 values"))
    β = zeros(Float64, k)
    σ(z) = 1 / (1 + exp(-z))
    prev_ll = -Inf
    for _ in 1:max_iter
        p  = [σ(dot(X[i, :], β)) for i in 1:n]
        grad = X' * (y .- p) / n
        β  .+= learning_rate .* grad
        ll = sum(y[i] * log(p[i] + 1e-15) + (1 - y[i]) * log(1 - p[i] + 1e-15) for i in 1:n)
        abs(ll - prev_ll) < tol && break
        prev_ll = ll
    end
    return (coefficients=β, log_likelihood=prev_ll)
end

"""
    logistic_predict(model, X_new; threshold=0.5)

Predict class probabilities and labels for new observations.
Returns `(probabilities, labels)`.
"""
function logistic_predict(model, X_new::Matrix{<:Real}; threshold::Real=0.5)
    size(X_new, 2) == length(model.coefficients) ||
        throw(ArgumentError("X_new columns must match number of coefficients"))
    σ(z) = 1 / (1 + exp(-z))
    probs  = [σ(dot(X_new[i, :], model.coefficients)) for i in 1:size(X_new, 1)]
    labels = [p >= threshold ? 1 : 0 for p in probs]
    return (probabilities=probs, labels=labels)
end

"""
    logistic_accuracy(labels_true, labels_pred)

Classification accuracy for logistic regression predictions.
"""
function logistic_accuracy(labels_true::AbstractVector{<:Integer},
                            labels_pred::AbstractVector{<:Integer})
    length(labels_true) == length(labels_pred) ||
        throw(ArgumentError("labels must have same length"))
    return sum(labels_true .== labels_pred) / length(labels_true)
end

# ─── Difference-in-Differences ────────────────────────────────────────────────

"""
    difference_in_differences(pre_treatment, post_treatment, pre_control, post_control)

Classic DiD estimator for policy evaluation.

Common in healthcare economics for:
- Medicaid expansion effects on coverage
- Hospital merger impacts on prices
- Pay-for-performance program evaluation

Returns the DiD estimate (ATT: average treatment effect on the treated).
"""
function difference_in_differences(pre_treatment::Real, post_treatment::Real,
                                    pre_control::Real, post_control::Real)
    treatment_change = post_treatment - pre_treatment
    control_change   = post_control   - pre_control
    return treatment_change - control_change
end

"""
    elasticity(pct_change_quantity, pct_change_price)

Price elasticity of demand. Returns a negative value for normal goods.
Healthcare demand is typically inelastic (|e| < 1).
"""
function elasticity(pct_change_quantity::Real, pct_change_price::Real)
    pct_change_price == 0 && throw(ArgumentError("pct_change_price cannot be zero"))
    return pct_change_quantity / pct_change_price
end

end
