# Chapter 5: Budgeting and Forecasting in Healthcare Organizations

## Learning objectives

1. Construct an operating budget for a hospital department or service line.
2. Apply moving average, exponential smoothing, and Holt-Winters forecasting.
3. Perform variance analysis comparing actual to budget.
4. Use flexible budgeting to separate volume effects from efficiency effects.

## 5.1 The budgeting process

The annual operating budget cycle typically runs 3–4 months before the fiscal year start:

1. **Strategic direction:** leadership sets volume and financial targets
2. **Statistical budget:** volume projections (discharges, visits, procedures)
3. **Revenue budget:** volumes × payer mix × net rates
4. **Expense budget:** volumes × staffing ratios + fixed overhead
5. **Capital budget:** equipment, construction, IT projects
6. **Consolidated review and approval:** board-level sign-off

## 5.2 Forecasting methods

### Moving average

Forecast = mean of the most recent k observations. Simple but does not capture trends.

### Exponential smoothing (SES)

```
S_t = α × y_t + (1 − α) × S_{t-1}
```

α near 1: heavy weight on recent data (responsive).
α near 0: slow-moving average (stable, lag-prone).

### Holt's double exponential smoothing (trend)

Adds a trend component:
```
L_t = α × y_t + (1 − α)(L_{t-1} + T_{t-1})
T_t = β(L_t − L_{t-1}) + (1 − β) T_{t-1}
Forecast(h) = L_t + h × T_t
```

### Holt-Winters additive (seasonality)

Extends Holt's method with a seasonal component. Required for monthly volumes with seasonal patterns (flu season, elective procedure scheduling).

## 5.3 Variance analysis

Variance = Actual − Budget

Decompose total variance into:
- **Volume variance:** due to more/fewer cases than budgeted
- **Rate/price variance:** due to different revenue rates or unit costs
- **Efficiency variance:** due to staffing productivity differences

A flexible budget adjusts the static budget to actual volume, isolating the efficiency and rate effects.

## 5.4 Julia module: Forecasting

```julia
include("src/forecasting/forecasting.jl")
using .Forecasting

monthly_encounters = [1200, 1150, 1300, 1400, 1350, 1500,
                      1450, 1600, 1550, 1700, 1650, 1800]

# SES forecast for next 3 months
res = simple_exponential_smoothing(monthly_encounters, 0.3; horizon=3)
res.forecast

# Holt-Winters additive (monthly data, season=12)
hw = holt_winters_additive(Float64.(monthly_encounters), 0.3, 0.1, 0.2, 12; horizon=6)
hw.forecast

# Budget variance
budget_variance(1_050_000.0, 1_000_000.0)   # over budget by 50K
budget_variance_pct(1_050_000.0, 1_000_000.0)  # → 0.05 (5%)
```

## Key terms

- Static budget
- Flexible budget
- Volume variance
- Rate variance
- Efficiency variance
- Exponential smoothing
- Holt-Winters

## Discussion questions

1. Why is a flexible budget more useful than a static budget for performance evaluation?
2. How should a hospital CFO set the smoothing parameter α for a volume forecast?
3. What are the risks of using a purely statistical forecast without qualitative judgment?
