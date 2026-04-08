module AccountingEngine

using Statistics

export income_statement, balance_sheet_ratios, cash_flow_indirect,
       current_ratio, quick_ratio, debt_to_equity, equity_multiplier,
       days_cash_on_hand, long_term_debt_to_capitalization,
       straight_line_depreciation, macrs_depreciation_schedule,
       charitable_community_benefit_rate, net_assets_change,
       fund_accounting_summary, operating_leverage,
       ebitda, ebitda_margin, total_margin, operating_margin_hfma

# ─── Income Statement ─────────────────────────────────────────────────────────

"""
    income_statement(gross_revenue, contractual_adjustments, bad_debt,
                     charity_care, operating_expenses; other_income=0.0)

Construct a simplified hospital income statement.

Returns a named tuple with all key line items and margins.

Per HFMA reporting conventions:
- Net patient revenue = gross - contractual adjustments - bad debt - charity
- Total operating revenue = net patient revenue + other income
- Operating income = total operating revenue - operating expenses
"""
function income_statement(gross_revenue::Real, contractual_adjustments::Real,
                          bad_debt::Real, charity_care::Real,
                          operating_expenses::Real; other_income::Real=0.0)
    gross_revenue > 0 || throw(ArgumentError("gross_revenue must be positive"))
    net_patient_revenue = gross_revenue - contractual_adjustments - bad_debt - charity_care
    total_operating_revenue = net_patient_revenue + other_income
    operating_income = total_operating_revenue - operating_expenses
    total_margin_val = total_operating_revenue > 0 ?
                       operating_income / total_operating_revenue : 0.0
    return (
        gross_revenue             = Float64(gross_revenue),
        contractual_adjustments   = Float64(contractual_adjustments),
        bad_debt                  = Float64(bad_debt),
        charity_care              = Float64(charity_care),
        net_patient_revenue       = Float64(net_patient_revenue),
        other_income              = Float64(other_income),
        total_operating_revenue   = Float64(total_operating_revenue),
        operating_expenses        = Float64(operating_expenses),
        operating_income          = Float64(operating_income),
        total_margin              = Float64(total_margin_val),
    )
end

"""
    ebitda(operating_income, depreciation, amortization)

Earnings before interest, taxes, depreciation, and amortization.
Key credit metric used by rating agencies for healthcare.
"""
function ebitda(operating_income::Real, depreciation::Real, amortization::Real=0.0)
    return operating_income + depreciation + amortization
end

"""
    ebitda_margin(ebitda_val, total_operating_revenue)

EBITDA as a fraction of total operating revenue.
"""
function ebitda_margin(ebitda_val::Real, total_operating_revenue::Real)
    total_operating_revenue > 0 ||
        throw(ArgumentError("total_operating_revenue must be positive"))
    return ebitda_val / total_operating_revenue
end

"""
    total_margin(excess_of_revenue_over_expenses, total_revenue)

Total margin per HFMA definition (includes non-operating items).
"""
function total_margin(excess_of_revenue_over_expenses::Real, total_revenue::Real)
    total_revenue > 0 || throw(ArgumentError("total_revenue must be positive"))
    return excess_of_revenue_over_expenses / total_revenue
end

"""
    operating_margin_hfma(operating_income, total_operating_revenue)

HFMA operating margin = operating income / total operating revenue.
"""
function operating_margin_hfma(operating_income::Real, total_operating_revenue::Real)
    total_operating_revenue > 0 ||
        throw(ArgumentError("total_operating_revenue must be positive"))
    return operating_income / total_operating_revenue
end

"""
    operating_leverage(contribution_margin, operating_income)

Operating leverage = contribution margin / operating income.
Measures sensitivity of profit to volume changes.
"""
function operating_leverage(contribution_margin::Real, operating_income::Real)
    operating_income == 0 && throw(ArgumentError("operating_income cannot be zero"))
    return contribution_margin / operating_income
end

# ─── Balance Sheet Ratios ─────────────────────────────────────────────────────

