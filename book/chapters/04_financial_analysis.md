# Chapter 4: Financial Analysis for Healthcare Organizations

## Learning Objectives
After completing this chapter, students will be able to:
1. Construct and interpret hospital income statements using HFMA conventions
2. Compute and benchmark key financial ratios for health systems
3. Apply DuPont analysis to decompose return on equity (net assets)
4. Evaluate financial performance using bond-rating agency frameworks

---

## 4.1 Healthcare Financial Statements

Hospital financial statements differ from those of for-profit corporations in
important ways:

- **Revenue deductions** (contractual adjustments, charity care, bad debt) are
  netted against gross charges to arrive at *net patient revenue*
- **Non-profit status** means equity is replaced by *net assets* (unrestricted,
  temporarily restricted, permanently restricted) per FASB ASC 958
- **Community benefit** reporting is required on IRS Form 990, Schedule H

### Net Patient Revenue Waterfall

```
Gross Charges
  − Contractual Adjustments     (negotiated write-offs to payers)
  − Charity Care                (free care at cost to qualifying patients)
  − Bad Debt                    (uncollectible after good-faith billing)
= Net Patient Revenue
  + Other Operating Revenue     (grants, cafeteria, parking, etc.)
= Total Operating Revenue
  − Operating Expenses
= Operating Income (Excess of Revenue over Expenses)
```

### Julia Example

```julia
using HealthcareFinance

stmt = income_statement(
    50_000_000.0,   # gross charges
    18_000_000.0,   # contractual adjustments
    500_000.0,      # bad debt
    1_000_000.0,    # charity care
    27_000_000.0;   # operating expenses
    other_income = 500_000.0
)

println("Net patient revenue: \$", stmt.net_patient_revenue)
println("Operating margin:    ", round(stmt.total_margin * 100, digits=2), "%")
```

---

## 4.2 Key Financial Ratios

### Profitability
| Ratio | Formula | Typical Benchmark |
|---|---|---|
| Operating margin | Operating income / Total operating revenue | 2–4% |
| Total margin | Excess revenue / Total revenue | 3–5% |
| EBITDA margin | EBITDA / Total operating revenue | 8–12% |
| Return on assets | Net income / Total assets | 2–4% |

### Liquidity
| Ratio | Formula | Typical Benchmark |
|---|---|---|
| Current ratio | Current assets / Current liabilities | ≥ 2.0 |
| Days cash on hand | Cash / (Operating expenses / 365) | ≥ 150 days |
| Days in AR | AR balance / (Net revenue / 365) | ≤ 50 days |

### Leverage (Credit)
| Ratio | Formula | Moody's A Benchmark |
|---|---|---|
| Debt-to-capitalization | LTD / (LTD + Net assets) | < 35% |
| DSCR | (Income + D&A) / Debt service | ≥ 2.0× |
| Maximum annual debt service | MADS / Operating revenue | < 3% |

### Julia Example: Balance Sheet Analysis

```julia
ratios = balance_sheet_ratios(
    12_000_000.0,   # current assets
    5_000_000.0,    # current liabilities
    3_000_000.0,    # cash
    80_000_000.0,   # total assets
    45_000_000.0,   # total liabilities
    35_000_000.0,   # net assets
    30_000_000.0    # long-term debt
)

println("Current ratio:    ", round(ratios.current_ratio, digits=2))
println("D/Cap ratio:      ", round(ratios.long_term_debt_to_capitalization * 100, digits=1), "%")
dscr = debt_service_coverage_ratio(2_000_000.0, 4_000_000.0, 2_500_000.0)
println("DSCR:             ", round(dscr, digits=2))
```

---

## 4.3 DuPont Analysis for Healthcare

The DuPont framework decomposes return on net assets (RONA):

```
RONA = Net Profit Margin × Asset Turnover × Equity Multiplier
```

Where:
- **Net profit margin** = Net income / Revenue
- **Asset turnover** = Revenue / Total assets
- **Equity multiplier** = Total assets / Net assets

---

## 4.4 Community Benefit and Non-Profit Accountability

Under IRS Schedule H, non-profit hospitals must quantify:
1. Financial assistance (charity care at cost)
2. Unreimbursed Medicaid
3. Health professions education
4. Community health improvement services
5. Research

Industry average is 7–10% of total operating expense.

```julia
cbr = charitable_community_benefit_rate(7_500_000.0, 100_000_000.0)
println("Community benefit rate: ", round(cbr * 100, digits=1), "%")
```

---

## Key Terms
- **Contractual adjustment**: Write-off of the difference between billed charges and
  a payer's allowed amount per contract
- **EBITDA**: Earnings before interest, taxes, depreciation, and amortization — key
  credit metric used by Moody's, S&P, and Fitch
- **Days cash on hand**: Liquidity indicator; number of days operations could
  continue using only available cash and investments
- **DSCR**: Debt service coverage ratio; measures ability to service debt obligations
