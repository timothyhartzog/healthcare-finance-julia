# Healthcare Finance Julia

A unified repository for an MBA-level quantitative financial analysis of healthcare systems project.

This repository combines:

- textbook and teaching materials
- Julia source code for healthcare finance analytics
- data schemas and ETL plans
- references from MBA syllabi and evidence reviews
- interactive application/dashboard prototypes

## Quickstart (package API)

```julia
using HealthcareFinance

margin = operating_margin(1_000_000.0, 800_000.0)
beu = break_even_units(100_000.0, 50.0, 30.0)
forecast = forecast_series([100.0, 120.0, 140.0, 160.0]; method=:linear_trend, horizon=2)
```

## Repository goals

1. Build a rigorous textbook on quantitative financial analysis of healthcare systems.
2. Create reusable Julia modules for finance, reimbursement, forecasting, econometrics, simulation, and value-based care.
3. Organize datasets, schemas, and provenance for reproducible analysis.
4. Support deployment as an interactive educational and analytical platform.

## Top-level structure

- `book/` — textbook manuscript and references
- `src/` — Julia package source code
- `test/` — automated tests
- `examples/` — runnable examples and demos
- `data/` — schemas, synthetic data, ETL notes, provenance
- `references/` — bibliography and literature-review materials
- `docs/` — architecture and project documentation
- `app/` — dashboard applications

## Package entrypoint

Use `HealthcareFinance` as the canonical package module.
`HealthcareFinanceSystem` remains available as a compatibility wrapper.

## License

To be determined by repository owner.
