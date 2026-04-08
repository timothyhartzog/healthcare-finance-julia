# Chapter 7: Healthcare Economics and Insurance

## Learning Objectives
1. Apply supply-and-demand analysis to healthcare markets
2. Explain moral hazard, adverse selection, and market failures in insurance
3. Develop insurance premiums from a claims cost base
4. Compute actuarial metrics: frequency, severity, MLR, IBNR
5. Apply credibility theory to experience-rated groups

---

## 7.1 Market Failures in Healthcare

Healthcare markets exhibit four classic failures that justify public intervention:

### 1. Information Asymmetry
- Providers know more than patients about treatment necessity and quality
- Payers know less than enrollees about individual health risk
- Creates **adverse selection** (sick people buy more insurance) and
  **moral hazard** (insured people consume more care)

### 2. Externalities
- Infectious disease treatment benefits society beyond the individual
- Vaccination programs are positive externalities justifying subsidy

### 3. Market Power
- Hospital consolidation reduces competition and raises prices
- Empirical evidence: hospital mergers raise prices 6–40% in concentrated markets

### 4. Public Goods
- Medical research has non-rival, non-excludable characteristics
- Underproduced by markets alone; justifies NIH/public funding

---

## 7.2 Insurance Premium Development

The actuarial premium formula:

```
Premium = Pure Premium / (1 − Expense Loading − Profit Margin)

Pure Premium = Claim Frequency × Claim Severity
```

```julia
using HealthcareFinance

# Individual market premium development
freq = claim_frequency(2_400, 1_000.0)     # 2.4 claims per member-year
sev  = claim_severity(720_000_000.0, 2_400_000)  # $300 per claim
pp   = pure_premium(freq, sev)
premium = premium_rate_development(pp / 12, 0.15, 0.05)  # monthly PMPM
println("Monthly premium: \$", round(premium, digits=2))
```

---

## 7.3 Medical Loss Ratio

The ACA requires insurers to spend a minimum fraction of premiums on medical care:
- 80% for individual/small group markets
- 85% for large group markets

Insurers below the threshold must issue rebates to policyholders.

```julia
mlr = medical_loss_ratio(850_000_000.0, 1_000_000_000.0)
println("MLR: ", round(mlr * 100, digits=1), "%")
println("ACA compliant (large group): ", mlr >= 0.85)
```

---

## 7.4 IBNR Reserve Development

Claims "incurred but not reported" (IBNR) are a critical actuarial liability.
Insurers must estimate ultimate claims from partially developed triangles using
chain-ladder or Bornhuetter-Ferguson methods.

```julia
# 4-year claims development triangle (rows = accident years, cols = development ages)
triangle = Float64[
    10_000   12_000   12_500   12_600;
    11_000   13_200   13_800   0;
    10_500   12_600   0        0;
    11_500   0        0        0
]

ldfs = loss_development_factors(triangle)
println("LDFs: ", round.(ldfs, digits=3))

ibnr = ibnr_reserve(triangle)
println("IBNR by accident year: \$", round.(ibnr))
println("Total IBNR reserve:    \$", round(sum(ibnr)))
```

---

## 7.5 Price Elasticity in Healthcare

Healthcare demand is generally price-inelastic:
- Emergency care: nearly perfectly inelastic (|ε| ≈ 0.1)
- Elective procedures: more elastic (|ε| ≈ 0.2–0.5)
- Prescription drugs: moderate elasticity (|ε| ≈ 0.3)

The RAND Health Insurance Experiment estimated overall healthcare demand
elasticity of approximately −0.2.

```julia
e = elasticity(-0.20, 1.0)   # 1% price increase → 0.2% demand decrease
println("Price elasticity: ", e)
println("Classification: ", abs(e) < 1 ? "Inelastic" : "Elastic")
```

---

## Key Terms
- **Adverse selection**: Market failure where asymmetric information causes disproportionate enrollment of high-risk individuals
- **Moral hazard**: Tendency to consume more services when insured because the marginal cost is subsidized
- **Community rating**: Setting a single premium for an entire rating area regardless of individual health status
- **IBNR**: Incurred But Not Reported — claims liability for services already rendered but not yet billed or paid
- **Credibility**: Statistical weight given to a group's own experience vs. manual/market rates
