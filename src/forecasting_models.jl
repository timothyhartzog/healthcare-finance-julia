module ForecastingModels

using Statistics

export moving_average_forecast, linear_trend_forecast, forecast_series,
       holt_winters_additive, holt_winters_multiplicative,
       forecast_mape, forecast_rmse, seasonal_decompose,
       exponential_smoothing

function moving_average_forecast(values::AbstractVector{<:Real}, window::Int, horizon::Int)
    window > 0 || throw(ArgumentError("window must be positive"))
    horizon > 0 || throw(ArgumentError("horizon must be positive"))
    length(values) >= window || throw(ArgumentError("values length must be at least window"))
    avg = mean(values[end-window+1:end])
    return fill(Float64(avg), horizon)
end

function linear_trend_forecast(values::AbstractVector{<:Real}, horizon::Int)
    horizon > 0 || throw(ArgumentError("horizon must be positive"))
    n = length(values)
    n >= 2 || throw(ArgumentError("at least two values are required"))

    x = collect(1:n)
    xbar = mean(x)
    ybar = mean(values)
    numerator = sum((xi - xbar) * (yi - ybar) for (xi, yi) in zip(x, values))
    denominator = sum((xi - xbar)^2 for xi in x)
    denominator == 0 && throw(ArgumentError("cannot fit trend"))

    slope = numerator / denominator
    intercept = ybar - slope * xbar
    return [intercept + slope * t for t in (n+1):(n+horizon)]
end

function forecast_series(values::AbstractVector{<:Real}; method::Symbol = :moving_average,
                          window::Int = 3, horizon::Int = 3,
                          alpha::Real=0.3, beta::Real=0.1, gamma::Real=0.2, season::Int=4)
    if method == :moving_average
        return moving_average_forecast(values, window, horizon)
    elseif method == :linear_trend
        return linear_trend_forecast(values, horizon)
    elseif method == :exponential_smoothing
        fitted = exponential_smoothing(values; alpha=alpha)
        last_smoothed = fitted[end]
        return fill(last_smoothed, horizon)
    elseif method == :holt_winters_additive
        return holt_winters_additive(values, season, horizon; alpha=alpha, beta=beta, gamma=gamma)
    else
        throw(ArgumentError("unsupported forecasting method: $method"))
    end
end

"""
    exponential_smoothing(values; alpha=0.3)

Simple exponential smoothing (SES). Returns fitted values.
`alpha` is the smoothing parameter (0 < alpha < 1).
"""
function exponential_smoothing(values::AbstractVector{<:Real}; alpha::Real=0.3)
    0 < alpha < 1 || throw(ArgumentError("alpha must be in (0,1)"))
    length(values) >= 1 || throw(ArgumentError("values cannot be empty"))
    smoothed = zeros(Float64, length(values))
    smoothed[1] = values[1]
    for t in 2:length(values)
        smoothed[t] = alpha * values[t] + (1 - alpha) * smoothed[t-1]
    end
    return smoothed
end

"""
    holt_winters_additive(values, season_length, horizon; alpha=0.2, beta=0.1, gamma=0.2)

Holt-Winters additive triple exponential smoothing for seasonal series.

- `season_length`: number of periods in a seasonal cycle (e.g., 4 for quarterly, 12 for monthly)
- `alpha`: level smoothing parameter
- `beta`: trend smoothing parameter
- `gamma`: seasonal smoothing parameter

Returns vector of `horizon` forecasts.

Healthcare use cases: seasonal ED volume, flu admission patterns, revenue cycles.
"""
function holt_winters_additive(values::AbstractVector{<:Real}, season_length::Integer,
                                horizon::Integer;
                                alpha::Real=0.2, beta::Real=0.1, gamma::Real=0.2)
    0 < alpha < 1 || throw(ArgumentError("alpha must be in (0,1)"))
    0 < beta  < 1 || throw(ArgumentError("beta must be in (0,1)"))
    0 < gamma < 1 || throw(ArgumentError("gamma must be in (0,1)"))
    n = length(values)
    n >= 2 * season_length || throw(ArgumentError("need at least 2 full seasons"))
    horizon > 0 || throw(ArgumentError("horizon must be positive"))

    # Initialise level, trend, and seasonal components
    L = mean(values[1:season_length])
    b = (mean(values[season_length+1:2*season_length]) - mean(values[1:season_length])) / season_length
    S = [values[i] - L for i in 1:season_length]

    levels = Float64[L]
    trends = Float64[b]
    seasonal = copy(S)

    for t in (season_length+1):n
        s_prev = seasonal[mod1(t - season_length, season_length)]
        L_new  = alpha * (values[t] - s_prev) + (1 - alpha) * (levels[end] + trends[end])
        b_new  = beta  * (L_new - levels[end]) + (1 - beta)  * trends[end]
        s_new  = gamma * (values[t] - L_new)   + (1 - gamma) * s_prev
        push!(levels, L_new)
        push!(trends, b_new)
        push!(seasonal, s_new)
    end

    L_final = levels[end]
    b_final = trends[end]
    return [L_final + h * b_final + seasonal[mod1(n + h, season_length)]
            for h in 1:horizon]
