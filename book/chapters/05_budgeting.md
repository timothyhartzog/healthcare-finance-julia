# Chapter 5: Budgeting and Variance Analysis

## Learning Objectives
1. Build an operating budget using fixed and variable cost structures
2. Construct a flexible budget adjusted to actual volume
3. Decompose total variance into volume, price, efficiency, and mix components
4. Rank and select capital projects using NPV and strategic scoring
5. Apply zero-based budgeting to healthcare service lines

---

## 5.1 The Operating Budget

Healthcare budgets integrate clinical activity (volume) with financial targets.

**Basic structure:**
```
Revenue = Price × Volume
Variable Costs = Variable Cost Rate × Volume
Contribution Margin = Revenue − Variable Costs
Operating Income = Contribution Margin − Fixed Costs
```

### Julia Example

```julia
using HealthcareFinance

# Cardiology clinic: 8,000 visits budgeted at $150/visit
bud = operating_budget(600_000.0, 45.0, 8_000, 150.0)
println("Budgeted operating income: \$", bud.operating_income)
println("Break-even volume: ", break_even_units(600_000.0, 150.0, 45.0), " visits")
```

---

## 5.2 Flexible Budgeting

A *static budget* is prepared at the start of the period. A *flexible budget*
adjusts the cost and revenue targets to the actual volume, isolating whether
variance is from volume or other factors.

```julia
# Actual volume was 8,800 (10% above budget)
flex = flex_budget(600_000.0, 45.0, 8_800, 150.0)

# Variance analysis
vol_var   = volume_variance(150.0 - 45.0, 8_800, 8_000)   # CM × ΔVolume
price_var = price_variance(148.0, 150.0, 8_800)            # actual price was $148

println("Volume variance (F/U): \$", vol_var)
println("Price variance (F/U):  \$", price_var)
```

---

## 5.3 Four-Variance Decomposition

| Variance | Formula | Meaning |
|---|---|---|
| **Volume** | Budgeted CM/unit × (Actual − Budgeted volume) | More/fewer encounters |
| **Price (Rate)** | (Actual price − Budget price) × Actual volume | Revenue per unit |
| **Efficiency** | Budgeted cost × (Actual inputs − Standard inputs) | Resource productivity |
| **Mix** | Shift in composition across service lines or payers | Patient/payer mix effect |

Favorable variances increase operating income; unfavorable reduce it.

---

## 5.4 Capital Budgeting

Capital projects in healthcare often require Certificate of Need (CON) approval
and involve long useful lives (10–30 years for buildings, 5–10 for equipment).

**Decision criteria:**
1. **NPV > 0**: creates economic value
2. **IRR > WACC**: returns exceed cost of capital
3. **DSCR ≥ 1.25**: can service associated debt

```julia
cfs = [-2_000_000.0, 500_000.0, 600_000.0, 700_000.0, 800_000.0, 600_000.0]
project_npv = npv(0.07, cfs)
project_irr = irr(cfs)
println("NPV:         \$", round(project_npv))
println("IRR:         ", round(project_irr * 100, digits=2), "%")
println("PI:          ", profitability_index(project_npv, 2_000_000.0))
```

### Capital Project Ranking

```julia
projects = [
    (name="OR Renovation",    npv=800_000.0,  strategic_score=9.0),
    (name="MRI Replacement",  npv=600_000.0,  strategic_score=8.0),
    (name="Parking Structure", npv=200_000.0, strategic_score=4.0),
    (name="Telehealth Platform", npv=400_000.0, strategic_score=9.5),
]
ranked = capital_budget_rank(projects; npv_weight=0.6, strategic_weight=0.4)
for (i, p) in enumerate(ranked)
    println("$i. $(p.name): score = $(round(p.composite_score, digits=2))")
end
```

---

## 5.5 Zero-Based Budgeting in Healthcare

ZBB requires each budget line item to be justified from scratch each period,
rather than incrementing prior year. Useful for administrative overhead review.

```julia
# Score a telehealth program for ZBB approval
score = zero_based_budget_score(9.0, 8.5, 9.0;
                                  weights=(0.4, 0.3, 0.3))
println("ZBB score (0–10): ", round(score, digits=2))
```

---

## Key Terms
- **Contribution margin**: Revenue minus variable costs; the amount available to cover fixed costs and generate profit
- **Flexible budget**: A budget restated at actual volume to isolate non-volume variances
- **Capital rationing**: Situation where available capital is insufficient to fund all positive-NPV projects
- **Zero-based budgeting**: Budget methodology requiring justification of all expenditures from zero
