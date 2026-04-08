using HealthcareFinance
using Test

@testset "Public API exports" begin
    @test isdefined(HealthcareFinance, :operating_margin)
    @test isdefined(HealthcareFinance, :forecast_series)
    @test isdefined(HealthcareFinance, :simple_linear_regression)
    @test isdefined(HealthcareFinance, :simulate_growth)
    @test isdefined(HealthcareFinance, :value_score)
end

include("financial_engine_tests.jl")
include("econometrics_engine_tests.jl")
include("simulation_engine_tests.jl")
include("value_based_care_engine_tests.jl")
include("forecasting_models_tests.jl")
include("accounting_tests.jl")
include("reimbursement_tests.jl")
include("forecasting_tests.jl")
