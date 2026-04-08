# Chapter 3: Reimbursement Systems — DRG, Payer Mix, and Revenue Cycle Analytics

## Learning objectives

1. Calculate inpatient DRG payments including outlier adjustments and case mix index.
2. Apply outpatient APC and physician RVU payment methodologies.
3. Conduct payer mix analysis and compute blended reimbursement rates.
4. Measure revenue cycle performance with standard benchmarks.

## 3.1 Inpatient Prospective Payment System (IPPS)

Medicare pays acute care hospitals via DRG-based prospective payments:

```
DRG payment = base_rate × DRG_weight × (1 + DSH + IME)
```

Where:
- **Base rate:** operating and capital blended federal rate, adjusted for local wages
- **DRG weight:** relative resource intensity (higher = more complex / costlier)
- **DSH:** Disproportionate Share Hospital adjustment for safety-net hospitals
- **IME:** Indirect Medical Education adjustment for teaching hospitals

### Outlier payments

For extraordinarily high-cost cases:
```
Outlier payment = 0.80 × (actual_cost − (DRG_payment + fixed_loss_threshold))
```
The threshold is reset annually by CMS.

### Case Mix Index (CMI)

```
CMI = sum(DRG weights) / total discharges
```

A higher CMI indicates a more complex patient population and drives higher average reimbursement per case.

## 3.2 Outpatient: Ambulatory Payment Classifications (APCs)

Medicare pays hospital outpatient departments under the Outpatient Prospective Payment System (OPPS):

```
APC payment = APC_base_rate × relative_weight × wage_index
```

Multiple APCs may be assigned to a single encounter (packaging rules apply).

## 3.3 Physician: Resource-Based Relative Value Scale (RBRVS)

Medicare Fee Schedule payments for physician services:

```
Payment = (work_RVU × work_GPCI + PE_RVU × PE_GPCI + MP_RVU × MP_GPCI) × conversion_factor
```

Where GPCI = Geographic Practice Cost Index (adjusts for local cost of living).

## 3.4 Payer mix analysis

Hospitals serve multiple payers with different rates. Payer mix analysis:

```
Blended rate = Σ (payer_rate[i] × payer_share[i])
```

Commercial payers reimburse at higher rates than Medicare/Medicaid; a favorable commercial mix improves overall margin.

## 3.5 Revenue cycle analytics

| Metric | Formula | Benchmark |
|---|---|---|
| Days in A/R | net_AR / (net_revenue / 365) | 35–55 days |
| Net collection rate | payments / (charges − adjustments) | ≥ 95% |
| Denial rate | denied_claims / total_claims | < 5% |
| Clean claim rate | clean_claims / total_claims | > 90% |
| Bad debt rate | bad_debt / net_revenue | < 3% |

## 3.6 Julia module: Reimbursement

```julia
include("src/reimbursement/reimbursement.jl")
using .Reimbursement

# DRG payment for a case weight 1.5, base $6,000 + 5% DSH + 3% IME
drg_payment(6000.0, 1.5; dsh_adjustment=0.05, ime_adjustment=0.03)
# → 9000.0 * 1.08 = 9_720.0

# Case mix index for 100 discharges
drg_weights = fill(1.2, 50) ∪ fill(2.0, 50)
case_mix_index(drg_weights)

# Days in A/R
days_in_accounts_receivable(4_500_000.0, 45_000_000.0; days_in_period=365)  # → 36.5

# Denial rate
denial_rate(150.0, 3000.0)  # → 0.05
```

## Key terms

- Diagnosis Related Group (DRG)
- Case Mix Index (CMI)
- Disproportionate Share Hospital (DSH)
- Ambulatory Payment Classification (APC)
- Relative Value Unit (RVU)
- Net collection rate
- Clean claim rate

## Discussion questions

1. Why would a hospital's case mix index increase even if it adds no new service lines?
2. How does the outlier payment formula protect hospitals from catastrophic cases?
3. A hospital's net collection rate drops from 97% to 92%. What are the likely causes and remedies?
