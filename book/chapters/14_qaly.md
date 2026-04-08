# Chapter 14: QALYs, Utilities, and Health Outcomes Measurement

## Learning objectives

1. Derive QALY estimates from utility instruments (EQ-5D, SF-6D, HUI).
2. Evaluate the ethical and distributional implications of the QALY framework.
3. Apply disability-adjusted life years (DALYs) as an alternative measure.
4. Understand the ICER Society's value framework for the United States.

## 14.1 Defining a QALY

QALY = life years × utility weight (health-related quality of life)

Utility weight:
- 1.0 = perfect health
- 0.0 = death
- Negative values possible for states worse than death

**Example:** 3 years in a state with utility 0.7 = 2.1 QALYs

## 14.2 Utility measurement instruments

| Instrument | Method | Response options |
|---|---|---|
| EQ-5D-3L | Direct questionnaire | 243 health states |
| EQ-5D-5L | Direct questionnaire | 3125 health states |
| SF-6D | Derived from SF-36 | Continuous 0.3–1.0 |
| HUI-3 | Direct questionnaire | 8 dimensions |
| TTO (Time Trade-Off) | Stated preference | Continuous 0–1 |
| SG (Standard Gamble) | Stated preference | Continuous 0–1 |

Value sets are preference weights derived from population surveys; they vary by country.

## 14.3 Disability-Adjusted Life Years (DALYs)

DALYs measure disease burden:
```
DALY = YLL + YLD
```
- YLL (Years of Life Lost) = premature mortality
- YLD (Years Lived with Disability) = years × disability weight

Used by WHO and in global burden of disease analyses. Unlike QALYs, DALYs represent disease burden (lower is better).

## 14.4 Critiques of the QALY

- Discriminates against people with disabilities (lower baseline utility → fewer QALYs gained)
- Aggregation assumes equal value of health states across individuals
- Does not capture equity preferences (distribution of health gains matters)
- Sensitive to whose values are used to weight health states

Alternative value frameworks (ICER, ISPOR) incorporate:
- Severity of illness (end-of-life premium)
- Disease rarity
- Unmet medical need
- Broader non-QALY benefits (caregiver effects, productivity)

## 14.5 Julia application

```julia
using .ValueBasedCareEngine

# QALYs for a patient living 5 years post-surgery with utility 0.82
qalys(5.0, 0.82)   # → 4.1

# Discounted QALYs over 10 years at 3%
annual_qaly = 0.75
discounted_qalys = sum(annual_qaly / (1.03)^t for t in 1:10)

# ICER vs. best supportive care
icer(120_000.0, 10_000.0, 2.5, 1.0)   # → 73_333 per QALY
```

## Key terms

- Quality-adjusted life year (QALY)
- Utility weight
- EQ-5D
- Disability-adjusted life year (DALY)
- Time Trade-Off (TTO)
- Standard Gamble (SG)
- Value framework

## Discussion questions

1. How would you explain the QALY concept to a hospital clinical leadership team unfamiliar with health economics?
2. Should the US adopt a single national WTP threshold, as the UK's NICE does with £20,000–30,000/QALY?
3. Design a study to estimate the utility weight for a post-ICU survivor with long-COVID symptoms.