"""
    balance_sheet_ratios(current_assets, current_liabilities, cash,
                         total_assets, total_liabilities, net_assets,
                         long_term_debt)

Compute all standard hospital balance sheet ratios.
Returns a named tuple.
"""
function balance_sheet_ratios(current_assets::Real, current_liabilities::Real,
                               cash::Real, total_assets::Real,
                               total_liabilities::Real, net_assets::Real,
                               long_term_debt::Real)
    current_liabilities > 0 ||
        throw(ArgumentError("current_liabilities must be positive"))
    total_assets > 0 || throw(ArgumentError("total_assets must be positive"))
    return (
        current_ratio                   = current_ratio(current_assets, current_liabilities),
        quick_ratio                     = quick_ratio(cash, current_liabilities),
        debt_to_equity                  = debt_to_equity(total_liabilities, net_assets),
        equity_multiplier               = equity_multiplier(total_assets, net_assets),
        long_term_debt_to_capitalization= long_term_debt_to_capitalization(long_term_debt, net_assets),
    )
end

"""
    current_ratio(current_assets, current_liabilities)

Liquidity: current assets / current liabilities. Benchmark ≥ 2.0.
"""
function current_ratio(current_assets::Real, current_liabilities::Real)
    current_liabilities > 0 ||
        throw(ArgumentError("current_liabilities must be positive"))
    return current_assets / current_liabilities
end

"""
    quick_ratio(cash_and_equivalents, current_liabilities)

Quick (acid-test) ratio = cash / current liabilities.
"""
function quick_ratio(cash_and_equivalents::Real, current_liabilities::Real)
    current_liabilities > 0 ||
        throw(ArgumentError("current_liabilities must be positive"))
    return cash_and_equivalents / current_liabilities
end

"""
    debt_to_equity(total_liabilities, net_assets)

Leverage ratio for non-profit hospitals (uses net assets as equity proxy).
"""
function debt_to_equity(total_liabilities::Real, net_assets::Real)
    net_assets == 0 && throw(ArgumentError("net_assets cannot be zero"))
    return total_liabilities / net_assets
end

"""
    equity_multiplier(total_assets, net_assets)

DuPont equity multiplier = total assets / net assets.
"""
function equity_multiplier(total_assets::Real, net_assets::Real)
    net_assets == 0 && throw(ArgumentError("net_assets cannot be zero"))
    return total_assets / net_assets
end

"""
    days_cash_on_hand(cash_and_investments, daily_operating_expense)

Liquidity: days of operating expenses covered by cash.
Rating agency benchmark: Moody's A-rated ≥ 200 days.
"""
function days_cash_on_hand(cash_and_investments::Real, daily_operating_expense::Real)
    daily_operating_expense > 0 ||
        throw(ArgumentError("daily_operating_expense must be positive"))
    return cash_and_investments / daily_operating_expense
end

"""
    long_term_debt_to_capitalization(long_term_debt, net_assets)

Debt capitalization ratio = LTD / (LTD + net assets). Benchmark < 40%.
"""
function long_term_debt_to_capitalization(long_term_debt::Real, net_assets::Real)
    total_cap = long_term_debt + net_assets
    total_cap > 0 || throw(ArgumentError("long_term_debt + net_assets must be positive"))
    return long_term_debt / total_cap
end

# ─── Cash Flow Statement ──────────────────────────────────────────────────────

"""
    cash_flow_indirect(net_income, depreciation, amortization,
                       change_in_ar, change_in_ap, change_in_inventory,
                       capex)

Indirect method cash flow statement. Returns operating, investing, financing, and net.

- `change_in_ar`: increase in AR is negative (uses cash)
- `change_in_ap`: increase in AP is positive (provides cash)
- `capex`: capital expenditures (positive = outflow)
"""
function cash_flow_indirect(net_income::Real, depreciation::Real, amortization::Real,
                             change_in_ar::Real, change_in_ap::Real,
                             change_in_inventory::Real, capex::Real)
    operating = net_income + depreciation + amortization -
                change_in_ar + change_in_ap - change_in_inventory
    investing  = -capex
    financing  = 0.0  # placeholder; populate with debt issuance/repayment
    net_change = operating + investing + financing
    return (operating=operating, investing=investing,
            financing=financing, net_change=net_change)
