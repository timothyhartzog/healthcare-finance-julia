include("../src/financial_engine.jl")
using .FinancialEngine
using Test

@testset "Financial Engine" begin
    @test npv(0.05, [100.0, 100.0]) > 0
    @test roi(120.0, 100.0) ≈ 0.2
    @test operating_margin(1000.0, 800.0) ≈ 0.2
    @test cost_per_patient(1000.0, 10) == 100.0
    @test break_even_units(100.0, 10.0, 5.0) == 20.0
end
