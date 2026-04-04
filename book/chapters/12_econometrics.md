# Chapter 12: Econometrics and Causal Inference in Health Finance

## Learning objectives

1. Distinguish correlation from causation in healthcare financial data.
2. Apply difference-in-differences to evaluate policy interventions.
3. Use instrumental variables (2SLS) to address endogeneity.
4. Understand regression discontinuity design.

## 12.1 Threats to causal inference

Observational healthcare data suffers from:
- **Confounding:** unmeasured factors affect both treatment and outcome
- **Selection bias:** who receives an intervention is non-random
- **Reverse causality:** financial performance may cause, not result from, staffing levels
- **Measurement error:** coding errors, claims lag, attribution misclassification

## 12.2 Difference-in-Differences (DiD)

DiD estimates causal effects by comparing the change over time in a treated group relative to a control group:

```
DiD = (post_treat − pre_treat) − (post_control − pre_control)
```

**Identifying assumption:** parallel trends — absent the intervention, treated and control groups would have followed parallel trajectories.

**Healthcare example:** Estimate the effect of ACA Medicaid expansion on hospital uncompensated care costs.
- Treatment: expansion states
- Control: non-expansion states
- Outcome: uncompensated care as % of total revenue
- Pre period: 2011–2013; Post period: 2014–2016

## 12.3 Instrumental Variables (IV / 2SLS)

When a regressor X is endogenous (correlated with error term), an instrument Z can identify the causal effect:

**Stage 1:** Regress X on Z → get predicted X̂
**Stage 2:** Regress Y on X̂ → coefficient is the IV estimate

**Instrument validity requirements:**
1. **Relevance:** Z is correlated with X (testable: F > 10 in first stage)
2. **Exclusion restriction:** Z affects Y only through X (untestable, argued from theory)

**Healthcare example:** Estimate the causal effect of hospital volume on surgical outcomes.
- Endogenous: hospital volume (sicker patients seek high-volume centers)
- Instrument: distance to nearest high-volume center

## 12.4 Regression discontinuity

When treatment assignment is determined by a cutoff on a running variable, units just above and below the threshold are comparable. The jump at the threshold estimates the causal effect.

**Healthcare example:** Effect of Medicare eligibility (turning 65) on utilization and health outcomes.

## 12.5 Julia application

```julia
include("src/econometrics_engine.jl")
using .EconometricsEngine

# DiD: ACA Medicaid expansion effect on uncompensated care
pre_expansion   = 0.084   # 8.4% of revenue pre-ACA
post_expansion  = 0.051   # 5.1% post-ACA
pre_control     = 0.079   # 7.9% non-expansion states pre-ACA
post_control    = 0.075   # 7.5% post-ACA (slight secular trend)

did_estimate = difference_in_differences(pre_expansion, post_expansion,
                                          pre_control, post_control)
# → (0.051 − 0.084) − (0.075 − 0.079) = −0.033 + 0.004 = −0.029
# Expansion reduced uncompensated care by ~2.9 percentage points

# 2SLS: hospital volume and patient outcomes
# n=100 synthetic hospitals
n = 100
distance = randn(n) .* 20 .+ 50     # distance to high-volume center
volume = -0.8 .* distance .+ 300 .+ randn(n) .* 30
outcomes = -0.05 .* volume .+ 20 .+ randn(n) .* 3

result = two_stage_least_squares(volume, distance, outcomes)
println("IV estimate (volume → outcomes): ", result.iv_estimate)
```

## Key terms

- Endogeneity
- Difference-in-differences (DiD)
- Parallel trends assumption
- Instrumental variable (IV)
- Two-Stage Least Squares (2SLS)
- Exclusion restriction
- Regression discontinuity

## Discussion questions

1. Why might the parallel trends assumption fail in a DiD study of hospital quality?
2. Design an IV study to estimate the causal effect of nurse staffing ratios on readmission rates.
3. What threats to validity arise when using distance-to-hospital as an instrument?