end

# ─── Depreciation ─────────────────────────────────────────────────────────────

"""
    straight_line_depreciation(cost, salvage_value, useful_life_years)

Straight-line annual depreciation expense.
"""
function straight_line_depreciation(cost::Real, salvage_value::Real,
                                    useful_life_years::Integer)
    useful_life_years > 0 ||
        throw(ArgumentError("useful_life_years must be positive"))
    cost >= salvage_value ||
        throw(ArgumentError("cost must be >= salvage_value"))
    return (cost - salvage_value) / useful_life_years
end

"""
    macrs_depreciation_schedule(cost, property_class)

MACRS (Modified Accelerated Cost Recovery System) depreciation schedule.
Returns a vector of annual depreciation amounts.

`property_class` options: 5 (computers/equipment), 7 (office furniture),
10 (certain equipment), 15 (land improvements), 27.5 (residential), 39 (nonresidential).
"""
function macrs_depreciation_schedule(cost::Real, property_class::Real)
    cost > 0 || throw(ArgumentError("cost must be positive"))
    # IRS Rev. Proc. 87-57 half-year convention percentages
    tables = Dict{Real, Vector{Float64}}(
        5   => [0.2000, 0.3200, 0.1920, 0.1152, 0.1152, 0.0576],
        7   => [0.1429, 0.2449, 0.1749, 0.1249, 0.0893, 0.0892, 0.0893, 0.0446],
        10  => [0.1000, 0.1800, 0.1440, 0.1152, 0.0922, 0.0737,
                0.0655, 0.0655, 0.0656, 0.0655, 0.0328],
        15  => [0.0500, 0.0950, 0.0855, 0.0770, 0.0693, 0.0623,
                0.0590, 0.0590, 0.0591, 0.0590, 0.0591, 0.0590, 0.0591, 0.0590, 0.0591, 0.0295],
        27.5 => fill(1.0/27.5, 28),   # simplified; actual uses mid-month
        39  => fill(1.0/39.0, 40),    # simplified; actual uses mid-month
    )
    haskey(tables, property_class) ||
        throw(ArgumentError("unsupported property_class: $property_class"))
    rates = tables[property_class]
    return [cost * r for r in rates]
end

# ─── Non-Profit / Fund Accounting ─────────────────────────────────────────────

"""
    net_assets_change(beginning_net_assets, excess_revenue, unrestricted_gifts,
                      temporarily_restricted_releases, other_changes)

Change in net assets per FASB ASC 958 (non-profit accounting).
Returns ending net assets.
"""
function net_assets_change(beginning_net_assets::Real, excess_revenue::Real,
                            unrestricted_gifts::Real=0.0,
                            temporarily_restricted_releases::Real=0.0,
                            other_changes::Real=0.0)
    return beginning_net_assets + excess_revenue + unrestricted_gifts +
           temporarily_restricted_releases + other_changes
end

"""
    fund_accounting_summary(unrestricted, temporarily_restricted, permanently_restricted)

Summarise the three net asset classes for a non-profit health system.
Returns a named tuple with totals.
"""
function fund_accounting_summary(unrestricted::Real, temporarily_restricted::Real,
                                  permanently_restricted::Real)
    total = unrestricted + temporarily_restricted + permanently_restricted
    return (
        unrestricted              = Float64(unrestricted),
        temporarily_restricted    = Float64(temporarily_restricted),
        permanently_restricted    = Float64(permanently_restricted),
        total_net_assets          = Float64(total),
        unrestricted_fraction     = total > 0 ? unrestricted / total : 0.0,
    )
end

"""
    charitable_community_benefit_rate(community_benefit_expense, total_operating_expense)

Community benefit as a % of total operating expense (IRS Schedule H standard).
Non-profit hospitals typically report 7–10%.
"""
function charitable_community_benefit_rate(community_benefit_expense::Real,
                                            total_operating_expense::Real)
    total_operating_expense > 0 ||
        throw(ArgumentError("total_operating_expense must be positive"))
    return community_benefit_expense / total_operating_expense
end

end # module
