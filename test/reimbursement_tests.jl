include("../src/reimbursement/reimbursement.jl")
using .Reimbursement
using Test

@testset "Reimbursement" begin
    @testset "DRG payment" begin
        base = drg_payment(6000.0, 1.5)
        @test base ≈ 9000.0
        with_adj = drg_payment(6000.0, 1.5; dsh_adjustment=0.05, ime_adjustment=0.02)
        @test with_adj ≈ 9000.0 * 1.07
        @test_throws ArgumentError drg_payment(0.0, 1.5)
    end

    @testset "DRG outlier payment" begin
        @test drg_outlier_payment(50000.0, 9000.0, 55000.0) ≈ 0.0
        pmt = drg_outlier_payment(80000.0, 9000.0, 30000.0; outlier_share=0.80)
        @test pmt ≈ 0.80 * (80000.0 - 39000.0)
    end

    @testset "case_mix_index" begin
        @test case_mix_index([1.0, 2.0, 3.0]) ≈ 2.0
        @test_throws ArgumentError case_mix_index(Float64[])
    end

    @testset "APC payment" begin
        @test apc_payment(100.0, 1.5) ≈ 150.0
        @test apc_payment(100.0, 1.5; wage_adjustment=1.1) ≈ 165.0
    end

    @testset "RVU payment" begin
        pmt = rvu_payment(1.5, 1.0, 0.1, 34.0)
        @test pmt ≈ (1.5 + 1.0 + 0.1) * 34.0
    end

    @testset "revenue cycle analytics" begin
        @test denial_rate(20.0, 200.0) ≈ 0.1
        @test clean_claim_rate(180.0, 200.0) ≈ 0.9
        @test Reimbursement.days_in_accounts_receivable(500_000.0, 5_000_000.0; days_in_period=365) ≈ 36.5
        @test collection_rate(900_000.0, 1_000_000.0) ≈ 0.9
        @test Reimbursement.net_collection_rate(800.0, 1000.0, 100.0) ≈ 800.0/900.0
        @test bad_debt_rate(20_000.0, 1_000_000.0) ≈ 0.02
    end

    @testset "payer mix" begin
        @test payer_mix_revenue([100.0, 200.0], [0.8, 0.5]) ≈ 180.0
        @test effective_reimbursement_rate([0.9, 0.6, 0.4], [0.5, 0.3, 0.2]) ≈ 0.71
    end

    @testset "bundled / episode" begin
        @test episode_payment_savings(30000.0, 28000.0) ≈ 2000.0
        @test episode_payment_savings(28000.0, 30000.0) ≈ -2000.0
    end

    @testset "cost-to-charge ratio" begin
        ccr = cost_to_charge_ratio(600_000.0, 1_000_000.0)
        @test ccr ≈ 0.6
        @test estimated_cost_from_charges(1_000_000.0, ccr) ≈ 600_000.0
    end
end
