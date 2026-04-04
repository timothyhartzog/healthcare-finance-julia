# Chapter 7: Health Economics — Markets, Demand, and Insurance Theory

## Learning objectives

1. Apply microeconomic principles to healthcare markets.
2. Analyze demand elasticity for health services.
3. Explain the economics of health insurance, adverse selection, and moral hazard.
4. Model hospital competition and market concentration.

## 7.1 Why healthcare markets differ

Healthcare violates standard market assumptions:
- **Information asymmetry:** physicians have more clinical knowledge than patients (principal-agent problem).
- **Uncertainty:** individuals cannot predict illness or cost.
- **Externalities:** communicable disease treatment benefits the community.
- **Public goods aspects:** public health infrastructure is non-excludable.

These market failures justify public intervention (insurance mandates, Medicare/Medicaid, regulation).

## 7.2 Demand for healthcare

Healthcare demand is influenced by:
- Price (often low direct elasticity due to insurance)
- Income (normal good)
- Health status (derived demand)
- Provider recommendations (supplier-induced demand)

**Price elasticity of demand** for hospital services is generally inelastic (−0.1 to −0.7 depending on service and insurance coverage).

## 7.3 Insurance economics

### Adverse selection

When individuals have private health information that insurers cannot observe, sicker individuals disproportionately buy insurance. This drives up premiums, causing healthier individuals to exit → premium death spiral.

Remedies: risk adjustment, mandates, community rating.

### Moral hazard

Insurance reduces the effective price of care, increasing utilization. Ex-ante moral hazard: reduced preventive behavior. Ex-post moral hazard: overuse of covered services.

Cost-sharing mechanisms (copays, deductibles) trade off insurance protection against moral hazard reduction.

## 7.4 Hospital competition

Hospital market concentration is measured by the Herfindahl-Hirschman Index (HHI):
```
HHI = Σ (market_share_i)²
```
- < 1500: competitive
- 1500–2500: moderately concentrated
- > 2500: highly concentrated

Higher concentration is associated with higher prices and reduced quality in markets where payers have limited bargaining power.

## 7.5 Julia application

```julia
# HHI calculation
market_shares = [0.40, 0.30, 0.20, 0.10]
hhi = sum(s^2 for s in market_shares)  # → 0.30

# Demand curve: simple elasticity estimate
# % change in quantity given % change in price
elasticity = -0.35
pct_price_change = 0.10
pct_qty_change = elasticity * pct_price_change  # → -0.035
```

## Key terms

- Information asymmetry
- Adverse selection
- Moral hazard
- Price elasticity of demand
- Herfindahl-Hirschman Index (HHI)
- Supplier-induced demand
- Risk adjustment

## Discussion questions

1. How does employer-sponsored insurance change the demand curve for healthcare services?
2. Explain why hospital mergers may increase prices even without changes in clinical quality.
3. Design a cost-sharing structure that minimizes moral hazard while preserving catastrophic coverage.
