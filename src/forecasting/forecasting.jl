module Forecasting

using Statistics

export
    # Smoothing methods
    simple_exponential_smoothing, holt_double_exponential, holt_winters_additive,
    # Moving average variants
    weighted_moving_average,
    # Trend & seasonality helpers
    seasonal_indices, deseasonalize, reseasonalize,
    # Budget / variance
    budget_variance, budget_variance_pct, flexible_budget_variance,
    # Accuracy metrics
    rmse, mape, forecast_bias

# ---------------------------------------------------------------------------
# Exponential Smoothing
# ---------------------------------------------------------------------------

"""
Simple Exponential Smoothing (SES).
Returns the smoothed series and a one-step-ahead forecast.
α ∈ (0,1]: smoothing parameter.
"""
function simple_exponential_smoothing(
    values::AbstractVector{<:Real},
    α::Real;
    horizon::Int = 1,
)
    0 < α <= 1 || throw(ArgumentError("α must be in (0, 1]"))
    length(values) >= 1 || throw(ArgumentError("values must not be empty"))
    horizon >= 1 || throw(ArgumentError("horizon must be at least 1"))

    smoothed = similar(values, Float64)
    smoothed[1] = Float64(values[1])
    for i in 2:length(values)
        smoothed[i] = α * values[i] + (1 - α) * smoothed[i-1]
    end
    last_smooth = smoothed[end]
    forecast = fill(last_smooth, horizon)
    return (smoothed = smoothed, forecast = forecast)
end

"""
Holt's Double Exponential Smoothing (trend-adjusted).
α: level smoothing parameter.
β: trend smoothing parameter.
Returns smoothed series with trend component and a multi-step forecast.
"""
function holt_double_exponential(
    values::AbstractVector{<:Real},
    α::Real,
    β::Real;
    horizon::Int = 1,
)
    0 < α <= 1 || throw(ArgumentError("α must be in (0, 1]"))
    0 < β <= 1 || throw(ArgumentError("β must be in (0, 1]"))
    n = length(values)
    n >= 2 || throw(ArgumentError("at least two values are required"))
    horizon >= 1 || throw(ArgumentError("horizon must be at least 1"))

    level = zeros(Float64, n)
    trend = zeros(Float64, n)
    level[1] = Float64(values[1])
    trend[1] = Float64(values[2]) - Float64(values[1])

    for i in 2:n
        prev_level = level[i-1]
        prev_trend = trend[i-1]
        level[i] = α * values[i] + (1 - α) * (prev_level + prev_trend)
        trend[i] = β * (level[i] - prev_level) + (1 - β) * prev_trend
    end

    forecast = [level[end] + h * trend[end] for h in 1:horizon]
    return (level = level, trend = trend, forecast = forecast)
end

"""
Holt-Winters Additive Exponential Smoothing (level + trend + seasonality).
α: level smoothing.
β: trend smoothing.
γ: seasonal smoothing.
season_length: number of periods per season (e.g. 4 for quarterly, 12 for monthly).
"""
function holt_winters_additive(
    values::AbstractVector{<:Real},
    α::Real,
    β::Real,
    γ::Real,
    season_length::Int;
    horizon::Int = season_length,
)
    0 < α <= 1 || throw(ArgumentError("α must be in (0, 1]"))
    0 < β <= 1 || throw(ArgumentError("β must be in (0, 1]"))
    0 < γ <= 1 || throw(ArgumentError("γ must be in (0, 1]"))
    season_length >= 2 || throw(ArgumentError("season_length must be at least 2"))
    n = length(values)
    n >= 2 * season_length || throw(ArgumentError("values must contain at least two full seasons"))
    horizon >= 1 || throw(ArgumentError("horizon must be at least 1"))

    # Initialise
    level = zeros(Float64, n)
    trend = zeros(Float64, n)
    seasonal = zeros(Float64, n + horizon)

    # Season averages for initial seasonal indices
    n_seasons = div(n, season_length)
    season_avgs = [mean(values[(s-1)*season_length+1:s*season_length]) for s in 1:n_seasons]

    level[1] = mean(values[1:season_length])
    trend[1] = (mean(values[season_length+1:2*season_length]) - mean(values[1:season_length])) / season_length
    for i in 1:season_length
        seasonal[i] = Float64(values[i]) / (season_avgs[1] == 0 ? 1.0 : season_avgs[1])
    end

    for i in 2:n
        s_idx = mod1(i, season_length)
        prev_seasonal = seasonal[s_idx]
        prev_level = level[i-1]
        prev_trend = trend[i-1]

        level[i] = α * (values[i] - prev_seasonal) + (1 - α) * (prev_level + prev_trend)
        trend[i] = β * (level[i] - prev_level) + (1 - β) * prev_trend
        seasonal[i] = γ * (values[i] - level[i]) + (1 - γ) * prev_seasonal
    end

    # Fill seasonal indices for forecast horizon
    for h in 1:horizon
        seasonal[n + h] = seasonal[n + h - season_length]
    end

    forecast = [level[end] + h * trend[end] + seasonal[n + h] for h in 1:horizon]
    return (level = level, trend = trend, seasonal = seasonal[1:n], forecast = forecast)
