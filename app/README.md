# Healthcare Finance Dashboard

Interactive Genie/Stipple dashboards for healthcare finance analytics.

## Canonical entrypoint (consolidated)

Run the canonical launcher:

```bash
julia --project=app app/src/app.jl
```

By default this starts the consolidated dashboard experience (`dashboard_plus.jl`).

## Optional legacy modes

Use `DASHBOARD_MODE` only when explicitly validating legacy flows:

- `enterprise` → `dashboard_enterprise.jl`
- `extended` → `dashboard_extended.jl`

Example:

```bash
DASHBOARD_MODE=enterprise julia --project=app app/src/app.jl
```

## Features

- Compute financial metrics
- Compare scenarios
- Load CSV summary rows
- Run enterprise-style dataset analysis route
