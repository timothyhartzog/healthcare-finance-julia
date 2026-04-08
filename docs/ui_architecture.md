# UI Architecture

## Overview

The interactive dashboard is built on the **Genie + Stipple** reactive framework, a full-stack Julia web application stack. The UI allows users to input financial parameters and receive real-time computed analytics without page reloads.

## Stack

| Layer | Technology |
|---|---|
| Web server | Genie.jl |
| Reactive state | Stipple.jl |
| UI components | StippleUI.jl (Quasar / Vue.js) |
| Charts | PlotlyJS.jl (via StipplePlotly) |
| File upload | Genie file upload API |
| Computation | HealthcareFinanceSystem.jl |

## Application files

```
app/
  Project.toml          — app-specific dependencies
  src/
    app.jl              — minimal single-page demo
    dashboard_app.jl    — core reactive dashboard
    dashboard_extended.jl — extended with additional metrics
    dashboard_plus.jl   — CSV upload + aggregate stats
    dashboard_enterprise.jl — multi-tab enterprise view
```

## Reactive model pattern

Each dashboard defines a `ReactiveModel` struct tagged with `@reactive` that holds:
- **Input fields:** user-adjustable parameters (rates, volumes, costs)
- **Output fields:** computed results that update when inputs change
- **Data fields:** uploaded datasets and processed results

```julia
@reactive mutable struct FinanceModel <: ReactiveModel
    # Inputs
    rate::R{Float64} = 0.05
    cashflows::R{Vector{Float64}} = [100.0, 200.0, 300.0]

    # Outputs
    npv_result::R{Float64} = 0.0
    roi_result::R{Float64} = 0.0
end
```

## Controller pattern

A Genie route handler recalculates outputs when inputs change:

```julia
on(model.rate) do _
    model.npv_result[] = FinancialEngine.npv(model.rate[], model.cashflows[])
end
```

## Data flow

```
Browser (Quasar / Vue)
   ↕ WebSocket (Stipple)
ReactiveModel (Julia struct)
   ↓ on() handler
HealthcareFinanceSystem (computation)
   ↓ result assignment
ReactiveModel (updated)
   ↕ WebSocket push
Browser (re-rendered)
```

## CSV upload flow

1. User uploads a CSV of hospital financial data
2. Genie receives the file and saves to a temp path
3. CSV.jl + DataFrames.jl parse the data
4. Aggregate metrics (total revenue, average margin, etc.) are computed
5. Results populate ReactiveModel output fields

## Planned enhancements

- **Multi-scenario comparison:** side-by-side NPV/IRR across scenarios
- **Cohort filtering:** filter metrics by payer, service line, or DRG
- **Time-series charts:** interactive PlotlyJS line charts for trend data
- **Authentication:** Genie Auth for user accounts and role-based access
- **Export:** download computed results as CSV or PDF report
- **PubMed integration:** relevant literature surfaced alongside metrics
