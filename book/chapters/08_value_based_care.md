# Chapter 8: Value-Based Care and Population Health Finance

## Learning Objectives
1. Explain the CMS value-based payment landscape (MSSP, BPCI, VBP)
2. Calculate ACO shared savings and losses under MSSP tracks
3. Model bundled payment gainsharing for an episode of care
4. Apply HEDIS and Star Rating quality measurement frameworks
5. Quantify the financial ROI of care management and SDOH interventions

---

## 8.1 The Value Transformation

The "Triple Aim" framework (IHI) drives the shift from volume to value:
1. **Better patient experience** of care
2. **Improved population health**
3. **Lower per capita cost**

CMS tracks include:
| Program | Risk Model | Mechanism |
|---|---|---|
| MSSP Track 1/1+ | One-sided (upside only) | Shared savings |
| MSSP Enhanced (Track E) | Two-sided | Shared savings and losses |
| BPCI-A | Retrospective episode | Gainsharing vs. target price |
| Medicare Shared Savings | Prospective benchmark | Risk-adjusted ACO benchmark |
| Hospital VBP | Budget-neutral | Quality-adjusted DRG payment |

---

## 8.2 ACO Benchmarking and MSSP Shared Savings

```julia
using HealthcareFinance

# Set prospective benchmark
benchmark = aco_benchmark(11_500.0, 0.035, 1.08)
println("ACO benchmark PBPY: \$", round(benchmark, digits=0))

# Compute shared savings
savings = mssp_shared_savings(
    benchmark,          # benchmark PBPY
    10_800.0,           # actual expenditures PBPY
    8_000,              # assigned beneficiaries
    0.50;               # 50% sharing rate (Track 1)
    minimum_savings_rate = 0.02
)
println("Shared savings payment: \$", round(savings, digits=0))
```

---

## 8.3 Bundled Payments

BPCI Advanced bundles all Medicare Part A and B services for 90 days
post-trigger event. ACOs retain savings vs. target price.

```julia
# Hip replacement episode: target $25,000, actual cost $22,500
gainshare = bundled_payment_gainshare(
    25_000.0, 22_500.0, 0.50;
    stop_loss_threshold = 5_000.0
)
println("Gainsharing revenue: \$", round(gainshare, digits=0))
```

---

## 8.4 Quality Measurement: HEDIS and Star Ratings

HEDIS (Healthcare Effectiveness Data and Information Set) contains >90 measures
covering preventive care, chronic disease management, and behavioral health.

```julia
# Composite quality score for ACO quality bonus
rates = [0.72, 0.85, 0.91, 0.68, 0.78]   # five HEDIS measures
weights = [0.25, 0.25, 0.20, 0.15, 0.15]
composite = hedis_composite_score(rates, weights)
println("Composite HEDIS score: ", round(composite * 100, digits=1), "%")

# Star rating computation
thresholds = [
    [0.55, 0.65, 0.75, 0.85],  # measure 1 cut points
    [0.60, 0.70, 0.80, 0.90],  # measure 2 cut points
]
stars = star_rating_score([0.82, 0.85], thresholds)
println("Star ratings: ", stars.measure_stars)
println("Composite stars: ", stars.composite_stars)
```

---

## 8.5 Care Gap Closure and SDOH ROI

### Care Gap Intervention ROI

```julia
# HbA1c testing program for diabetic members
cgr = care_gap_closure_roi(
    3_000,     # gaps closed
    25.0,      # cost per outreach/closure
    450.0,     # avoided downstream cost per closed gap
    50_000.0   # program fixed cost
)
println("Net benefit: \$", round(cgr.net_benefit, digits=0))
println("ROI:         ", round(cgr.roi * 100, digits=1), "%")
```

### Social Determinants of Health

Housing instability, food insecurity, and transportation barriers account for
~30–55% of health outcomes. Financial modeling of SDOH interventions:

```julia
sdoh = sdoh_financial_impact(
    1_200,      # high-risk members
    300.0,      # cost per member for housing navigation
    0.18,       # expected 18% utilization reduction
    9_500.0     # average annual medical spend per member
)
println("Total savings: \$", round(sdoh.total_savings, digits=0))
println("Net impact:    \$", round(sdoh.net_impact, digits=0))
println("ROI:           ", round(sdoh.roi * 100, digits=1), "%")
```

---

## Key Terms
- **ACO**: Accountable Care Organization — network of providers sharing financial responsibility for a defined population
- **MSSP**: Medicare Shared Savings Program — CMS ACO program with benchmark-based shared savings/losses
- **PBPY**: Per-Beneficiary-Per-Year — standard unit for ACO expenditure benchmarks
- **MSR**: Minimum Savings Rate — threshold below which an ACO does not receive shared savings
- **BPCI-A**: Bundled Payments for Care Improvement Advanced — episode-based payment model
- **SDOH**: Social Determinants of Health — non-clinical factors (housing, food, education) affecting health outcomes
