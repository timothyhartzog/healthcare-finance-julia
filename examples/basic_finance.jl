using HealthcareFinance

cashflows = [100.0, 150.0, 200.0]
rate = 0.05

println("NPV:", npv(rate, cashflows))
