# Chapter 17: Capstone — Integrated Healthcare Financial Analysis

## Overview

This capstone chapter integrates all modules of the course into a comprehensive healthcare financial analysis project. Students apply the full HealthcareFinanceSystem toolkit to a realistic scenario: evaluating the financial viability and strategic value of a proposed integrated care program at a regional health system.

## Case context

**Lakewood Health System** (fictional) is a 450-bed nonprofit hospital in a moderately competitive urban market. The CFO is evaluating a proposed **Accountable Care Organization (ACO)** program with a 5-year financial model.

Key parameters:
- 25,000 attributed Medicare beneficiaries (average risk score 1.15)
- Current PMPM spending: $890
- CMS benchmark: $920 PMPM (system has historically outperformed)
- Program infrastructure cost: $4.2M upfront + $1.5M/year
- Expected shared savings rate: 40% (BASIC Track E)
- Minimum savings rate: 2%

## Part 1: Baseline financial assessment

Compute key ratios from Lakewood's balance sheet and income statement using the `Accounting` module:

```julia
include("src/accounting/accounting.jl")
using .Accounting

# Income statement data (in millions)
revenue = 650.0; operating_expense = 610.0; depreciation = 28.0
interest = 12.0; capex = 35.0; operating_cf = 55.0

# Ratios
op_margin = operating_margin(revenue, operating_expense)
ebitda_val = ebitda(revenue - operating_expense, depreciation, 4.0)
fcf = free_cash_flow(operating_cf, capex)
```

## Part 2: ACO financial projection (5 years)

Model shared savings and costs using `ValueBasedCareEngine` and `FinancialEngine`:

```julia
include("src/value_based_care_engine.jl")
include("src/financial_engine.jl")
using .ValueBasedCareEngine, .FinancialEngine

n_members = 25_000
benchmark_pmpm = 920.0
actual_pmpm = 890.0
member_months_per_year = n_members * 12

for yr in 1:5
    benchmark = benchmark_pmpm * member_months_per_year
    actual = actual_pmpm * (0.995^(yr-1)) * member_months_per_year   # assumed 0.5%/yr improvement
    net = aco_net_savings(benchmark - actual, benchmark;
                          min_savings_rate=0.02, shared_savings_rate=0.40)
    program_cost = yr == 1 ? 4_200_000 + 1_500_000 : 1_500_000
    println("Year $yr net benefit: \$(round(net - program_cost, digits=0))")
end
```

## Part 3: NPV and break-even

```julia
cashflows = [-5_700_000.0, 800_000.0, 1_200_000.0, 1_500_000.0, 1_800_000.0, 2_100_000.0]
project_npv = npv(0.06, cashflows)
pp = payback_period(5_700_000.0, cashflows[2:end])
println("NPV: ", project_npv)
println("Payback: ", pp, " years")
```

## Part 4: Sensitivity and scenario analysis

```julia
include("src/simulation_engine.jl")
using .SimulationEngine

# One-way sensitivity on shared savings rate
base_fn(sav_rate) = begin
    annual_savings = aco_net_savings(
        (benchmark_pmpm - actual_pmpm) * n_members * 12,
        benchmark_pmpm * n_members * 12;
        shared_savings_rate = sav_rate
    )
    npv(0.06, vcat(-5_700_000.0, fill(annual_savings - 1_500_000.0, 5)))
end

result = one_way_sensitivity(base_fn, 0.40, 0.20, 0.60)

# Monte Carlo: uncertain PMPM trajectory
cost_sampler() = rand() * 0.01 - 0.005   # ±0.5% annual improvement
paths = simulate_stochastic_growth(actual_pmpm * n_members * 12, cost_sampler, 5, 10_000)
```

## Part 5: Quality metrics and value score

```julia
# Composite quality score (readmission, HAC, patient experience)
composite_quality_score([92.0, 88.0, 85.0], [0.4, 0.3, 0.3])

# Value score
value_score(0.91, actual_pmpm * 12)   # outcome index / annual cost

# ICER vs. usual care
icer(actual_pmpm * 12 + 1_500_000/n_members, actual_pmpm * 12, 0.82, 0.78)
```

## Part 6: Econometric evaluation

After the first 2 years, evaluate program effectiveness using DiD:

```julia
include("src/econometrics_engine.jl")
using .EconometricsEngine

pre_aco_spending   = 920.0   # PMPM baseline
post_aco_spending  = 878.0   # PMPM post-intervention
pre_control        = 915.0   # comparison region pre
post_control       = 908.0   # comparison region post

did = difference_in_differences(pre_aco_spending, post_aco_spending,
                                 pre_control, post_control)
println("DiD estimate: -$(round(-did, digits=2)) PMPM reduction attributable to ACO")
```

## Deliverables

Students completing the capstone should produce:
1. Executive summary (1–2 pages): financial recommendation with supporting rationale
2. 5-year pro forma income statement for the ACO program
3. Sensitivity analysis tornado chart
4. Monte Carlo simulation output (expected NPV distribution)
5. DiD evaluation design for year 2 program assessment

## Reflection questions

1. Based on the financial model, should Lakewood Health System pursue the ACO program?
2. What are the three most important risk factors, and how would you mitigate them?
3. How would your recommendation change if Lakewood's payer mix shifted 5% toward Medicaid?
4. What quality investments would most efficiently increase the composite quality score and value score?
5. If the DiD analysis at year 2 shows no statistically significant savings, what actions should leadership take?
