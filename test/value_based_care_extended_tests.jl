using Test

@testset "Value-Based Care Engine — extended" begin
    # ACO benchmark
    bench = aco_benchmark(12_000.0, 0.03, 1.05)
    @test bench ≈ 12_000.0 * 1.03 * 1.05  atol=1e-6

    # MSSP shared savings
    savings = mssp_shared_savings(12_000.0, 11_500.0, 5_000, 0.50;
                                   minimum_savings_rate=0.02)
    @test savings > 0

    # Below MSR — no sharing
    below_msr = mssp_shared_savings(12_000.0, 11_900.0, 5_000, 0.50;
                                     minimum_savings_rate=0.02)
    @test below_msr ≈ 0.0

    # MSSP shared losses
    losses = mssp_shared_losses(12_000.0, 12_500.0, 5_000, 0.60;
                                 minimum_loss_rate=0.02)
    @test losses > 0

    # No losses
    @test mssp_shared_losses(12_000.0, 11_900.0, 5_000, 0.60) ≈ 0.0

    # Total cost of care
    @test total_cost_of_care(1000.0, 500.0, 400.0, 200.0) ≈ 2100.0
    @test tcoc_pmpm(2_100_000.0, 10_000.0) ≈ 210.0

    # HEDIS composite
    hc = hedis_composite_score([0.80, 0.75, 0.90], [0.4, 0.3, 0.3])
    @test hc ≈ 0.80*0.4 + 0.75*0.3 + 0.90*0.3
    @test_throws ArgumentError hedis_composite_score([0.8, 0.7], [0.6, 0.6])

    # Star ratings
    thresholds = [[0.60, 0.70, 0.80, 0.90],
                  [0.55, 0.65, 0.75, 0.85]]
    sr = star_rating_score([0.85, 0.78], thresholds)
    @test sr.measure_stars[1] == 4
    @test sr.measure_stars[2] == 4

    # Care gap ROI
    cgr = care_gap_closure_roi(1000, 10.0, 150.0, 20_000.0)
    @test cgr.net_benefit ≈ 1000*150 - (1000*10 + 20_000)
    @test cgr.roi isa Float64

    # Readmission reduction savings
    rrs = readmission_reduction_savings(0.15, 0.12, 10_000, 15_000.0)
    @test rrs ≈ 0.03 * 10_000 * 15_000.0
    @test_throws ArgumentError readmission_reduction_savings(0.10, 0.15, 10_000, 15_000.0)

    # Bundled payment gainshare
    @test bundled_payment_gainshare(25_000.0, 23_000.0, 0.50) ≈ 1_000.0
    @test bundled_payment_gainshare(25_000.0, 30_000.0, 0.50;
                                     stop_loss_threshold=3_000.0) ≈ -1_500.0

    # SDOH financial impact
    sdoh = sdoh_financial_impact(500, 500.0, 0.15, 8_000.0)
    @test sdoh.total_savings ≈ 500 * 8_000.0 * 0.15
    @test sdoh.roi isa Float64
end
