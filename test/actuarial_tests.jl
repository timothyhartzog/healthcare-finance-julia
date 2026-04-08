using Test

@testset "Actuarial Engine" begin
    # Claims triangle development
    tri = Float64[
        1000  1200  1300  1320;
        1100  1320  1430  0;
        1050  1260  0     0;
        1150  0     0     0
    ]
    ldfs = loss_development_factors(tri)
    @test length(ldfs) == 3
    @test all(ldf > 1.0 for ldf in ldfs)

    developed = claims_triangle_development(tri)
    @test size(developed) == (4, 4)
    @test developed[1, 4] ≈ 1320.0  atol=1e-6   # fully paid — no change
    @test developed[4, 4] > tri[4, 1]            # projected ultimate > latest paid

    ibnr = ibnr_reserve(tri)
    @test length(ibnr) == 4
    @test ibnr[1] ≈ 0.0  atol=1e-6              # first year fully developed
    @test all(x >= 0 for x in ibnr)

    # HCC risk score
    raf = hcc_risk_score(0.5, [0.3, 0.2, 0.15]; normalization_factor=1.0)
    @test raf ≈ 1.15
    @test hcc_prospective_score(1.2, 1.05) ≈ 1.26

    # PMPM by category
    cats = pmpm_by_category([1_200_000.0, 600_000.0], ["Inpatient", "Outpatient"], 10_000.0)
    @test length(cats) == 2
    @test cats[1].pmpm ≈ 120.0
    @test cats[2].category == "Outpatient"

    # Medical loss ratio
    @test medical_loss_ratio(850_000.0, 1_000_000.0) ≈ 0.85
    @test admin_expense_ratio(150_000.0, 1_000_000.0) ≈ 0.15

    # Premium development
    prem = premium_rate_development(300.0, 0.12, 0.03)
    @test prem > 300.0
    @test_throws ArgumentError premium_rate_development(300.0, 0.60, 0.50)

    # Utilization
    @test utilization_rate(100, 1000.0) ≈ 100.0
    @test admissions_per_thousand(500, 12_000.0) ≈ 500.0
    @test ed_visits_per_thousand(1200, 12_000.0) ≈ 1200.0

    # Frequency, severity, pure premium
    @test claim_frequency(2000, 1000.0) ≈ 2.0
    @test claim_severity(500_000.0, 1000.0) ≈ 500.0
    @test pure_premium(2.0, 500.0) ≈ 1000.0

    # Credibility
    @test credibility_weight(1082) ≈ 1.0
    @test credibility_weight(0) ≈ 0.0
    @test 0 < credibility_weight(500) < 1

    @test blended_rate(120.0, 100.0, 0.5) ≈ 110.0
    @test_throws ArgumentError blended_rate(120.0, 100.0, 1.5)
end
