# Chapter 2: Healthcare Accounting — Financial Statements, Ratios, and Cost Structures

## Learning objectives

1. Read and interpret a hospital income statement, balance sheet, and statement of cash flows.
2. Compute and benchmark standard healthcare financial ratios.
3. Distinguish between full absorption costing, activity-based costing, and marginal costing in a healthcare setting.
4. Apply Julia's `Accounting` module to real-world hospital financial data.

## 2.1 The hospital income statement

The hospital income statement (also called the statement of operations) reports revenues and expenses over a period:

```
Net patient service revenue
+ Other operating revenue
= Total operating revenue

- Salaries, wages, and benefits
- Supplies and other expenses
- Depreciation and amortization
- Interest expense
= Operating income (EBIT)

± Non-operating items (investment income, gains/losses)
= Net income (excess of revenues over expenses)
```

**Net patient service revenue** is gross charges minus contractual adjustments (negotiated discounts), charity care write-offs, and bad debt expense.

## 2.2 The balance sheet

| Assets | Liabilities & Equity |
|---|---|
| Current assets (cash, A/R, supplies) | Current liabilities (A/P, accrued expenses, current debt) |
| Long-term investments | Long-term debt |
| Property, plant & equipment (net) | Net assets (equity): unrestricted, temporarily restricted, permanently restricted |

For nonprofit hospitals, equity is called **net assets** and includes donor-restricted funds.

## 2.3 Key financial ratios

### Liquidity
- **Current ratio** = current assets / current liabilities (benchmark: ≥ 2.0)
- **Days cash on hand** = (cash + investments) / (total expenses / 365)

### Profitability
- **Operating margin** = operating income / total operating revenue (benchmark: 2–5% for nonprofits)
- **Net profit margin** = net income / total revenue
- **EBITDA margin** = EBITDA / revenue

### Efficiency
- **Days in A/R** = net A/R / (net patient revenue / 365) (benchmark: 35–55 days)
- **Asset turnover** = revenue / average total assets

### Leverage
- **Debt-to-equity** = long-term debt / net assets (benchmark: < 1.5 for investment-grade nonprofits)
- **Debt service coverage** = EBITDA / annual debt service (bond covenant threshold: often 1.25×)

## 2.4 Cost accounting

### Full absorption costing

Assigns all manufacturing / service costs (direct + overhead) to a patient encounter:

```
Full cost = direct labor + direct supplies + allocated overhead
```

Overhead is allocated based on a cost driver (e.g., direct labor hours, RVUs).

### Activity-based costing (ABC)

ABC assigns overhead by identifying specific activities that consume resources:

1. Identify activities (triage, IV insertion, imaging, discharge planning)
2. Assign costs to activity cost pools
3. Determine cost drivers (number of IV starts, imaging minutes)
4. Calculate activity rates (cost per driver unit)
5. Assign costs to patient encounters based on actual activity consumption

ABC produces more accurate per-encounter costs but requires detailed data collection.

### Marginal (variable) costing

Distinguishes fixed costs (incurred regardless of volume) from variable costs (proportional to volume):

- **Contribution margin** = revenue − variable cost
- Used for break-even analysis and short-run pricing decisions

## 2.5 Julia module: Accounting

The `Accounting` module (`src/accounting/accounting.jl`) implements all ratios and cost accounting functions discussed in this chapter.

```julia
include("src/accounting/accounting.jl")
using .Accounting

# Liquidity
current_ratio(200_000.0, 100_000.0)         # → 2.0
days_in_accounts_receivable(500_000.0, 5_000_000.0)  # → 36.5

# Profitability
operating_margin = gross_profit_margin(10_000_000.0, 7_500_000.0)   # → 0.25
ebitda_val = ebitda(2_000_000.0, 300_000.0, 50_000.0)               # → 2_350_000

# Activity-based cost per encounter
activity_based_cost([50.0, 30.0, 20.0], [200.0, 100.0, 50.0], 500.0)
# → (50*200 + 30*100 + 20*50) / 500 = 26.0
```

## Key terms

- Net patient service revenue
- Contractual adjustment / contractual allowance
- Days in accounts receivable (DAR)
- Activity-based costing (ABC)
- Contribution margin
- EBITDA
- Net assets (nonprofit equity)

## Discussion questions

1. Why might two hospitals with the same gross margin have very different operating margins?
2. How does activity-based costing change the financial case for service line decisions?
3. A hospital's DAR increases from 45 to 62 days. What revenue cycle processes might explain this?
