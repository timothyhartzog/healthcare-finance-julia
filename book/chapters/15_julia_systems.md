# Chapter 15: Julia for Healthcare Analytics — Language, Ecosystem, and Implementation

## Learning objectives

1. Understand why Julia is well-suited for healthcare financial modeling.
2. Navigate the HealthcareFinanceSystem package and its modules.
3. Write type-stable, performant Julia functions for financial computations.
4. Integrate Julia with databases (DuckDB), the web (Genie), and data files (CSV).

## 15.1 Why Julia for healthcare finance?

| Property | Benefit |
|---|---|
| JIT compilation | C-like speed for numerical loops; no vectorization required |
| Multiple dispatch | Generic functions work across data types (Int, Float32, Float64) |
| Unicode support | Write β₁, x̄, Σ directly in source code |
| REPL-driven workflow | Fast iteration without recompilation overhead |
| Strong ecosystem | Statistics.jl, DataFrames.jl, GLM.jl, JuMP.jl, Genie.jl |
| Interoperability | Call Python (PyCall.jl), R (RCall.jl), C/Fortran natively |

## 15.2 Package structure

```
HealthcareFinance/
  src/
    HealthcareFinanceSystem.jl    # Umbrella module, re-exports all
    financial_engine.jl           # NPV, ROI, DRG, payer mix
    econometrics_engine.jl        # OLS, logistic, DiD, IV/2SLS
    simulation_engine.jl          # Monte Carlo, bootstrap, scenarios
    value_based_care_engine.jl    # QALY, ICER, ACO, quality metrics
    forecasting_models.jl         # Moving average, linear trend
    accounting/accounting.jl      # Financial ratios, cost accounting
    reimbursement/reimbursement.jl # DRG, APC, RVU, revenue cycle
    forecasting/forecasting.jl    # Exponential smoothing, Holt-Winters
  test/                           # Test files for each module
  examples/                       # Runnable demonstrations
  docs/                           # Architecture and API documentation
```

## 15.3 Writing performant Julia

Key performance guidelines:
1. **Type stability:** functions should return a consistent type
2. **Avoid global variables:** pass data as function arguments
3. **Use AbstractVector/AbstractMatrix:** enables generic dispatch
4. **Prefer `sum(f(x) for x in v)` over allocating intermediate arrays** for tight loops
5. **Use `@inbounds` sparingly** for validated inner loops

## 15.4 Database integration (DuckDB)

```julia
using DuckDB

db = DuckDB.DB()
DuckDB.execute(db, """
    CREATE TABLE hospital_financials AS
    SELECT * FROM read_csv_auto('data/synthetic/hospitals.csv')
""")

result = DuckDB.execute(db, """
    SELECT hospital_id, AVG(operating_margin) as avg_margin
    FROM hospital_financials
    GROUP BY hospital_id
""")
df = DataFrame(result)
```

## 15.5 Building a Genie dashboard

See `app/src/dashboard_app.jl` for a working example. The key pattern:

```julia
using Genie, Stipple, StippleUI

@reactive mutable struct Model <: ReactiveModel
    rate::R{Float64} = 0.05
    cashflows::R{Vector{Float64}} = [100.0, 200.0]
    npv_out::R{Float64} = 0.0
end

function handlers(model)
    on(model.rate) do _
        model.npv_out[] = FinancialEngine.npv(model.rate[], model.cashflows[])
    end
    model
end
```

## 15.6 Running tests

```bash
# Run all tests
julia --project=. -e 'include("test/runtests.jl")'

# Run a single module's tests
julia --project=. test/accounting_tests.jl
```

## Key terms

- Multiple dispatch
- Type stability
- Just-in-time (JIT) compilation
- REPL
- Genie / Stipple
- DuckDB

## Discussion questions

1. What trade-offs would you face choosing Julia vs. Python (pandas + scikit-learn) for a hospital analytics platform?
2. How does multiple dispatch enable the `ols_regression` function to work with both `Matrix{Float64}` and `Matrix{Int}`?
3. Design the schema for a DuckDB database to store historical hospital financial data for 200 hospitals over 10 years.
