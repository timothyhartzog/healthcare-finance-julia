using Test

@testset "Reimbursement Engine" begin
    # DRG payment
    @test drg_payment(6_000.0, 1.2, 10) ≈ 72_000.0
    @test drg_payment(6_000.0, 1.2, 10; outlier_threshold=500.0, outlier_rate=0.8) ≈ 72_000.0 + 4_000.0
    @test_throws ArgumentError drg_payment(0.0, 1.2, 10)

    # MS-DRG with adjustments
    p = ms_drg_payment(6_000.0, 1.5, 100, :none; wage_index=1.1, dsh_adjustment=0.02)
    @test p > 6_000.0 * 1.5 * 100   # DSH boosts payment
    @test_throws ArgumentError ms_drg_payment(6_000.0, 1.5, 10, :invalid)

    # APR-DRG
    @test apr_drg_payment(6_000.0, 1.0, 1, 100) < apr_drg_payment(6_000.0, 1.0, 4, 100)
    @test_throws ArgumentError apr_drg_payment(6_000.0, 1.0, 5, 100)

    # OPPS APC
    @test opps_apc_payment(85.0, 5.0, 100) ≈ 85.0 * 5.0 * 100

    # RBRVS RVU
    pay = rvu_to_payment(2.0, 1.5, 0.1, 36.0)
    @test pay ≈ (2.0 + 1.5 + 0.1) * 36.0
    total = rbrvs_payment(2.0, 1.5, 0.1, 36.0, 10)
    @test total ≈ pay * 10

    # Capitation / PMPM
    @test capitation_pmpm(1_200_000.0, 10_000.0) ≈ 120.0
    @test pmpm_trend(100.0, 0.04, 12) ≈ 100.0 * (1.04)^12

    # Payer contract net
    net = payer_contract_net(1_000.0, 0.60, 0.80, 50.0)
    @test net ≈ 1_000.0 * 0.60 * 0.80 + 50.0

    # Revenue cycle KPIs
    @test days_in_ar(5_000_000.0, 100_000.0) ≈ 50.0
    @test denial_rate(50, 1000) ≈ 0.05
    @test clean_claim_rate(970, 1000) ≈ 0.97
    @test gross_collection_rate(800_000.0, 1_000_000.0) ≈ 0.8
    @test cash_collection_efficiency(5_100_000.0, 5_000_000.0) ≈ 1.02
    @test bad_debt_rate(200_000.0, 10_000_000.0) ≈ 0.02
    @test charity_care_rate(300_000.0, 10_000_000.0) ≈ 0.03
    @test uncompensated_care_rate(200_000.0, 300_000.0, 10_000_000.0) ≈ 0.05

    # Scorecard
    sc = revenue_cycle_scorecard(days_ar=35.0, denial_rt=0.02, clean_claim_rt=0.98,
                                  cash_efficiency=1.03)
    @test sc.days_ar == :exceeds
    @test sc.denial_rate == :exceeds
    @test sc.clean_claim_rate == :exceeds
    @test sc.cash_efficiency == :exceeds
end
