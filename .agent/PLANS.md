# ExecPlan

## Phase 1 — Baseline and workflow bootstrap
- Audit source modules, exports, tests, and dashboard scripts.
- Establish tracking artifacts for agentic execution.

## Phase 2 — Package correctness and API consolidation
- Align `HealthcareFinance` public API with implemented engines.
- Preserve backward compatibility for existing `npv` behavior while exposing stable exported interfaces.
- Improve docstrings for public entry points.

## Phase 3 — Testing hardening
- Expand test coverage across financial, forecasting, econometrics, simulation, and value-based care modules.
- Add failure-path checks for argument validation.

## Phase 4 — Dashboard consolidation
- Define a single canonical dashboard entrypoint and route users away from fragmented scripts.
- Document supported dashboard startup path.

## Phase 5 — Validation and delivery
- Run package tests.
- Update `CODEX_PROGRESS.md` with executed steps and validation outcomes.
- Commit coherent changes and prepare PR summary.
