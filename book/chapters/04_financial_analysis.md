# Chapter 4: Financial Analysis — NPV, IRR, and Capital Investment Decisions

## Learning objectives

1. Apply net present value (NPV) and internal rate of return (IRR) to healthcare capital projects.
2. Compute payback period and break-even analysis.
3. Evaluate lease-vs.-buy decisions for medical equipment.
4. Construct a pro forma income statement for a new service line.

## 4.1 Time value of money

A dollar today is worth more than a dollar in the future. The present value of a future cash flow CF received in period t at discount rate r is:

```
PV = CF / (1 + r)^t
```

For a series of cash flows:
```
NPV = Σ CF_t / (1 + r)^t
```

Accept projects where NPV > 0.

## 4.2 Internal rate of return

The IRR is the discount rate that makes NPV = 0. It can be found numerically using bisection or Newton's method. Accept projects where IRR > weighted average cost of capital (WACC).

## 4.3 Payback period

The payback period is the number of periods required to recover an initial investment from cumulative cash flows. It ignores time value of money but is a useful liquidity metric.

## 4.4 Break-even analysis

Break-even volume = fixed costs / contribution margin per unit

In healthcare, "units" may be encounters, procedures, bed-days, or adjusted patient days.

## 4.5 Service line pro forma

A pro forma income statement projects revenue and costs for a proposed service or program:

1. Estimate volume (encounters, cases) from market data
2. Apply expected payer mix and reimbursement rates → net revenue
3. Estimate variable costs (supplies, labor) and fixed costs (equipment, space)
4. Project operating income over 3–5 years
5. Discount to NPV; compare to hurdle rate

## 4.6 Julia application

```julia
using .FinancialEngine

# NPV of a new imaging center over 5 years
npv(0.07, [-2_000_000.0, 400_000.0, 500_000.0, 600_000.0, 650_000.0, 700_000.0])

# Break-even volume for a new procedure
break_even_units(500_000.0, 1200.0, 450.0)  # fixed=500K, price=1200, var=450

# Payback period
payback_period(2_000_000.0, [400_000.0, 500_000.0, 600_000.0, 700_000.0])
```

## Key terms

- Net present value (NPV)
- Internal rate of return (IRR)
- Weighted average cost of capital (WACC)
- Payback period
- Contribution margin
- Pro forma

## Discussion questions

1. Why might an NPV-positive project be rejected at a nonprofit hospital?
2. How should a hospital choose a discount rate for capital project evaluation?
3. What are the limitations of using IRR as a sole decision criterion?
