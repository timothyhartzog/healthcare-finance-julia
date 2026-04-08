# Chapter 8: Health Insurance Finance — Premium Pricing, Risk, and Actuarial Methods

## Learning objectives

1. Explain actuarial methods for premium pricing and reserve setting.
2. Analyze medical loss ratio (MLR) and its regulatory implications.
3. Apply risk adjustment methodologies (HCC models).
4. Evaluate Medicare Advantage bid economics.

## 8.1 Premium pricing fundamentals

A health insurance premium must cover:
```
Premium = Expected claims (PMPM) + Administrative loading + Profit margin
         + Risk margin + Reserves
```

**Per-member-per-month (PMPM)** is the standard unit for health plan cost analysis.

## 8.2 Medical Loss Ratio (MLR)

Under the ACA, insurers must spend at least 80% (individual/small group) or 85% (large group) of premium revenue on medical claims and quality improvement:

```
MLR = (claims paid + quality improvement expenses) / (premium revenue − taxes and fees)
```

Failure to meet MLR requires rebates to enrollees.

## 8.3 Risk adjustment

Risk adjustment transfers funds from plans with healthier enrollees to those with sicker enrollees, reducing incentives for favorable selection.

### HCC (Hierarchical Condition Category) model

CMS-HCC uses demographic factors + chronic condition diagnoses:

```
Risk score = demographic_base + Σ (HCC_coefficient for each condition present)
```

A risk score of 1.0 = average expected costs. Score 1.5 = 50% above average.

## 8.4 Medicare Advantage economics

MA plans submit bids relative to a county benchmark rate. Plans below benchmark keep a portion of the difference (rebate); plans above benchmark charge supplemental premiums.

**Bid economics:**
- Bid < benchmark → shared savings + rebate used for enhanced benefits
- Bid > benchmark → supplemental premium required

## 8.5 Julia application

```julia
using .ValueBasedCareEngine

# HCC risk score
hcc_risk_score(0.85, [0.30, 0.20, 0.15])  # → 1.50

# Population risk index for a panel of patients
panel_scores = [0.8, 1.2, 1.5, 0.9, 2.1, 1.0]
population_risk_index(panel_scores)  # → mean ≈ 1.25

# Episode spending PMPM
episode_spending_pmpm(12_000_000.0, 1200.0)  # → 10_000.0 PMPM
```

## Key terms

- Per-member-per-month (PMPM)
- Medical loss ratio (MLR)
- Risk adjustment
- HCC model
- Medicare Advantage (MA)
- Benchmark rate
- Community rating

## Discussion questions

1. How does risk adjustment reduce cherry-picking in ACA exchange markets?
2. Why might a Medicare Advantage plan with high-risk members still be financially viable?
3. What are the incentives created by the MLR floor, and are they aligned with value?
