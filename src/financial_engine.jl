module FinancialEngine

export npv, irr, mirr, roi, operating_margin, cost_per_patient, break_even_units,
       payback_period, discounted_payback_period,
       drg_revenue, weighted_payer_rate, net_collection_rate,
       wacc, debt_service_coverage_ratio, interest_coverage_ratio,
       profitability_index, modified_duration, lease_vs_buy

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

"""
Internal rate of return via bisection method.
Returns `missing` when no sign change is found within search bounds.
"""
function irr(cashflows::AbstractVector{<:Real};
             lo::Real=-0.999, hi::Real=10.0, tol::Real=1e-10, max_iter::Int=1000)
    length(cashflows) >= 2 || throw(ArgumentError("at least two cashflows required"))
    f(r) = sum(cf / (1 + r)^t for (t, cf) in enumerate(cashflows))
    (f(lo) * f(hi) > 0) && return missing
    for _ in 1:max_iter
        mid = (lo + hi) / 2
        fmid = f(mid)
        abs(fmid) < tol && return mid
        f(lo) * fmid < 0 ? (hi = mid) : (lo = mid)
    end
    return (lo + hi) / 2
end

"""
    mirr(cashflows, finance_rate, reinvestment_rate)

Modified internal rate of return.

Negative cashflows are discounted at `finance_rate`; positive cashflows compounded
at `reinvestment_rate`.
"""
function mirr(cashflows::AbstractVector{<:Real}, finance_rate::Real,
              reinvestment_rate::Real)
    length(cashflows) >= 2 || throw(ArgumentError("at least two cashflows required"))
    n = length(cashflows)
    pv_neg = sum(cf / (1 + finance_rate)^(t-1)
                 for (t, cf) in enumerate(cashflows) if cf < 0; init=0.0)
    fv_pos = sum(cf * (1 + reinvestment_rate)^(n - t)
                 for (t, cf) in enumerate(cashflows) if cf > 0; init=0.0)
    pv_neg == 0 && throw(ArgumentError("no negative cashflows found"))
    fv_pos <= 0 && throw(ArgumentError("no positive cashflows found"))
    return (fv_pos / abs(pv_neg))^(1/(n-1)) - 1
end

"""
    discounted_payback_period(initial_investment, cashflows, discount_rate)

Payback period accounting for time value of money.
Returns `missing` when payback is not achieved within the cashflow horizon.
"""
function discounted_payback_period(initial_investment::Real,
                                    cashflows::AbstractVector{<:Real},
                                    discount_rate::Real)
    remaining = Float64(initial_investment)
    for (t, cf) in enumerate(cashflows)
        dcf = cf / (1 + discount_rate)^t
        if dcf > 0
            if dcf >= remaining
                return (t - 1) + remaining / dcf
            end
            remaining -= dcf
        else
            remaining -= dcf
        end
    end
    return missing
end

"""
    wacc(equity_value, debt_value, cost_of_equity, cost_of_debt, tax_rate=0.0)

Weighted average cost of capital.

For non-profit hospitals, tax_rate = 0 and equity is replaced by net assets.
"""
function wacc(equity_value::Real, debt_value::Real, cost_of_equity::Real,
              cost_of_debt::Real, tax_rate::Real=0.0)
    total = equity_value + debt_value
    total > 0 || throw(ArgumentError("equity_value + debt_value must be positive"))
    0 <= tax_rate < 1 || throw(ArgumentError("tax_rate must be in [0,1)"))
    w_e = equity_value / total
    w_d = debt_value   / total
    return w_e * cost_of_equity + w_d * cost_of_debt * (1 - tax_rate)
end

"""
    debt_service_coverage_ratio(net_income, depreciation_amortization, debt_service)

DSCR = (net income + D&A) / total debt service.
Lender covenant benchmark ≥ 1.25; rating agency benchmark ≥ 2.0.
"""
function debt_service_coverage_ratio(net_income::Real, depreciation_amortization::Real,
                                      debt_service::Real)
    debt_service > 0 || throw(ArgumentError("debt_service must be positive"))
    return (net_income + depreciation_amortization) / debt_service
end

"""
    interest_coverage_ratio(ebit, interest_expense)

Times interest earned = EBIT / interest expense.
"""
function interest_coverage_ratio(ebit::Real, interest_expense::Real)
    interest_expense == 0 && throw(ArgumentError("interest_expense cannot be zero"))
    return ebit / interest_expense
end

"""
    profitability_index(npv_value, initial_investment)

Profitability index = (NPV + initial_investment) / initial_investment.
PI > 1 indicates value creation.
"""
function profitability_index(npv_value::Real, initial_investment::Real)
    initial_investment > 0 || throw(ArgumentError("initial_investment must be positive"))
    return (npv_value + initial_investment) / initial_investment
end

"""
    modified_duration(cashflows, yield)

Macaulay duration divided by (1 + yield) — measures price sensitivity to yield.
Useful for analyzing tax-exempt hospital revenue bonds.
"""
function modified_duration(cashflows::AbstractVector{<:Real}, yield::Real)
    isempty(cashflows) && throw(ArgumentError("cashflows cannot be empty"))
    yield > -1 || throw(ArgumentError("yield must be > -1"))
    price = sum(cf / (1 + yield)^t for (t, cf) in enumerate(cashflows))
    price == 0 && throw(ArgumentError("present value of cashflows is zero"))
    macaulay = sum(t * cf / (1 + yield)^t for (t, cf) in enumerate(cashflows)) / price
    return macaulay / (1 + yield)
end

"""
    lease_vs_buy(asset_cost, lease_payments, salvage_value, discount_rate, useful_life;
                 tax_rate=0.0)

Present value comparison of leasing vs. buying an asset.

Returns `(buy_pv, lease_pv, preferred)` where `preferred` is `:buy` or `:lease`.

- `lease_payments`: vector of periodic lease payments
- `salvage_value`: residual asset value at end of useful life (buy scenario)
- `tax_rate`: marginal tax rate (0.0 for non-profits)
"""
function lease_vs_buy(asset_cost::Real, lease_payments::AbstractVector{<:Real},
                      salvage_value::Real, discount_rate::Real, useful_life::Integer;
                      tax_rate::Real=0.0)
    asset_cost > 0 || throw(ArgumentError("asset_cost must be positive"))
    discount_rate > 0 || throw(ArgumentError("discount_rate must be positive"))
    pv_salvage = salvage_value / (1 + discount_rate)^useful_life
    buy_pv = asset_cost - pv_salvage
    lease_pv = sum(pmt * (1 - tax_rate) / (1 + discount_rate)^t
                   for (t, pmt) in enumerate(lease_payments))
    preferred = lease_pv <= buy_pv ? :lease : :buy
    return (buy_pv=buy_pv, lease_pv=lease_pv, preferred=preferred)
end

end
