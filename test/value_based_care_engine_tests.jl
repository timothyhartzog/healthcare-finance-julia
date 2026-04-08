include("../src/value_based_care_engine.jl")
using .ValueBasedCareEngine
using Test

@testset "ValueBasedCareEngine" begin
    @testset "value_score and qalys" begin
        @test value_score(0.8, 10000.0) ≈ 8e-5
        @test qalys(10.0, 0.9) ≈ 9.0
        @test_throws ArgumentError value_score(1.0, 0.0)
    end

    @testset "icer / cost_per_qaly_gained" begin
        @test icer(50000.0, 30000.0, 2.0, 1.0) ≈ 20000.0
        @test cost_per_qaly_gained(50000.0, 30000.0, 2.0, 1.0) ≈ 20000.0
        @test_throws ArgumentError icer(1.0, 0.0, 1.0, 1.0)
    end

    @testset "hcc_risk_score and population_risk_index" begin
        score = hcc_risk_score(0.8, [0.3, 0.2])
        @test score ≈ 1.3
        @test population_risk_index([1.0, 1.5, 2.0]) ≈ 1.5
        @test_throws ArgumentError population_risk_index(Float64[])
    end

    @testset "quality metrics" begin
        @test readmission_rate(10.0, 100.0) ≈ 0.1
        @test preventable_admissions_rate(5.0, 1000.0) ≈ 0.005
        @test hospital_acquired_condition_rate(2.0, 400.0) ≈ 0.005
        scores = [80.0, 90.0, 70.0]
        weights = [1.0, 2.0, 1.0]
        cqs = composite_quality_score(scores, weights)
        @test cqs ≈ 82.5
    end

    @testset "pay-for-performance" begin
        @test quality_payment_adjustment(1000.0, 1.02) ≈ 1020.0
        @test shared_savings(1_000_000.0, 950_000.0; shared_savings_rate=0.5) ≈ 25000.0
        @test shared_savings(1_000_000.0, 1_010_000.0) ≈ 0.0
    end

    @testset "ACO / bundled" begin
        @test aco_net_savings(50000.0, 1_000_000.0; min_savings_rate=0.02, shared_savings_rate=0.5) ≈ 25000.0
        @test aco_net_savings(5000.0, 1_000_000.0; min_savings_rate=0.02) ≈ 0.0
        @test episode_spending_pmpm(120_000.0, 12.0) ≈ 10_000.0
    end

    @testset "sdoh_adjusted_outcomes" begin
        @test sdoh_adjusted_outcomes(100.0, 0.0) ≈ 100.0
        @test sdoh_adjusted_outcomes(100.0, 1.0; sdoh_weight=0.1) ≈ 90.0
        @test_throws ArgumentError sdoh_adjusted_outcomes(100.0, 1.5)
    end
end