end

"""
    holt_winters_multiplicative(values, season_length, horizon; alpha=0.2, beta=0.1, gamma=0.2)

Holt-Winters multiplicative triple exponential smoothing.
Use when seasonal fluctuations scale proportionally with level.
"""
function holt_winters_multiplicative(values::AbstractVector{<:Real}, season_length::Integer,
                                      horizon::Integer;
                                      alpha::Real=0.2, beta::Real=0.1, gamma::Real=0.2)
    0 < alpha < 1 || throw(ArgumentError("alpha must be in (0,1)"))
    0 < beta  < 1 || throw(ArgumentError("beta must be in (0,1)"))
    0 < gamma < 1 || throw(ArgumentError("gamma must be in (0,1)"))
    n = length(values)
    n >= 2 * season_length || throw(ArgumentError("need at least 2 full seasons"))
    horizon > 0 || throw(ArgumentError("horizon must be positive"))

    L = mean(values[1:season_length])
    b = (mean(values[season_length+1:2*season_length]) - mean(values[1:season_length])) / season_length
    S = [values[i] / L for i in 1:season_length]

    levels = Float64[L]
    trends = Float64[b]
    seasonal = copy(S)

    for t in (season_length+1):n
        s_prev = seasonal[mod1(t - season_length, season_length)]
        L_new  = alpha * (values[t] / s_prev) + (1 - alpha) * (levels[end] + trends[end])
        b_new  = beta  * (L_new - levels[end]) + (1 - beta)  * trends[end]
        s_new  = gamma * (values[t] / L_new)   + (1 - gamma) * s_prev
        push!(levels, L_new)
        push!(trends, b_new)
        push!(seasonal, s_new)
    end

    L_final = levels[end]
    b_final = trends[end]
    return [( L_final + h * b_final) * seasonal[mod1(n + h, season_length)]
            for h in 1:horizon]
end

"""
    forecast_mape(actual, forecast)

Mean absolute percentage error. Standard forecast accuracy metric.
"""
function forecast_mape(actual::AbstractVector{<:Real}, forecast::AbstractVector{<:Real})
    length(actual) == length(forecast) ||
        throw(ArgumentError("actual and forecast must have same length"))
    any(a == 0 for a in actual) && throw(ArgumentError("actual values cannot contain zeros"))
    return mean(abs.((actual .- forecast) ./ actual)) * 100
end

"""
    forecast_rmse(actual, forecast)

Root mean squared error for forecast evaluation.
"""
function forecast_rmse(actual::AbstractVector{<:Real}, forecast::AbstractVector{<:Real})
    length(actual) == length(forecast) ||
        throw(ArgumentError("actual and forecast must have same length"))
    return sqrt(mean((actual .- forecast).^2))
end

"""
    seasonal_decompose(values, season_length)

Additive decomposition into trend, seasonal, and residual components.

Returns a named tuple: (trend, seasonal, residual).
"""
function seasonal_decompose(values::AbstractVector{<:Real}, season_length::Integer)
    n = length(values)
    n >= 2 * season_length || throw(ArgumentError("need at least 2 full seasons"))
    season_length > 0 || throw(ArgumentError("season_length must be positive"))

    # Centered moving average for trend (odd window = season_length, even uses 2×MA)
    half = season_length ÷ 2
    trend = fill(NaN, n)
    for i in (half+1):(n-half)
        trend[i] = mean(values[i-half:i+half])
    end

    # Detrend
    detrended = values .- trend

    # Average seasonal indices
    seasonal_indices = zeros(Float64, season_length)
    counts = zeros(Int, season_length)
    for i in 1:n
        if !isnan(detrended[i])
            s = mod1(i, season_length)
            seasonal_indices[s] += detrended[i]
            counts[s] += 1
        end
    end
    for s in 1:season_length
        counts[s] > 0 && (seasonal_indices[s] /= counts[s])
    end
    # Normalise so seasonal indices sum to zero
    adj = mean(seasonal_indices)
    seasonal_indices .-= adj

    seasonal = [seasonal_indices[mod1(i, season_length)] for i in 1:n]
    residual = values .- trend .- seasonal
    return (trend=trend, seasonal=seasonal, residual=residual)
end

end
