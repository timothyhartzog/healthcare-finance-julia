module EconometricsEngine

using Statistics

export simple_linear_regression, predict_linear, r_squared, mean_absolute_error

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

end
