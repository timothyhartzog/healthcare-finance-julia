# Chapter 11: Regression Analysis for Healthcare Finance

## Learning objectives

1. Apply simple and multiple OLS regression to hospital cost and utilization data.
2. Interpret regression coefficients in a healthcare financial context.
3. Diagnose regression assumptions using residual analysis and VIF.
4. Use logistic regression for binary outcomes (readmission, denial prediction).

## 11.1 Simple linear regression

For a single predictor:
```
y = β₀ + β₁x + ε
```

Estimated by OLS: minimizes Σ(yᵢ − ŷᵢ)².

**Healthcare example:** Predict average length of stay (y) from case mix index (x).

## 11.2 Multiple regression

For p predictors:
```
y = β₀ + β₁x₁ + β₂x₂ + ... + βₚxₚ + ε
```

Estimated via normal equations:
```
β = (X'X)⁻¹ X'y
```

**Healthcare example:** Predict cost per discharge from CMI, bed count, teaching status, payer mix.

## 11.3 Model diagnostics

- **R²:** proportion of variance explained (higher is better, but can be inflated by adding variables)
- **Adjusted R²:** penalizes for additional predictors
- **RMSE:** root mean squared error (same units as y)
- **VIF:** variance inflation factor — VIF > 10 indicates collinearity problems
- **Residual plots:** check for heteroskedasticity and non-linearity

## 11.4 Logistic regression

For binary outcomes (readmitted: yes/no; claim denied: yes/no):
```
P(y=1|x) = sigmoid(β₀ + β₁x₁ + ... + βₚxₚ)
```

Coefficients are log-odds. Exponentiate to obtain odds ratios.

**Healthcare example:** Predict 30-day readmission probability from discharge diagnoses, age, LOS, payer.

## 11.5 Julia application

```julia
include("src/econometrics_engine.jl")
using .EconometricsEngine

# Simple regression: ALOS ~ CMI
cmi = [0.9, 1.1, 1.3, 1.6, 2.0, 1.4, 1.8, 1.2]
alos = [3.2, 3.8, 4.5, 5.1, 6.8, 4.8, 6.0, 4.1]
model = simple_linear_regression(cmi, alos)
preds = predict_linear(model, cmi)
println("R²: ", r_squared(alos, preds))

# Multiple regression: cost ~ CMI + beds + teaching
X = hcat(cmi, [120, 200, 150, 300, 500, 180, 400, 160.0],
               [0, 0, 1, 1, 1, 0, 1, 0.0])
y = [8500.0, 9200.0, 11000.0, 13500.0, 18000.0, 10500.0, 16000.0, 9800.0]
m = ols_regression(X, y)

# Logistic regression: readmission
Xr = hcat([3.0, 5.0, 7.0, 4.0, 9.0, 2.0])
yr = [0.0, 0.0, 1.0, 0.0, 1.0, 0.0]
lr_model = logistic_regression(Xr, yr; lr=0.1, epochs=2000)
probs = predict_logistic(lr_model, Xr)
```

## Key terms

- Ordinary Least Squares (OLS)
- Coefficient of determination (R²)
- Variance Inflation Factor (VIF)
- Logistic regression
- Odds ratio
- Heteroskedasticity

## Discussion questions

1. A regression of cost per discharge on CMI yields R² = 0.72. What explains the remaining 28%?
2. When is logistic regression more appropriate than linear probability model for a readmission analysis?
3. How would multicollinearity between CMI and teaching status affect your regression estimates?
