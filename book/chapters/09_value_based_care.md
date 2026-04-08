# Chapter 9: Value-Based Care Finance — ACOs, Bundled Payments, and Quality Incentives

## Learning objectives

1. Compute ACO shared savings and losses under MSSP and BASIC/ENHANCED tracks.
2. Model the financial implications of bundled payment programs.
3. Calculate quality-adjusted outcomes and ICER.
4. Apply SDOH adjustments to risk models.

## 9.1 The value equation

Porter's value framework:
```
Value = Health outcomes achieved / Cost of achieving those outcomes
```

In financial terms:
```
value_score = clinical_outcome_index / total_cost_per_patient
```

## 9.2 ACO shared savings

Under the Medicare Shared Savings Program (MSSP):
1. CMS assigns beneficiaries to an ACO based on plurality of primary care use
2. A risk-adjusted benchmark spending target is set
3. If actual spending < benchmark by more than the Minimum Savings Rate (MSR), the ACO shares in savings
4. Under two-sided risk tracks, ACOs also share in losses if spending exceeds benchmark

```
Gross savings = benchmark_spending − actual_spending
ACO share = max(0, gross_savings) × shared_savings_rate   (if savings_rate ≥ MSR)
```

## 9.3 Bundled payments (BPCI / CJR)

A single episode payment covers all services for a defined care episode (e.g., hip/knee replacement, CABG):

```
Episode savings = target_price − actual_episode_spending
Provider reconciliation = episode_savings × sharing_rate
```

Effective bundles require:
- Care coordination across hospital, post-acute, and outpatient settings
- Accurate episode attribution
- Downside risk management

## 9.4 Pay-for-performance

CMS programs (VBP, HRRP, HAC Reduction Program) adjust base DRG payments:

| Program | Adjustment | Metric |
|---|---|---|
| Value-Based Purchasing | ±2% | Clinical outcomes, patient experience |
| Hospital Readmissions Reduction | Up to −3% | Risk-adjusted readmission rates |
| HAC Reduction | −1% | Hospital-acquired conditions |

## 9.5 ICER and cost-effectiveness

The Incremental Cost-Effectiveness Ratio compares a new intervention to a comparator:

```
ICER = (cost_new − cost_comparator) / (effect_new − effect_comparator)
```

Common thresholds: <$50,000/QALY (highly cost-effective), <$100,000/QALY (acceptable), >$150,000/QALY (not cost-effective under most frameworks).

## 9.6 Julia application

```julia
using .ValueBasedCareEngine

# ACO net savings
aco_net_savings(2_500_000.0, 50_000_000.0; min_savings_rate=0.02, shared_savings_rate=0.50)
# → savings rate = 5% > MSR; ACO earns 50% × 2.5M = 1.25M

# ICER
icer(75_000.0, 50_000.0, 1.8, 1.0)   # → 31_250 per QALY

# Readmission rate
readmission_rate(45.0, 500.0)  # → 0.09 (9%)

# Quality payment adjustment
quality_payment_adjustment(1_000_000.0, 1.015)  # +1.5% bonus
```

## Key terms

- Shared savings rate
- Minimum savings rate (MSR)
- Bundled payment
- Episode of care
- ICER (Incremental Cost-Effectiveness Ratio)
- QALY
- Value-Based Purchasing (VBP)
- Hospital Readmissions Reduction Program (HRRP)

## Discussion questions

1. What clinical capabilities must a hospital develop to succeed under two-sided ACO risk?
2. How does episode definition affect the financial exposure in a bundled payment program?
3. At what ICER threshold should a payer refuse to cover a new oncology drug?
