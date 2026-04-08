using Test

@testset "Accounting Engine" begin
    # Income statement
    stmt = income_statement(10_000_000.0, 3_000_000.0, 200_000.0, 300_000.0, 5_500_000.0;
                             other_income=100_000.0)
    @test stmt.gross_revenue ≈ 10_000_000.0
    @test stmt.net_patient_revenue ≈ 6_500_000.0
    @test stmt.total_operating_revenue ≈ 6_600_000.0
    @test stmt.operating_income ≈ 1_100_000.0
    @test stmt.total_margin ≈ 1_100_000.0 / 6_600_000.0  atol=1e-6

    # EBITDA
    @test ebitda(1_000_000.0, 500_000.0) ≈ 1_500_000.0
    @test ebitda(1_000_000.0, 500_000.0, 50_000.0) ≈ 1_550_000.0
    @test ebitda_margin(1_500_000.0, 6_000_000.0) ≈ 0.25

    # Total margin & operating margin
    @test total_margin(500_000.0, 5_000_000.0) ≈ 0.10
    @test operating_margin_hfma(500_000.0, 5_000_000.0) ≈ 0.10
    @test_throws ArgumentError total_margin(100.0, 0.0)

    # Operating leverage
    @test operating_leverage(2_000_000.0, 1_000_000.0) ≈ 2.0
    @test_throws ArgumentError operating_leverage(1.0, 0.0)

    # Balance sheet ratios
    bsr = balance_sheet_ratios(5_000_000.0, 2_000_000.0, 1_000_000.0,
                                30_000_000.0, 15_000_000.0, 15_000_000.0, 10_000_000.0)
    @test bsr.current_ratio ≈ 2.5
    @test bsr.quick_ratio ≈ 0.5
    @test bsr.debt_to_equity ≈ 1.0
    @test bsr.equity_multiplier ≈ 2.0
    @test bsr.long_term_debt_to_capitalization ≈ 10/(10+15)  atol=1e-6

    # Days cash on hand
    @test days_cash_on_hand(100_000_000.0, 500_000.0) ≈ 200.0

    # Cash flow (indirect)
    cf = cash_flow_indirect(1_000_000.0, 500_000.0, 50_000.0,
                             200_000.0, 150_000.0, 50_000.0, 2_000_000.0)
    @test cf.operating ≈ 1_000_000.0 + 500_000.0 + 50_000.0 - 200_000.0 + 150_000.0 - 50_000.0
    @test cf.investing ≈ -2_000_000.0

    # Straight-line depreciation
    @test straight_line_depreciation(1_000_000.0, 0.0, 10) ≈ 100_000.0
    @test_throws ArgumentError straight_line_depreciation(100.0, 200.0, 5)

    # MACRS
    schedule = macrs_depreciation_schedule(1_000_000.0, 7)
    @test length(schedule) == 8
    @test abs(sum(schedule) - 1_000_000.0) < 1.0   # sums to cost

    # Non-profit fund accounting
    summary = fund_accounting_summary(50_000_000.0, 5_000_000.0, 2_000_000.0)
    @test summary.total_net_assets ≈ 57_000_000.0
    @test summary.unrestricted_fraction ≈ 50/57  atol=1e-4

    ending = net_assets_change(100_000_000.0, 2_000_000.0, 500_000.0)
    @test ending ≈ 102_500_000.0

    # Community benefit rate
    @test charitable_community_benefit_rate(5_000_000.0, 100_000_000.0) ≈ 0.05
end
