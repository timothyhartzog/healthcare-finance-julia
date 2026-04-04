# Demo for FinancialEngine

include("../src/financial_engine.jl")
using .FinancialEngine

println("--- Financial Engine Demo ---")

cf = [100.0, 150.0, 200.0]
println("NPV:", npv(0.05, cf))

println("ROI:", roi(120.0, 100.0))

println("Operating margin:", operating_margin(1000.0, 800.0))

println("Cost per patient:", cost_per_patient(500000.0, 10000))

println("Break-even units:", break_even_units(100000.0, 50.0, 30.0))

println("Payback period:", payback_period(200.0, [50.0, 75.0, 100.0]))

println("DRG revenue:", drg_revenue(6000.0, 1.2, 100))

println("Weighted payer rate:", weighted_payer_rate([0.8, 0.5, 0.3], [0.5, 0.3, 0.2]))

println("Net collection rate:", net_collection_rate(800.0, 1000.0, 100.0))
