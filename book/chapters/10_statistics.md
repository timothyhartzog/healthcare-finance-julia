# Chapter 10: Statistics for Healthcare Finance — Distributions, Hypothesis Testing, and Sampling

## Learning objectives

1. Apply descriptive statistics to healthcare cost and utilization data.
2. Conduct hypothesis tests on financial performance metrics.
3. Use confidence intervals and bootstrap methods for uncertainty quantification.
4. Understand distributions relevant to healthcare cost modeling.

## 10.1 Descriptive statistics for healthcare data

Healthcare cost data is typically:
- Right-skewed (long tail of high-cost patients)
- Zero-inflated (many patients with no utilization in a period)
- Count data (hospital admissions, ED visits)

Report median and interquartile range alongside mean for skewed distributions.

**Coefficient of variation (CV):**
```
CV = std(x) / mean(x)
```
Higher CV indicates greater variability relative to the mean. CV > 1.0 is common in total healthcare cost distributions.

## 10.2 Hypothesis testing in financial context

Compare performance metrics across periods, facilities, or populations using t-tests, rank-sum tests, or permutation tests.

**Example:** Did average cost per encounter change significantly after a process improvement initiative?

- H₀: mean cost pre = mean cost post
- H₁: mean cost post < mean cost pre (one-sided)
- Use Welch's t-test for unequal variances

## 10.3 Bootstrap methods

Bootstrap resampling provides non-parametric confidence intervals without distributional assumptions:

1. Draw n samples with replacement from observed data (n = original sample size)
2. Compute the statistic of interest on the resample
3. Repeat B = 1000–10000 times
4. The percentile interval [α/2, 1-α/2] of bootstrap statistics is the CI

## 10.4 Distributions in healthcare cost modeling

| Distribution | Use case |
|---|---|
| Log-normal | Individual-level medical costs |
| Negative binomial | Count data with overdispersion (admissions) |
| Gamma | Aggregate cost modeling |
| Tweedie (compound Poisson-Gamma) | Zero-inflated cost data |
| Normal | Large-sample aggregates (CLT) |

## 10.5 Julia application

```julia
using .SimulationEngine
using Statistics
import Random

data = [500.0, 1200.0, 800.0, 3500.0, 450.0, 2200.0]

# Coefficient of variation
cv = std(data) / mean(data)

# Bootstrap CI for mean
rng = Random.MersenneTwister(42)
lo, hi = bootstrap_ci(data, 5000; confidence=0.95, rng=rng)
println("95% bootstrap CI: ($lo, $hi)")

# Monte Carlo simulation from log-normal cost distribution
using Distributions
cost_sampler = () -> rand(LogNormal(log(2000), 0.8))
mean_cost = monte_carlo_mean(cost_sampler, 100_000)
p95_cost = monte_carlo_percentile(cost_sampler, 100_000, 95)
```

## Key terms

- Coefficient of variation (CV)
- Bootstrap confidence interval
- Log-normal distribution
- Negative binomial
- Tweedie distribution
- Hypothesis testing

## Discussion questions

1. Why is mean cost a misleading performance metric for a high-cost patient population?
2. When would you use bootstrap instead of a parametric confidence interval?
3. How does the choice of cost distribution affect a stop-loss insurance premium calculation?
