# Financial Engine

The `FinancialEngine` module provides core time-value-of-money, profitability, and revenue analytics used throughout the platform.

## Module location

`src/financial_engine.jl`

## Exported functions

### Time value of money

| Function | Signature | Description |
|---|---|---|
| `npv` | `npv(rate, cashflows)` | Net present value (cashflows discounted from period 1) |
| `payback_period` | `payback_period(investment, cashflows)` | Periods to recover initial investment; returns `missing` if never |

### Profitability

| Function | Signature | Description |
|---|---|---|
| `roi` | `roi(gain, cost)` | Return on investment `(gain - cost) / cost` |
| `operating_margin` | `operating_margin(revenue, expense)` | `(revenue - expense) / revenue` |
| `cost_per_patient` | `cost_per_patient(total_cost, encounters)` | Average cost per patient encounter |
| `break_even_units` | `break_even_units(fixed, price, var_cost)` | Break-even volume from contribution margin |

### Revenue cycle

| Function | Signature | Description |
|---|---|---|
| `drg_revenue` | `drg_revenue(base_rate, weight, cases)` | Simple DRG revenue estimate |
| `weighted_payer_rate` | `weighted_payer_rate(rates, shares)` | Blended reimbursement rate across payers |
| `net_collection_rate` | `net_collection_rate(payments, charges, adjustments)` | Payments as fraction of net revenue |

## Usage example

```julia
include("src/financial_engine.jl")
using .FinancialEngine

# NPV of a three-year project at 5% discount
npv(0.05, [10_000.0, 12_000.0, 15_000.0])  # → 33_196.6

# ROI on a capital investment
roi(120_000.0, 100_000.0)  # → 0.20

# DRG revenue for 100 cases, weight 1.2, base rate $6,000
drg_revenue(6000.0, 1.2, 100)  # → 720_000.0
```

## Design notes

- All functions accept `Real` or `AbstractVector{<:Real}` to support Integer, Float32, Float64, and Rational inputs.
- Division-by-zero guards throw `ArgumentError` with descriptive messages.
- `payback_period` returns `missing` (not an error) when payback is never reached, enabling `ismissing()` checks in calling code.
