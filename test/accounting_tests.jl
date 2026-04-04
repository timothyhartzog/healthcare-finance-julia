include("../src/accounting/accounting.jl")
using .Accounting
using Test

@testset "Accounting" begin
    @testset "liquidity ratios" begin
        @test current_ratio(200_000.0, 100_000.0) ≈ 2.0
        @test quick_ratio(200_000.0, 50_000.0, 100_000.0) ≈ 1.5
        @test cash_ratio(50_000.0, 100_000.0) ≈ 0.5
        @test_throws ArgumentError current_ratio(100.0, 0.0)
    end

    @testset "leverage ratios" begin
        @test debt_to_equity(400_000.0, 600_000.0) ≈ 4/6
        @test debt_to_assets(400_000.0, 1_000_000.0) ≈ 0.4
        @test equity_multiplier(1_000_000.0, 600_000.0) ≈ 1_000_000/600_000
        @test interest_coverage(500_000.0, 50_000.0) ≈ 10.0
    end

    @testset "profitability" begin
        @test gross_profit(1_000_000.0, 600_000.0) ≈ 400_000.0
        @test gross_profit_margin(1_000_000.0, 600_000.0) ≈ 0.4
        @test operating_income(1_000_000.0, 800_000.0) ≈ 200_000.0
        @test net_profit_margin(1_000_000.0, 900_000.0) ≈ 0.1
        @test return_on_assets(100_000.0, 1_000_000.0) ≈ 0.1
        @test return_on_equity(100_000.0, 500_000.0) ≈ 0.2
        ebitda_val = ebitda(200_000.0, 50_000.0, 10_000.0)
        @test ebitda_val ≈ 260_000.0
        @test ebitda_margin(260_000.0, 1_000_000.0) ≈ 0.26
    end

    @testset "efficiency ratios" begin
        @test asset_turnover(1_000_000.0, 500_000.0) ≈ 2.0
        dar = days_in_accounts_receivable(500_000.0, 5_000_000.0; days_in_period=365)
        @test dar ≈ 36.5
        dap = days_in_accounts_payable(100_000.0, 1_000_000.0; days_in_period=365)
        @test dap ≈ 36.5
        @test inventory_turnover(600_000.0, 100_000.0) ≈ 6.0
    end

    @testset "hospital-specific" begin
        @test occupancy_rate(36500.0, 100; days_in_period=365) ≈ 1.0
        @test average_length_of_stay(5000.0, 1000.0) ≈ 5.0
        @test cost_per_discharge(10_000_000.0, 2000.0) ≈ 5000.0
        @test revenue_per_adjusted_patient_day(3_650_000.0, 36500.0) ≈ 100.0
    end

    @testset "cost accounting" begin
        @test overhead_rate(200_000.0, 10_000.0) ≈ 20.0
        @test full_absorption_cost(100.0, 50.0, 30.0) ≈ 180.0
        @test contribution_margin_ratio(1000.0, 600.0) ≈ 0.4
        rates = [10.0, 5.0]
        usages = [100.0, 200.0]
        @test activity_based_cost(rates, usages, 100.0) ≈ 20.0
    end

    @testset "free cash flow" begin
        @test free_cash_flow(500_000.0, 150_000.0) ≈ 350_000.0
    end
end
