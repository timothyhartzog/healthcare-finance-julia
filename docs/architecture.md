# Architecture

## Overview

Healthcare Finance Julia is a full-stack analytical platform for MBA-level quantitative healthcare finance. It combines a Julia computation engine with a Genie + Stipple reactive dashboard and a DuckDB/PostgreSQL persistence layer.

## Frontend

- **Framework:** Genie.jl + Stipple.jl (reactive web UI)
- **Components:** StippleUI inputs, tables, charts (PlotlyJS / Makie)
- **Routing:** Genie router handles page and API endpoints
- **File upload:** CSV hospital dataset ingestion via Genie file handling

## Backend Modules (`src/`)

| Module | File | Purpose |
|---|---|---|
| FinancialEngine | `financial_engine.jl` | NPV, ROI, DRG revenue, payer mix |
| Accounting | `accounting/accounting.jl` | Financial ratios, cost accounting, hospital metrics |
| Reimbursement | `reimbursement/reimbursement.jl` | DRG/APC/RVU payment, revenue cycle analytics |
| Forecasting | `forecasting/forecasting.jl` | Exponential smoothing, Holt-Winters, budget variance |
| ForecastingModels | `forecasting_models.jl` | Moving average, linear trend |
| EconometricsEngine | `econometrics_engine.jl` | OLS, logistic regression, DiD, IV/2SLS |
| SimulationEngine | `simulation_engine.jl` | Monte Carlo, scenario analysis, bootstrap |
| ValueBasedCareEngine | `value_based_care_engine.jl` | QALY, ICER, ACO finance, quality metrics |

The umbrella module `HealthcareFinanceSystem.jl` re-exports all public symbols.

## Database

- **DuckDB:** embedded OLAP store for local analytics and development
- **PostgreSQL:** cloud-hosted production database for multi-user deployments
- **Schemas:** defined in `data/` with ETL notes and provenance tracking

## Data Flow

```
User Input (CSV / form)
       ↓
  Genie Controller
       ↓
  HealthcareFinanceSystem (Julia computation)
       ↓
  Stipple ReactiveModel (state update)
       ↓
  Stipple UI (rendered output / chart)
```

## Deployment Targets

- **Docker + Cloud Run:** containerized single-instance deployment
- **Fly.io:** lightweight PaaS deployment with persistent volumes
- **Local:** `julia --project=app/` for development

## Testing

- Test files in `test/` run each module in isolation
- Run all tests: `julia --project=. -e 'include("test/runtests.jl")'`

## Future Architecture

- Authentication layer (Genie Auth) for enterprise multi-tenant use
- Real-time streaming analytics via SSE / WebSockets
- PubMed RAG pipeline for evidence-augmented financial models
