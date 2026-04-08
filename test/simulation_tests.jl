using Test

@testset "Simulation Engine" begin
    @test monte_carlo_mean(() -> 5.0, 10) == 5.0
    @test simulate_growth(100.0, 0.1, 3) ≈ [110.0, 121.0, 133.1]

    @test_throws ArgumentError monte_carlo_mean(() -> 1.0, 0)
end
