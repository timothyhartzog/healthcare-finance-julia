using Test

@testset "Financial Engine — new functions" begin
    # IRR
    cfs = [-100_000.0, 30_000.0, 40_000.0, 50_000.0]
    r = irr(cfs)
    @test r isa Float64
    @test r > 0 && r < 1
    # Validate: NPV at IRR ≈ 0
    @test abs(npv(r, cfs)) < 1e-4

    # IRR returns missing when no sign change
    @test irr([100.0, 100.0]) === missing

    # MIRR
    m = mirr(cfs, 0.08, 0.10)
    @test m isa Float64
    @test m > 0

    # Discounted payback period
    dbp = discounted_payback_period(100_000.0, [30_000.0, 40_000.0, 50_000.0], 0.05)
    @test dbp isa Float64
    @test dbp > 0
    @test discounted_payback_period(1_000_000.0, [1.0, 1.0], 0.05) === missing

    # WACC
    w = wacc(500_000.0, 500_000.0, 0.10, 0.06, 0.21)
    @test w ≈ 0.10*0.5 + 0.06*0.79*0.5  atol=1e-6
    @test wacc(1_000_000.0, 0.0, 0.08, 0.05) ≈ 0.08

    # DSCR
    @test debt_service_coverage_ratio(500_000.0, 100_000.0, 300_000.0) ≈ 2.0
    @test_throws ArgumentError debt_service_coverage_ratio(100.0, 50.0, 0.0)

    # Interest coverage
    @test interest_coverage_ratio(300_000.0, 100_000.0) ≈ 3.0
    @test_throws ArgumentError interest_coverage_ratio(300_000.0, 0.0)

    # Profitability index
    @test profitability_index(50_000.0, 200_000.0) ≈ 1.25
    @test_throws ArgumentError profitability_index(50_000.0, 0.0)

    # Modified duration
    bond_cfs = [50.0, 50.0, 1050.0]
    md = modified_duration(bond_cfs, 0.05)
    @test md > 0

    # Lease vs buy
    result = lease_vs_buy(100_000.0, fill(15_000.0, 7), 10_000.0, 0.06, 7)
    @test result.preferred in (:lease, :buy)
    @test result.buy_pv > 0
    @test result.lease_pv > 0
end