end

# ---------------------------------------------------------------------------
# Weighted moving average
# ---------------------------------------------------------------------------

"""
Weighted moving average forecast.
weights: must have length == window and should be positive (will be normalised).
horizon: number of periods to forecast.
"""
function weighted_moving_average(
    values::AbstractVector{<:Real},
    weights::AbstractVector{<:Real};
    horizon::Int = 1,
)
    window = length(weights)
    window > 0 || throw(ArgumentError("weights must not be empty"))
    length(values) >= window || throw(ArgumentError("values length must be at least window size"))
    horizon >= 1 || throw(ArgumentError("horizon must be at least 1"))
    all(w >= 0 for w in weights) || throw(ArgumentError("weights must be non-negative"))

    total_weight = sum(weights)
    total_weight > 0 || throw(ArgumentError("sum of weights must be positive"))
    norm_weights = weights ./ total_weight

    window_vals = values[end-window+1:end]
    forecast_val = sum(v * w for (v, w) in zip(window_vals, norm_weights))
    return fill(Float64(forecast_val), horizon)
end

# ---------------------------------------------------------------------------
# Seasonal helpers
# ---------------------------------------------------------------------------

"""
Compute multiplicative seasonal indices.
values must contain at least one full season.
season_length: periods per season.
"""
function seasonal_indices(values::AbstractVector{<:Real}, season_length::Int)
    season_length >= 2 || throw(ArgumentError("season_length must be at least 2"))
    n = length(values)
    n >= season_length || throw(ArgumentError("values must cover at least one season"))

    # Use as many complete seasons as available
    n_complete = div(n, season_length) * season_length
    mat = reshape(collect(values[1:n_complete]), season_length, div(n_complete, season_length))
    overall_mean = mean(values[1:n_complete])
    overall_mean == 0 && throw(ArgumentError("mean of values cannot be zero"))

    indices = [mean(mat[s, :]) / overall_mean for s in 1:season_length]
    return indices
end

"""
Remove seasonality by dividing by seasonal indices (multiplicative model).
indices: seasonal index for each position (recycled over full series length).
"""
function deseasonalize(values::AbstractVector{<:Real}, indices::AbstractVector{<:Real})
    isempty(indices) && throw(ArgumentError("indices must not be empty"))
    season_length = length(indices)
    return [v / indices[mod1(i, season_length)] for (i, v) in enumerate(values)]
end

"""
Restore seasonality by multiplying by seasonal indices.
"""
function reseasonalize(values::AbstractVector{<:Real}, indices::AbstractVector{<:Real})
    isempty(indices) && throw(ArgumentError("indices must not be empty"))
    season_length = length(indices)
    return [v * indices[mod1(i, season_length)] for (i, v) in enumerate(values)]
end

# ---------------------------------------------------------------------------
# Budget / variance analysis
# ---------------------------------------------------------------------------

"""
Budget variance = actual - budget.
Positive = over budget (unfavorable for expenses, favorable for revenue).
"""
function budget_variance(actual::Real, budget::Real)
    return actual - budget
end

"""
Budget variance as a percentage of budget.
"""
function budget_variance_pct(actual::Real, budget::Real)
    budget == 0 && throw(ArgumentError("budget cannot be zero"))
    return (actual - budget) / budget
end

"""
Flexible budget variance = actual - flexible_budget.
flexible_budget: budget adjusted to actual volume/activity level.
"""
function flexible_budget_variance(actual::Real, flexible_budget::Real)
    return actual - flexible_budget
end

# ---------------------------------------------------------------------------
# Accuracy metrics
# ---------------------------------------------------------------------------

"""
Root Mean Squared Error.
"""
function rmse(actual::AbstractVector{<:Real}, forecast::AbstractVector{<:Real})
    length(actual) == length(forecast) || throw(ArgumentError("vectors must have same length"))
    return sqrt(mean((a - f)^2 for (a, f) in zip(actual, forecast)))
end

"""
Mean Absolute Percentage Error.
"""
function mape(actual::AbstractVector{<:Real}, forecast::AbstractVector{<:Real})
    length(actual) == length(forecast) || throw(ArgumentError("vectors must have same length"))
    any(a == 0 for a in actual) && throw(ArgumentError("actual values must not contain zeros"))
    return mean(abs((a - f) / a) for (a, f) in zip(actual, forecast))
end

"""
Forecast bias = mean(forecast - actual).
Positive value indicates systematic over-forecasting.
"""
function forecast_bias(actual::AbstractVector{<:Real}, forecast::AbstractVector{<:Real})
    length(actual) == length(forecast) || throw(ArgumentError("vectors must have same length"))
    return mean(f - a for (a, f) in zip(actual, forecast))
end

end # module Forecasting
