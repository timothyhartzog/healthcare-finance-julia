module Accounting

using Statistics

export
    # Liquidity ratios
    current_ratio, quick_ratio, cash_ratio,
    # Leverage / solvency ratios
    debt_to_equity, debt_to_assets, equity_multiplier, interest_coverage,
    # Profitability ratios
    gross_profit_margin, net_profit_margin, return_on_assets, return_on_equity,
    ebitda, ebitda_margin,
    # Efficiency / activity ratios
    asset_turnover, days_in_accounts_receivable, days_in_accounts_payable,
    inventory_turnover,
    # Hospital-specific ratios
    occupancy_rate, average_length_of_stay, cost_per_discharge,
    revenue_per_adjusted_patient_day,
    # Cost accounting
    overhead_rate, full_absorption_cost, contribution_margin_ratio,
    activity_based_cost,
    # Financial statement helpers
    gross_profit, operating_income, net_income,
    free_cash_flow

# ---------------------------------------------------------------------------
# Liquidity
# ---------------------------------------------------------------------------

"""
Current ratio = current assets / current liabilities.
Measures short-term liquidity.
"""
function current_ratio(current_assets::Real, current_liabilities::Real)
    current_liabilities == 0 && throw(ArgumentError("current_liabilities cannot be zero"))
    return current_assets / current_liabilities
end

"""
Quick ratio = (current assets - inventory) / current liabilities.
More conservative liquidity measure that excludes inventory.
"""
function quick_ratio(current_assets::Real, inventory::Real, current_liabilities::Real)
    current_liabilities == 0 && throw(ArgumentError("current_liabilities cannot be zero"))
    return (current_assets - inventory) / current_liabilities
end

"""
Cash ratio = cash / current liabilities.
Most conservative short-term liquidity measure.
"""
function cash_ratio(cash::Real, current_liabilities::Real)
    current_liabilities == 0 && throw(ArgumentError("current_liabilities cannot be zero"))
    return cash / current_liabilities
end

# ---------------------------------------------------------------------------
# Leverage / solvency
# ---------------------------------------------------------------------------

"""
Debt-to-equity = total debt / total equity.
"""
function debt_to_equity(total_debt::Real, total_equity::Real)
    total_equity == 0 && throw(ArgumentError("total_equity cannot be zero"))
    return total_debt / total_equity
end

"""
Debt-to-assets = total debt / total assets.
"""
function debt_to_assets(total_debt::Real, total_assets::Real)
    total_assets == 0 && throw(ArgumentError("total_assets cannot be zero"))
    return total_debt / total_assets
end

"""
Equity multiplier = total assets / total equity.
Used in DuPont analysis.
"""
function equity_multiplier(total_assets::Real, total_equity::Real)
    total_equity == 0 && throw(ArgumentError("total_equity cannot be zero"))
    return total_assets / total_equity
end

"""
Interest coverage ratio = EBIT / interest_expense.
Measures ability to service debt.
"""
function interest_coverage(ebit::Real, interest_expense::Real)
    interest_expense == 0 && throw(ArgumentError("interest_expense cannot be zero"))
    return ebit / interest_expense
end

# ---------------------------------------------------------------------------
# Profitability
# ---------------------------------------------------------------------------

"""
Gross profit = revenue - cost_of_goods_sold.
"""
function gross_profit(revenue::Real, cogs::Real)
    return revenue - cogs
end

"""
Gross profit margin = gross_profit / revenue.
"""
function gross_profit_margin(revenue::Real, cogs::Real)
    revenue == 0 && throw(ArgumentError("revenue cannot be zero"))
    return gross_profit(revenue, cogs) / revenue
end

"""
Operating income = revenue - operating_expenses.
"""
function operating_income(revenue::Real, operating_expenses::Real)
    return revenue - operating_expenses
end

"""
Net income = revenue - total_expenses.
"""
function net_income(revenue::Real, total_expenses::Real)
    return revenue - total_expenses
end

"""
Net profit margin = net_income / revenue.
"""
function net_profit_margin(revenue::Real, total_expenses::Real)
    revenue == 0 && throw(ArgumentError("revenue cannot be zero"))
    return net_income(revenue, total_expenses) / revenue
end

"""
Return on assets = net_income / average_total_assets.
"""
function return_on_assets(net_income_val::Real, average_total_assets::Real)
    average_total_assets == 0 && throw(ArgumentError("average_total_assets cannot be zero"))
    return net_income_val / average_total_assets
end

"""
Return on equity = net_income / average_equity.
"""
function return_on_equity(net_income_val::Real, average_equity::Real)
    average_equity == 0 && throw(ArgumentError("average_equity cannot be zero"))
    return net_income_val / average_equity
end

"""
EBITDA = operating_income + depreciation + amortization.
"""
function ebitda(operating_income_val::Real, depreciation::Real, amortization::Real)
    return operating_income_val + depreciation + amortization
end

