module SimulationEngine

using Random
using Statistics

export monte_carlo_mean, simulate_growth

"""
Monte Carlo simulation returning mean of sampled values.
"""
function monte_carlo_mean(dist_sampler::Function, n::Int)
    n > 0 || throw(ArgumentError("n must be positive"))
    samples = [dist_sampler() for _ in 1:n]
    return mean(samples)
end

"""
Simulate compounded growth over time.
"""
function simulate_growth(initial::Real, rate::Real, periods::Int)
    values = Float64[]
    current = initial
    for _ in 1:periods
        current *= (1 + rate)
        push!(values, current)
    end
    return values
end

end
