# Chapter 1: Healthcare Systems — Structure, Stakeholders, and Financial Flows

## Learning objectives

After completing this chapter, students will be able to:
1. Describe the organizational structures of major healthcare delivery models (fee-for-service, integrated delivery networks, ACOs).
2. Identify the primary financial stakeholders and their incentive structures.
3. Trace the flow of funds from payer to provider.
4. Explain how policy environment shapes financial strategy.

## 1.1 Types of healthcare organizations

### Hospitals

Hospitals are classified by ownership (government, nonprofit, for-profit), size (critical access, community, academic medical center), and service mix. Academic medical centers cross-subsidize teaching and research through clinical revenues. Critical access hospitals operate under cost-based reimbursement from Medicare.

### Physician groups and multispecialty practices

Independent physician associations (IPAs), large multispecialty groups, and hospital-employed physician organizations differ in governance, billing infrastructure, and exposure to value-based contracts.

### Integrated Delivery Networks (IDNs)

IDNs vertically integrate hospitals, physician groups, post-acute facilities, and often health insurance operations. Financial integration enables population health management and risk-bearing contracts.

### Payers

Commercial insurers, Medicare, Medicaid, Medicare Advantage plans, and self-insured employers each set reimbursement policy through contracts (commercial) or regulatory frameworks (government programs).

## 1.2 Stakeholder incentive analysis

| Stakeholder | Primary financial interest | Risk appetite |
|---|---|---|
| Hospital CFO | Operating margin, bond rating | Low-moderate |
| Physician group | Professional fee revenue, overhead control | Low |
| Commercial insurer | Premium adequacy, medical loss ratio | Moderate |
| CMS | Program solvency, quality improvement | Regulatory |
| Patient | Out-of-pocket cost minimization | Low |
| Employer | Benefit cost per employee | Moderate-high |

## 1.3 Financial flows in a fee-for-service system

```
Patient encounter
    ↓
Claim submitted by provider to payer
    ↓
Payer adjudicates: allow / deny / adjust
    ↓
Contractual adjustment (discount off charges)
    ↓
Payer remittance (allowed amount)
    ↓
Patient balance (copay / deductible / coinsurance)
    ↓
Provider posts payment; writes off balance if uncollectible
```

## 1.4 The shift to value-based care

Fee-for-service creates volume incentives misaligned with health outcomes. Value-based programs restructure financial flows:

- **Pay for performance (P4P):** bonus or penalty adjustments on base rates tied to quality measures (HCAHPS, readmissions, mortality).
- **Bundled payments:** single episode payment shared across all providers in a care episode.
- **Accountable Care Organizations (ACOs):** provider groups bear risk for total cost of care for an attributed population; share in savings below benchmark spending.
- **Capitation:** per-member-per-month payment replaces encounter-based billing entirely.

## 1.5 Policy environment

Key federal policies shaping hospital finance:
- **Medicare IPPS:** Inpatient Prospective Payment System sets DRG-based rates.
- **ACA Section 3022:** created the Medicare Shared Savings Program (ACOs).
- **MACRA / MIPS:** Quality Payment Program affecting physician reimbursement.
- **No Surprises Act:** limits balance billing and affects revenue cycle operations.
- **340B drug pricing program:** affects hospital pharmacy margins.

## Key terms

- Fee-for-service (FFS)
- Integrated Delivery Network (IDN)
- Accountable Care Organization (ACO)
- Prospective payment system (PPS)
- Medical loss ratio (MLR)
- Capitation

## Discussion questions

1. How does the transition from FFS to value-based reimbursement change a hospital's financial planning horizon?
2. What information asymmetries exist between payers and providers, and how do they affect contract negotiations?
3. Compare the financial risk profiles of a rural critical access hospital and a large urban academic medical center.

## Julia application

The `FinancialEngine` and `ValueBasedCareEngine` modules provide functions relevant to this chapter:
- `weighted_payer_rate` — model blended reimbursement across payer mix
- `shared_savings` — compute ACO shared savings under MSSP
- `episode_spending_pmpm` — normalize episode spending to a per-member-per-month basis
