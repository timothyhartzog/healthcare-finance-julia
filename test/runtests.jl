using HealthcareFinance
using Test

@testset "Public API exports" begin
    @test isdefined(HealthcareFinance, :operating_margin)
    @test isdefined(HealthcareFinance, :forecast_series)
    @test isdefined(HealthcareFinance, :simple_linear_regression)
    @test isdefined(HealthcareFinance, :simulate_growth)
    @test isdefined(HealthcareFinance, :value_score)
    # New modules
    @test isdefined(HealthcareFinance, :irr)
    @test isdefined(HealthcareFinance, :wacc)
    @test isdefined(HealthcareFinance, :income_statement)
    @test isdefined(HealthcareFinance, :ms_drg_payment)
    @test isdefined(HealthcareFinance, :ibnr_reserve)
    @test isdefined(HealthcareFinance, :markov_cohort)
    @test isdefined(HealthcareFinance, :operating_budget)
    @test isdefined(HealthcareFinance, :mssp_shared_savings)
    @test isdefined(HealthcareFinance, :holt_winters_additive)
    @test isdefined(HealthcareFinance, :bootstrap_ci)
end

include("financial_engine_tests.jl")
include("financial_engine_extended_tests.jl")
include("forecasting_tests.jl")
include("forecasting_extended_tests.jl")
include("econometrics_tests.jl")
include("econometrics_extended_tests.jl")
include("simulation_tests.jl")
include("simulation_extended_tests.jl")
include("value_based_care_tests.jl")
include("value_based_care_extended_tests.jl")
include("accounting_tests.jl")
include("reimbursement_tests.jl")
include("actuarial_tests.jl")
include("cost_effectiveness_tests.jl")
include("budgeting_tests.jl")

