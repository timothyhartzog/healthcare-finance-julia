module EconometricsEngine

using Statistics

export
    # Simple OLS
    simple_linear_regression, predict_linear, r_squared, mean_absolute_error,
    # Multiple OLS (via normal equations)
    ols_regression, predict_ols,
    # Logistic regression (gradient descent)
    logistic_regression, predict_logistic,
    # Causal inference
    difference_in_differences,
    # Instrumental variables (2SLS)
    two_stage_least_squares,
    # Descriptive / diagnostics
    coefficient_of_variation, vif_simple

# ---------------------------------------------------------------------------
# Simple OLS
# ---------------------------------------------------------------------------

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
Predict values from a simple linear model.
"""
function predict_linear(model, x::AbstractVector{<:Real})
    return [model.intercept + model.slope * xi for xi in x]
end

"""
Coefficient of determination (R²).
"""
function r_squared(y_true::AbstractVector{<:Real}, y_pred::AbstractVector{<:Real})
    length(y_true) == length(y_pred) || throw(ArgumentError("vectors must have same length"))
    ȳ = mean(y_true)
    ss_res = sum((yt - yp)^2 for (yt, yp) in zip(y_true, y_pred))
    ss_tot = sum((yt - ȳ)^2 for yt in y_true)
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

# ---------------------------------------------------------------------------
# Multiple OLS (Normal Equations)
# ---------------------------------------------------------------------------

"""
Fit a multiple linear regression via the normal equations: β = (X'X)⁻¹ X'y.
X: design matrix (n × p), should NOT include a constant column — one is added.
y: response vector (length n).
Returns a named tuple with:
  coefficients: vector of length p+1 (intercept first, then slopes)
"""
function ols_regression(X::AbstractMatrix{<:Real}, y::AbstractVector{<:Real})
    n, p = size(X)
    n == length(y) || throw(ArgumentError("X and y must have the same number of rows"))
    n > p + 1 || throw(ArgumentError("need more observations than parameters"))

    X_aug = hcat(ones(n), X)
    XtX = X_aug' * X_aug
    Xty = X_aug' * y
    coefficients = XtX \ Xty
    return (coefficients = coefficients,)
end

"""
Predict from an OLS model produced by ols_regression.
X: new design matrix (n × p), same column count as training X (no intercept column).
"""
function predict_ols(model, X::AbstractMatrix{<:Real})
    n = size(X, 1)
    X_aug = hcat(ones(n), X)
    return X_aug * model.coefficients
end

# ---------------------------------------------------------------------------
# Logistic regression (binary, gradient descent)
# ---------------------------------------------------------------------------

_sigmoid(z::Real) = 1.0 / (1.0 + exp(-z))

function _dot(a::AbstractVector, b::AbstractVector)
    return sum(ai * bi for (ai, bi) in zip(a, b))
end

"""
Fit a binary logistic regression via gradient descent.
X: design matrix (n × p), intercept added automatically.
y: binary response vector (0 or 1) of length n.
lr: learning rate (default 0.1).
epochs: number of gradient descent iterations (default 1000).
Returns a named tuple with coefficients (length p+1, intercept first).
"""
function logistic_regression(
    X::AbstractMatrix{<:Real},
    y::AbstractVector{<:Real};
    lr::Real = 0.1,
    epochs::Int = 1000,
)
    n, p = size(X)
    n == length(y) || throw(ArgumentError("X and y must have the same number of rows"))
    lr > 0 || throw(ArgumentError("lr must be positive"))
    epochs > 0 || throw(ArgumentError("epochs must be positive"))

    X_aug = hcat(ones(n), X)
    β = zeros(p + 1)

    for _ in 1:epochs
        p_hat = [_sigmoid(_dot(X_aug[i, :], β)) for i in 1:n]
        grad = X_aug' * (p_hat .- y) ./ n
        β .-= lr .* grad
    end
    return (coefficients = β,)
end

"""
Predict probabilities from a logistic regression model.
"""
function predict_logistic(model, X::AbstractMatrix{<:Real})
    n = size(X, 1)
    X_aug = hcat(ones(n), X)
    return [_sigmoid(_dot(X_aug[i, :], model.coefficients)) for i in 1:n]
end

# ---------------------------------------------------------------------------
# Difference-in-Differences
# ---------------------------------------------------------------------------

"""
Difference-in-Differences estimator (2×2 design).
DiD = (post_treat - pre_treat) - (post_control - pre_control)
Returns the average treatment effect on the treated.
"""
function difference_in_differences(
    pre_treat::Real,
    post_treat::Real,
    pre_control::Real,
    post_control::Real,
)
    return (post_treat - pre_treat) - (post_control - pre_control)
end

# ---------------------------------------------------------------------------
# Instrumental Variables (2SLS)
# ---------------------------------------------------------------------------

"""
Two-Stage Least Squares (2SLS) instrumental variables estimator.
x_endog: endogenous regressor vector (length n).
z_instrument: instrument vector (length n).
y: outcome vector (length n).
w_controls: optional exogenous controls matrix (n × k).
Returns (first_stage, second_stage, iv_estimate).
"""
function two_stage_least_squares(
    x_endog::AbstractVector{<:Real},
    z_instrument::AbstractVector{<:Real},
    y::AbstractVector{<:Real};
    w_controls::Union{AbstractMatrix{<:Real}, Nothing} = nothing,
)
    n = length(y)
    n == length(x_endog) == length(z_instrument) ||
        throw(ArgumentError("x_endog, z_instrument, and y must have the same length"))

    if isnothing(w_controls)
        X1 = reshape(z_instrument, n, 1)
    else
        size(w_controls, 1) == n || throw(ArgumentError("w_controls must have n rows"))
        X1 = hcat(reshape(z_instrument, n, 1), w_controls)
    end

    first_stage = ols_regression(X1, x_endog)
    x_hat = predict_ols(first_stage, X1)

    if isnothing(w_controls)
        X2 = reshape(x_hat, n, 1)
    else
        X2 = hcat(reshape(x_hat, n, 1), w_controls)
    end

    second_stage = ols_regression(X2, y)
    iv_estimate = second_stage.coefficients[2]

    return (
        first_stage  = first_stage,
        second_stage = second_stage,
        iv_estimate  = iv_estimate,
    )
end

# ---------------------------------------------------------------------------
# Descriptive / diagnostics
# ---------------------------------------------------------------------------

"""
Coefficient of variation = std(x) / mean(x).
"""
function coefficient_of_variation(x::AbstractVector{<:Real})
    isempty(x) && throw(ArgumentError("x must not be empty"))
    μ = mean(x)
    μ == 0 && throw(ArgumentError("mean cannot be zero"))
    return std(x) / μ
end

"""
Simple pairwise VIF estimate: regress x1 on x2, return 1 / (1 - R²).
"""
function vif_simple(x1::AbstractVector{<:Real}, x2::AbstractVector{<:Real})
    model = simple_linear_regression(x2, x1)
    preds = predict_linear(model, x2)
    r2 = r_squared(x1, preds)
    r2 >= 1 && throw(ArgumentError("perfect collinearity detected"))
    return 1 / (1 - r2)
end

end # module EconometricsEngine
