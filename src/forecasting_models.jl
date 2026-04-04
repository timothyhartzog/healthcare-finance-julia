module ForecastingModels

using Statistics

export moving_average_forecast, linear_trend_forecast, forecast_series

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

function forecast_series(values::AbstractVector{<:Real}; method::Symbol = :moving_average, window::Int = 3, horizon::Int = 3)
    if method == :moving_average
        return moving_average_forecast(values, window, horizon)
    elseif method == :linear_trend
        return linear_trend_forecast(values, horizon)
    else
        throw(ArgumentError("unsupported forecasting method"))
    end
end

end
