module ValueBasedCareEngine

export value_score, qalys

function value_score(outcomes::Real, cost::Real)
    cost == 0 && throw(ArgumentError("cost cannot be zero"))
    return outcomes / cost
end

function qalys(years::Real, quality_weight::Real)
    return years * quality_weight
end

end
