using Test

@testset "Financial Engine" begin
    @test npv(0.05, [100.0, 100.0]) > 0
    @test roi(120.0, 100.0) ≈ 0.2
    @test operating_margin(1000.0, 800.0) ≈ 0.2
    @test cost_per_patient(1000.0, 10) == 100.0
    @test break_even_units(100.0, 10.0, 5.0) == 20.0
    @test payback_period(250.0, [100.0, 100.0, 100.0]) ≈ 2.5
    @test drg_revenue(6000.0, 1.2, 10) == 72_000.0
    @test weighted_payer_rate([100.0, 80.0], [0.7, 0.3]) ≈ 94.0
    @test net_collection_rate(900.0, 1200.0, 200.0) == 0.9

    @test_throws ArgumentError roi(10.0, 0.0)
    @test_throws ArgumentError operating_margin(0.0, 10.0)
    @test_throws ArgumentError cost_per_patient(10.0, 0.0)
    @test_throws ArgumentError break_even_units(100.0, 10.0, 10.0)
    @test_throws ArgumentError weighted_payer_rate([1.0], [0.5, 0.5])
end