"""
EBITDA margin = ebitda / revenue.
"""
function ebitda_margin(ebitda_val::Real, revenue::Real)
    revenue == 0 && throw(ArgumentError("revenue cannot be zero"))
    return ebitda_val / revenue
end

# ---------------------------------------------------------------------------
# Efficiency / activity
# ---------------------------------------------------------------------------

"""
Asset turnover = revenue / average_total_assets.
"""
function asset_turnover(revenue::Real, average_total_assets::Real)
    average_total_assets == 0 && throw(ArgumentError("average_total_assets cannot be zero"))
    return revenue / average_total_assets
end

"""
Days in accounts receivable (DAR) = (net_accounts_receivable / net_patient_revenue) * days_in_period.
Standard healthcare A/R efficiency measure.
"""
function days_in_accounts_receivable(net_ar::Real, net_patient_revenue::Real; days_in_period::Int = 365)
    net_patient_revenue == 0 && throw(ArgumentError("net_patient_revenue cannot be zero"))
    return (net_ar / net_patient_revenue) * days_in_period
end

"""
Days in accounts payable = (accounts_payable / total_purchases) * days_in_period.
"""
function days_in_accounts_payable(accounts_payable::Real, total_purchases::Real; days_in_period::Int = 365)
    total_purchases == 0 && throw(ArgumentError("total_purchases cannot be zero"))
    return (accounts_payable / total_purchases) * days_in_period
end

"""
Inventory turnover = cost_of_goods_sold / average_inventory.
"""
function inventory_turnover(cogs::Real, average_inventory::Real)
    average_inventory == 0 && throw(ArgumentError("average_inventory cannot be zero"))
    return cogs / average_inventory
end

# ---------------------------------------------------------------------------
# Hospital-specific
# ---------------------------------------------------------------------------

"""
Occupancy rate = patient_days / (beds * days_in_period).
"""
function occupancy_rate(patient_days::Real, beds::Real; days_in_period::Int = 365)
    beds == 0 && throw(ArgumentError("beds cannot be zero"))
    return patient_days / (beds * days_in_period)
end

"""
Average length of stay (ALOS) = total_patient_days / total_discharges.
"""
function average_length_of_stay(total_patient_days::Real, total_discharges::Real)
    total_discharges == 0 && throw(ArgumentError("total_discharges cannot be zero"))
    return total_patient_days / total_discharges
end

"""
Cost per discharge = total_operating_expenses / total_discharges.
"""
function cost_per_discharge(total_operating_expenses::Real, total_discharges::Real)
    total_discharges == 0 && throw(ArgumentError("total_discharges cannot be zero"))
    return total_operating_expenses / total_discharges
end

"""
Revenue per adjusted patient day = net_patient_revenue / adjusted_patient_days.
"""
function revenue_per_adjusted_patient_day(net_patient_revenue::Real, adjusted_patient_days::Real)
    adjusted_patient_days == 0 && throw(ArgumentError("adjusted_patient_days cannot be zero"))
    return net_patient_revenue / adjusted_patient_days
end

# ---------------------------------------------------------------------------
# Cost accounting
# ---------------------------------------------------------------------------

"""
Overhead rate = total_overhead / allocation_base.
The allocation_base can be direct labor hours, machine hours, etc.
"""
function overhead_rate(total_overhead::Real, allocation_base::Real)
    allocation_base == 0 && throw(ArgumentError("allocation_base cannot be zero"))
    return total_overhead / allocation_base
end

"""
Full absorption (total) cost = direct_material + direct_labor + applied_overhead.
"""
function full_absorption_cost(direct_material::Real, direct_labor::Real, applied_overhead::Real)
    return direct_material + direct_labor + applied_overhead
end

"""
Contribution margin ratio = (revenue - variable_costs) / revenue.
"""
function contribution_margin_ratio(revenue::Real, variable_costs::Real)
    revenue == 0 && throw(ArgumentError("revenue cannot be zero"))
    return (revenue - variable_costs) / revenue
end

"""
Activity-based cost per unit = sum of (activity_rate[i] * activity_usage[i]) / units.
activity_rates and activity_usages are paired vectors of cost-driver rates and volumes.
"""
function activity_based_cost(
    activity_rates::AbstractVector{<:Real},
    activity_usages::AbstractVector{<:Real},
    units::Real,
)
    length(activity_rates) == length(activity_usages) ||
        throw(ArgumentError("activity_rates and activity_usages must have same length"))
    units <= 0 && throw(ArgumentError("units must be positive"))
    total = sum(r * u for (r, u) in zip(activity_rates, activity_usages))
    return total / units
end

# ---------------------------------------------------------------------------
# Free cash flow
# ---------------------------------------------------------------------------

"""
Free cash flow = operating_cash_flow - capital_expenditures.
"""
function free_cash_flow(operating_cash_flow::Real, capital_expenditures::Real)
    return operating_cash_flow - capital_expenditures
end

end # module Accounting
