using Test
using Random

@testset "Simulation Engine — extended" begin
    # Bootstrap CI
    Random.seed!(42)
    data = [100.0, 110.0, 90.0, 105.0, 95.0, 115.0, 85.0, 120.0]
    ci = bootstrap_ci(data; n_boot=500, ci_level=0.95)
    @test ci.lower < mean(data)
    @test ci.upper > mean(data)
    @test length(ci.distribution) == 500

    # Probabilistic sensitivity
    samplers = Dict{String, Function}(
        "rate" => () -> 0.05 + rand() * 0.05,
        "cost" => () -> 100_000.0 + randn() * 10_000.0,
    )
    psa = probabilistic_sensitivity(
        0.0,
        samplers,
        (p) -> p["rate"] * p["cost"];
        n_simulations=500
    )
    @test psa.mean_outcome > 0
    @test length(psa.outcomes) == 500

    # Tornado sensitivity
    tornado = tornado_sensitivity(
        50_000.0,
        Dict{String, Tuple{Float64, Float64}}(
            "volume"   => (8_000.0, 12_000.0),
            "price"    => (45.0, 55.0),
        ),
        (name, val) -> name == "volume" ? val * 5.0 : 10_000.0 * val
    )
    @test length(tornado) == 2
    @test tornado[1].swing >= tornado[2].swing   # sorted descending

    # Scenario analysis
    base = Dict("revenue" => 1_000_000.0, "cost" => 800_000.0)
    scenarios = Dict(
        "optimistic" => Dict("revenue" => 1_200_000.0, "cost" => 750_000.0),
        "pessimistic" => Dict("revenue" => 800_000.0, "cost" => 850_000.0),
    )
    results = scenario_analysis(
        base, scenarios,
        (p) -> p["revenue"] - p["cost"]
    )
    @test results["base"] ≈ 200_000.0
    @test results["optimistic"] > results["base"]
    @test results["pessimistic"] < results["base"]

    # Simulate claims
    Random.seed!(1)
    sim = simulate_claims(1000,
                          () -> rand(0:3),
                          () -> 500.0 + randn() * 100.0; seed=42)
    @test sim.total_claims >= 0
    @test sim.total_paid >= 0

    # Discrete event patient flow
    flow = discrete_event_patient_flow(200, 2.0, 2.5, 3;
                                        sim_duration=100.0, seed=7)
    @test flow.patients_served >= 0
    @test 0 <= flow.server_utilization <= 1
    @test flow.mean_wait >= 0
end
