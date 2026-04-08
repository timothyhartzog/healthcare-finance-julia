include("../src/simulation_engine.jl")
using .SimulationEngine
using Test

@testset "SimulationEngine" begin
    @testset "monte_carlo_mean" begin
        μ = monte_carlo_mean(() -> 1.0, 100)
        @test μ ≈ 1.0
        @test_throws ArgumentError monte_carlo_mean(() -> 1.0, 0)
    end

    @testset "monte_carlo_percentile" begin
        p50 = monte_carlo_percentile(() -> rand(), 10000, 50)
        @test 0.3 < p50 < 0.7
        @test_throws ArgumentError monte_carlo_percentile(() -> rand(), 10, 101)
    end

    @testset "simulate_growth" begin
        vals = simulate_growth(100.0, 0.10, 3)
        @test length(vals) == 3
        @test vals[1] ≈ 110.0
        @test vals[2] ≈ 121.0
        @test vals[3] ≈ 133.1
        @test_throws ArgumentError simulate_growth(100.0, 0.1, 0)
    end

    @testset "simulate_stochastic_growth" begin
        mat = simulate_stochastic_growth(100.0, () -> 0.05, 5, 3)
        @test size(mat) == (5, 3)
        @test all(mat .> 0)
    end

    @testset "one_way_sensitivity" begin
        f(x) = 2 * x
        result = one_way_sensitivity(f, 10.0, 5.0, 15.0)
        @test result.base_output ≈ 20.0
        @test result.low_output ≈ 10.0
        @test result.high_output ≈ 30.0
    end

    @testset "tornado_values" begin
        f(x) = x^2
        params = [(name="A", low=1.0, base=5.0, high=9.0),
                  (name="B", low=4.0, base=5.0, high=6.0)]
        tv = tornado_values(params, f)
        @test tv[1].name == "A"
        @test tv[1].swing > tv[2].swing
    end

    @testset "scenario_npv" begin
        scenarios = [
            (name="base",  cashflows=[100.0, 100.0], probability=0.5),
            (name="upside", cashflows=[200.0, 200.0], probability=0.5),
        ]
        result = scenario_npv(0.05, scenarios)
        @test length(result.scenarios) == 2
        @test result.expected_npv > 0
    end

    @testset "bootstrap_mean and bootstrap_ci" begin
        import Random
        rng = Random.MersenneTwister(42)
        data = [1.0, 2.0, 3.0, 4.0, 5.0]
        bm = bootstrap_mean(data, 500; rng=rng)
        @test length(bm) == 500
        rng2 = Random.MersenneTwister(42)
        lo, hi = bootstrap_ci(data, 500; rng=rng2)
        @test lo < hi
        @test_throws ArgumentError bootstrap_mean(Float64[], 10)
    end
end
