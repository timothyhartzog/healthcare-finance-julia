# Chapter 6: Capital Investment — Debt Finance, Bond Ratings, and Strategic Capital Allocation

## Learning objectives

1. Understand sources of long-term capital for healthcare organizations.
2. Analyze the components of a hospital bond rating.
3. Apply capital allocation frameworks to competing investment requests.
4. Model debt service coverage and covenant compliance.

## 6.1 Sources of capital

- **Tax-exempt municipal bonds:** primary debt vehicle for nonprofit hospitals; interest is exempt from federal income tax.
- **Taxable bonds:** used when tax-exempt allocation is exhausted or for for-profit entities.
- **Bank loans and lines of credit:** flexible short-term or intermediate financing.
- **Equity / philanthropic capital:** endowments, donor gifts, retained earnings.
- **Leasing:** operating vs. capital leases for equipment.

## 6.2 Bond ratings

Rating agencies (Moody's, S&P, Fitch) assign ratings based on:

| Factor | Key metrics |
|---|---|
| Profitability | Operating margin, EBITDA margin |
| Liquidity | Days cash on hand, current ratio |
| Leverage | Debt-to-capitalization, debt-to-EBITDA |
| Debt service | Debt service coverage ratio (DSCR) |
| Market position | Market share, payor mix, payer diversity |

Investment grade: Baa3/BBB- and above. Below-investment-grade hospitals face much higher borrowing costs.

**Debt service coverage ratio (DSCR):**
```
DSCR = (net income + depreciation + interest) / annual debt service
```
Bond covenants typically require DSCR ≥ 1.10–1.25.

## 6.3 Capital allocation frameworks

Hospitals face limited capital budgets. Allocation approaches:

1. **Financial hurdle rate:** require NPV > 0 at the hospital's WACC.
2. **Scoring matrix:** weighted score of financial return, strategic fit, regulatory requirement, quality impact.
3. **Portfolio approach:** balance short-payback tactical investments with long-term strategic capacity.

## 6.4 Julia application

```julia
using .FinancialEngine

# Debt service coverage calculation
ebitda_val = 15_000_000.0
interest = 2_000_000.0
annual_principal = 3_000_000.0
net_income = 5_000_000.0
depreciation = 8_000_000.0

dscr = (net_income + depreciation + interest) / (annual_principal + interest)

# NPV comparison of two capital projects
npv_project_a = npv(0.06, [-5_000_000.0, 1_200_000.0, 1_400_000.0, 1_600_000.0, 1_800_000.0])
npv_project_b = npv(0.06, [-3_000_000.0, 900_000.0, 1_000_000.0, 1_100_000.0, 1_200_000.0])
```

## Key terms

- Tax-exempt bond
- Debt service coverage ratio (DSCR)
- Weighted average cost of capital (WACC)
- Capital structure
- Days cash on hand
- Bond covenant

## Discussion questions

1. Why do nonprofit hospitals have access to tax-exempt bonds and how does this affect their cost of capital?
2. A hospital's DSCR falls from 2.1 to 1.15. What actions can management take to avoid covenant breach?
3. How would you incorporate quality and mission into a capital allocation scoring matrix?
