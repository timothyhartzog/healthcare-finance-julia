module HealthcareFinance

export npv

"""
Compute Net Present Value (NPV)
"""
function npv(rate::Float64, cashflows::Vector{Float64})
    return sum(cf / (1 + rate)^t for (t, cf) in enumerate(cashflows))
end

end
