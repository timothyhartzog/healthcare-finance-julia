# Chapter 6: Reimbursement Systems and Revenue Cycle

## Learning Objectives
1. Explain the major Medicare payment systems (IPPS, OPPS, RBRVS)
2. Calculate MS-DRG hospital payments including wage-index and policy adjustments
3. Compute physician fee schedule payments from RVU components
4. Analyze revenue cycle performance using standard KPI benchmarks
5. Model payer contract net revenue under fee schedule and capitation arrangements

---

## 6.1 The U.S. Reimbursement Landscape

Healthcare reimbursement flows through several distinct payment systems:

| Setting | CMS System | Unit of Payment |
|---|---|---|
| Inpatient hospital | IPPS (MS-DRG) | Per discharge |
| Outpatient hospital | OPPS (APC) | Per visit/procedure |
| Physician | RBRVS / PFS | Per service (RVU) |
| Skilled nursing | SNF PPS | Per diem |
| Home health | HH PPS | Per 60-day episode |
| Inpatient psych | IPF PPS | Per diem |

---

## 6.2 Inpatient Prospective Payment System (IPPS)

**MS-DRG payment formula:**
```
Payment = Base Rate × DRG Relative Weight × Cases
         × Wage-Index Adjustment
         × (1 + DSH Adjustment + IME Adjustment)
         + Outlier Payments
```

- **Base rate**: Hospital-specific blended operating + capital rate (~$6,000–$10,000)
- **DRG weight**: Reflects relative resource intensity (1.0 = average case)
- **Wage index**: Adjusts for local labor costs (~0.80–1.40 depending on MSA)
- **DSH**: Disproportionate share add-on for hospitals serving low-income patients
- **IME**: Indirect medical education add-on for teaching hospitals

### Julia Example

```julia
using HealthcareFinance

# Community hospital, high-severity cardiac case (DRG 280, weight 6.0)
payment = ms_drg_payment(
    8_500.0,    # base rate
    6.0,        # DRG weight
    50,         # discharges
    :mcc;       # major complication/comorbidity
    wage_index    = 1.12,
    dsh_adjustment = 0.08,
    ime_adjustment = 0.0
)
println("Total MS-DRG payment: \$", round(payment, digits=0))
println("Per-case:             \$", round(payment/50, digits=0))
```

---

## 6.3 Physician Fee Schedule / RBRVS

Each CPT code has three RVU components:

| Component | Measures |
|---|---|
| Work RVU | Physician time, skill, mental effort |
| Practice Expense RVU | Office overhead: staff, equipment, supplies |
| Malpractice RVU | Professional liability insurance cost |

```
Payment = (Work RVU × GPCI_work + PE RVU × GPCI_pe + MP RVU × GPCI_mp)
          × Conversion Factor
```

2024 CMS conversion factor: ~$32.74/RVU

```julia
# Office visit (99213): Work=1.3, PE=0.92, MP=0.10
pay = rvu_to_payment(1.3, 0.92, 0.10, 32.74; gpci_work=1.05, gpci_pe=1.02, gpci_mp=0.98)
println("Medicare allowable: \$", round(pay, digits=2))
```

---

## 6.4 Revenue Cycle KPIs

The revenue cycle spans patient registration through final payment. Key metrics:

| KPI | Formula | Benchmark |
|---|---|---|
| Days in AR | AR balance / (Net revenue / 365) | ≤ 50 days |
| Denial rate | Denied claims / Total submitted | < 5% |
| Clean claim rate | First-pass paid / Total submitted | ≥ 95% |
| Net collection rate | Cash collected / (Charges − Contractuals) | ≥ 95% |
| Cash collection efficiency | Cash collected / Net revenue | ≥ 100% |

```julia
sc = revenue_cycle_scorecard(
    days_ar = 45.0,
    denial_rt = 0.04,
    clean_claim_rt = 0.96,
    cash_efficiency = 1.01
)
println("Days AR performance:     ", sc.days_ar)
println("Denial rate performance: ", sc.denial_rate)
```

---

## 6.5 Capitation and Value-Based Contracting

In capitated arrangements, providers receive a fixed **per-member-per-month (PMPM)**
payment regardless of utilization. Risk is transferred from payer to provider.

```julia
pmpm = capitation_pmpm(12_000_000.0, 100_000.0)   # $12M / 100K member-months
println("PMPM: \$", pmpm)

# Project forward at 4% annual trend
pmpm_yr3 = pmpm_trend(pmpm, 0.04/12, 36)           # 36 months
println("PMPM in 3 years: \$", round(pmpm_yr3, digits=2))
```

---

## Key Terms
- **MS-DRG**: Medicare Severity-Diagnosis Related Group — the inpatient classification and payment unit
- **APC**: Ambulatory Payment Classification — OPPS equivalent of DRG for outpatient services
- **RVU**: Relative value unit — building block of physician fee schedule payments
- **GPCI**: Geographic practice cost index — local cost adjustment to RVU components
- **Capitation**: Fixed periodic payment per enrolled member regardless of services rendered
