# Chapter 13: Cost-Effectiveness Analysis and Health Technology Assessment

## Learning objectives

1. Conduct a cost-effectiveness analysis from a payer or societal perspective.
2. Build a simple decision tree and Markov cohort model.
3. Interpret ICER results and apply willingness-to-pay thresholds.
4. Understand the role of HTA agencies in coverage decisions.

## 13.1 Perspectives in CEA

The perspective determines which costs and outcomes to include:
- **Payer perspective:** only reimbursed medical costs
- **Healthcare system perspective:** all direct medical costs
- **Societal perspective:** direct medical + indirect (productivity, caregiver) costs

ICER results can differ substantially by perspective.

## 13.2 The cost-effectiveness plane

A scatter plot of (ΔQALY, ΔCost) relative to a comparator:
- **Quadrant I (dominant):** more effective AND cheaper → always adopt
- **Quadrant II (dominated):** less effective AND more costly → never adopt
- **Quadrants III/IV:** tradeoff; evaluate against WTP threshold

## 13.3 Decision tree model

For one-time decisions with probabilistic branches:

```
Decision node → Treatment A
                  ├─ (p) Successful → QALYs_success, Cost_A_success
                  └─ (1-p) Failed   → QALYs_failure, Cost_A_failure

Decision node → Treatment B
                  ├─ (q) Successful → QALYs_success, Cost_B_success
                  └─ (1-q) Failed   → QALYs_failure, Cost_B_failure

Expected QALY_A = p × QALYs_success + (1-p) × QALYs_failure
Expected Cost_A = p × Cost_A_success + (1-p) × Cost_A_failure
ICER(A vs B) = (Cost_A − Cost_B) / (QALY_A − QALY_B)
```

## 13.4 Markov cohort model

For chronic conditions with ongoing transitions between health states, a Markov model tracks a cohort over time:

1. Define health states (e.g., Stable, Progressed, Dead)
2. Estimate transition probabilities per cycle
3. Assign utility weights (QALYs) and costs per state per cycle
4. Simulate over lifetime horizon
5. Discount QALYs and costs at 3–5% annually

## 13.5 Sensitivity analysis

- **One-way sensitivity:** vary each parameter individually across plausible range
- **Probabilistic sensitivity (PSA):** simultaneously sample all uncertain parameters from distributions; produce cost-effectiveness acceptability curves (CEAC)
- **Tornado diagram:** rank parameters by influence on ICER

## 13.6 Julia application

```julia
using .FinancialEngine, .SimulationEngine, .ValueBasedCareEngine

# Simple ICER
icer(80_000.0, 55_000.0, 2.1, 1.5)   # → 41_667 per QALY

# Monte Carlo CEA: uncertain efficacy and cost
n_sim = 10_000
rng = Random.MersenneTwister(42)
icers = [begin
    Δcost = 25_000 + randn() * 3000
    Δqaly = 0.6 + randn() * 0.1
    Δcost / Δqaly
end for _ in 1:n_sim]

pct_cost_effective = mean(icers .< 100_000)
println("Probability cost-effective at 100K threshold: ", pct_cost_effective)

# One-way sensitivity on efficacy
base_fn(qaly_new) = icer(80_000.0, 55_000.0, qaly_new, 1.5)
sensitivity = one_way_sensitivity(base_fn, 2.1, 1.7, 2.5)
```

## Key terms

- Incremental cost-effectiveness ratio (ICER)
- Quality-adjusted life year (QALY)
- Willingness-to-pay (WTP) threshold
- Decision tree model
- Markov cohort model
- Probabilistic sensitivity analysis (PSA)
- Cost-effectiveness acceptability curve (CEAC)

## Discussion questions

1. How should a hospital system incorporate HTA findings into formulary and protocol decisions?
2. Why might a societal-perspective ICER differ from a payer-perspective ICER for a mental health intervention?
3. Design a Markov model to evaluate a preventive cardiovascular program.
