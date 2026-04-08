using Test

@testset "Budgeting Engine" begin
    # Operating budget
    bud = operating_budget(500_000.0, 20.0, 10_000.0, 50.0)
    @test bud.revenue ≈ 500_000.0
    @test bud.variable_costs ≈ 200_000.0
    @test bud.total_costs ≈ 700_000.0
    @test bud.operating_income ≈ -200_000.0
    @test bud.contribution_margin ≈ 300_000.0

    # Flex budget
    flex = flex_budget(500_000.0, 20.0, 12_000.0, 50.0)
    @test flex.revenue ≈ 600_000.0

    # Variance analysis
    @test volume_variance(30.0, 12_000.0, 10_000.0) ≈ 60_000.0
    @test price_variance(55.0, 50.0, 12_000.0) ≈ 60_000.0
    @test efficiency_variance(20.0, 25_000.0, 2.5, 10_000.0) ≈ 0.0  # actual = standard

    # Mix variance
    mv = mix_variance([600.0, 400.0], [500.0, 500.0], [40.0, 30.0])
    @test mv.total_mix_variance isa Float64

    # Rate-volume decomposition
    rv = rate_volume_variance(620_000.0, 500_000.0, 12_000.0, 10_000.0, 50.0)
    @test rv.total_variance ≈ 120_000.0
    @test rv.volume_variance ≈ 100_000.0  # 50 × 2000
    @test rv.rate_variance ≈ 20_000.0

    # Budget-to-actual
    bav = budget_to_actual_variance(1_000_000.0, 950_000.0)
    @test bav.dollar_variance ≈ 50_000.0
    @test bav.pct_variance ≈ 0.05

    # Capital budget ranking
    projects = [
        (name="MRI Machine", npv=500_000.0, strategic_score=8.0),
        (name="EHR Upgrade", npv=200_000.0, strategic_score=9.5),
        (name="Parking Garage", npv=100_000.0, strategic_score=3.0),
    ]
    ranked = capital_budget_rank(projects; npv_weight=0.7, strategic_weight=0.3)
    @test length(ranked) == 3
    @test ranked[1].composite_score >= ranked[2].composite_score

    # ZBB score
    @test zero_based_budget_score(8.0, 7.0, 6.0) isa Float64
    @test_throws ArgumentError zero_based_budget_score(11.0, 7.0, 6.0)

    # Rolling forecast
    rf = rolling_forecast_update(4_200_000.0, 7, 12, 7_000_000.0)
    @test rf.projected_annual ≈ 4_200_000.0 / 7 * 12
    @test rf.variance_to_budget ≈ 7_000_000.0 - rf.projected_annual
end
