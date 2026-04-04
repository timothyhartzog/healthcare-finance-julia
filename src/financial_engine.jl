module FinancialEngine

export npv, roi, operating_margin, cost_per_patient, break_even_units, payback_period,
       drg_revenue, weighted_payer_rate, net_collection_rate

"""
Compute net present value using period-indexed cashflows.
The first cashflow is discounted one period.
"""
function npv(rate::Real, cashflows::AbstractVector{<:Real})
    return sum(cf / (1 + rate)^t for (t, cf) in enumerate(cashflows))
end

"""
Return on investment.
"""
function roi(gain::Real, cost::Real)
    cost == 0 && throw(ArgumentError("cost cannot be zero"))
    return (gain - cost) / cost
end

"""
Operating margin = (operating revenue - operating expense) / operating revenue
"""
function operating_margin(revenue::Real, expense::Real)
    revenue == 0 && throw(ArgumentError("revenue cannot be zero"))
    return (revenue - expense) / revenue
end

"""
Cost per patient encounter.
"""
function cost_per_patient(total_cost::Real, encounters::Real)
    encounters == 0 && throw(ArgumentError("encounters cannot be zero"))
    return total_cost / encounters
end

"""
Break-even volume in units.
"""
function break_even_units(fixed_cost::Real, unit_price::Real, unit_variable_cost::Real)
    contribution_margin = unit_price - unit_variable_cost
    contribution_margin <= 0 && throw(ArgumentError("unit price must exceed variable cost"))
    return fixed_cost / contribution_margin
end

"""
Payback period in whole and partial periods.
Returns missing when payback is not achieved.
"""
function payback_period(initial_investment::Real, cashflows::AbstractVector{<:Real})
    remaining = initial_investment
    for (i, cf) in enumerate(cashflows)
        if cf <= 0
            remaining -= cf
            continue
        end
        if cf >= remaining
            fraction = remaining / cf
            return (i - 1) + fraction
        end
        remaining -= cf
    end
    return missing
end

"""
Simple DRG revenue estimate.
"""
function drg_revenue(base_rate::Real, weight::Real, cases::Integer)
    return base_rate * weight * cases
end

"""
Weighted average payer rate from rates and payer shares.
Shares should sum near 1.0.
"""
function weighted_payer_rate(rates::AbstractVector{<:Real}, shares::AbstractVector{<:Real})
    length(rates) == length(shares) || throw(ArgumentError("rates and shares must have same length"))
    return sum(r * s for (r, s) in zip(rates, shares))
end

"""
Net collection rate = payments / (charges - contractual_adjustments)
"""
function net_collection_rate(payments::Real, charges::Real, contractual_adjustments::Real)
    denominator = charges - contractual_adjustments
    denominator == 0 && throw(ArgumentError("charges minus contractual adjustments cannot be zero"))
    return payments / denominator
end

end
