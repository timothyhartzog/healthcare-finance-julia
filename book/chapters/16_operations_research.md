# Chapter 16: Operations Research for Healthcare Finance — Optimization, Queuing, and Simulation

## Learning objectives

1. Formulate and solve linear programs for resource allocation in healthcare settings.
2. Apply queuing theory to ED throughput and bed capacity planning.
3. Use discrete-event simulation to model patient flow and financial impact.
4. Conduct scenario analysis and sensitivity analysis on strategic decisions.

## 16.1 Linear programming in healthcare

LP formulation:
```
Maximize/Minimize: c'x
Subject to: Ax ≤ b, x ≥ 0
```

**Healthcare examples:**
- **Staffing optimization:** minimize cost subject to patient-to-nurse ratios and shift coverage constraints
- **Service line mix:** maximize contribution margin subject to capacity constraints (beds, OR time, staff)
- **Supply chain:** minimize procurement cost subject to demand and inventory constraints

Using JuMP.jl:

```julia
using JuMP, HiGHS

model = Model(HiGHS.Optimizer)
@variable(model, x[1:3] >= 0)
@objective(model, Max, [500.0, 300.0, 400.0]' * x)
@constraint(model, [120.0, 80.0, 100.0]' * x <= 40000.0)   # OR minutes
@constraint(model, x[1] + x[2] + x[3] <= 500.0)              # bed capacity
optimize!(model)
```

## 16.2 Queuing theory

Hospital queuing models determine optimal capacity:

**M/M/c queue** (Erlang-C model):
- Arrival rate λ (patients/hour)
- Service rate μ per server (beds/hour)
- c servers (beds)
- Traffic intensity: ρ = λ / (cμ) — must be < 1 for stable queue

Key metrics:
- **P(waiting):** probability a patient must wait (Erlang-C formula)
- **Expected wait time:** W_q = P(waiting) / (cμ − λ)
- **Expected queue length:** L_q = λ × W_q

**Financial implication:** excess capacity wastes fixed costs; insufficient capacity causes diversion revenue loss.

## 16.3 Discrete-event simulation

DES models individual patient flows:
1. Patients arrive with inter-arrival time distribution
2. Each patient proceeds through a sequence of stages (triage, bed assignment, treatment, discharge)
3. Each stage has a duration distribution and resource requirement
4. Financial outcomes: revenue per patient, cost per hour, throughput rate

## 16.4 Scenario analysis

Define baseline, upside, and downside scenarios for key drivers:

| Driver | Downside | Base | Upside |
|---|---|---|---|
| Volume growth | −5% | +2% | +8% |
| Payer mix (commercial %) | 28% | 35% | 42% |
| Reimbursement rate change | −3% | 0% | +2% |
| Labor cost inflation | +6% | +3% | +1% |

## 16.5 Julia application

```julia
using .SimulationEngine

# Stochastic revenue simulation over 5 years
volume_sampler() = rand() * 0.08 - 0.02   # uniform(-2%, +6%) growth
rate_paths = simulate_stochastic_growth(50_000_000.0, volume_sampler, 5, 10_000)
mean_revenue_yr5 = mean(rate_paths[5, :])

# Scenario NPV analysis
scenarios = [
    (name="base",     cashflows=[1M, 1.1M, 1.2M, 1.3M, 1.4M], probability=0.6),
    (name="downside", cashflows=[0.8M, 0.9M, 0.9M, 1.0M, 1.0M], probability=0.25),
    (name="upside",   cashflows=[1.2M, 1.4M, 1.6M, 1.8M, 2.0M], probability=0.15),
]
result = scenario_npv(0.06, scenarios)
println("Expected NPV: ", result.expected_npv)
```

## Key terms

- Linear programming (LP)
- JuMP.jl
- M/M/c queue (Erlang-C)
- Discrete-event simulation (DES)
- Scenario analysis
- Traffic intensity (ρ)

## Discussion questions

1. How would you use LP to optimize a hospital's service line portfolio given OR capacity constraints?
2. A hospital ED runs at ρ = 0.92. What is the risk, and what are the options to reduce wait times?
3. Design a DES model to estimate the revenue impact of reducing ED door-to-physician time by 30 minutes.
