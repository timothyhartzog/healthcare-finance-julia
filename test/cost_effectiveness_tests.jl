using Test

@testset "Cost Effectiveness Engine" begin
    # Markov cohort
    P = [0.7 0.2 0.1;
         0.0 0.6 0.4;
         0.0 0.0 1.0]   # absorbing death state
    cohort = [1000.0, 0.0, 0.0]
    traces = markov_cohort(P, cohort, 10)
    @test size(traces) == (11, 3)
    @test all(row -> abs(sum(row) - 1000.0) < 1e-6, eachrow(traces))  # cohort conserved

    # Markov cycle QALYs
    utils = [0.8, 0.5, 0.0]
    qaly_vec = markov_cycle_traces(traces, utils; discount_rate=0.03)
    @test length(qaly_vec) == 10
    @test all(q >= 0 for q in qaly_vec)

    # ICER
    @test icer(20_000.0, 0.5) ≈ 40_000.0
    @test_throws ArgumentError icer(10_000.0, 0.0)

    # Dominance
    @test cea_dominant(10_000.0, 2.0, 15_000.0, 1.5) == :a_dominates
    @test cea_dominant(15_000.0, 1.5, 10_000.0, 2.0) == :b_dominates
    @test cea_dominant(15_000.0, 2.0, 10_000.0, 1.5) == :neither

    # NMB
    @test net_monetary_benefit(0.5, 20_000.0, 50_000.0) ≈ 5_000.0
    @test net_monetary_benefit(0.5, 30_000.0, 50_000.0) ≈ -5_000.0

    # WTP threshold
    @test willingness_to_pay_threshold(25_000.0, 0.5) ≈ 50_000.0

    # Outcome metrics
    @test daly(2.0, 5.0, 0.4) ≈ 4.0
    @test life_years_gained(10.0, 8.0) ≈ 2.0
    @test qaly_adjusted_life_years(5.0, 0.8) ≈ 4.0
    @test_throws ArgumentError daly(1.0, 1.0, 1.5)

    # Budget impact analysis
    bia = budget_impact_analysis(10_000, 0.20, 5_000.0, 3_000.0, 0.0; horizon_years=3)
    @test length(bia.annual_impacts) == 3
    @test bia.annual_impacts[1] > 0   # new therapy is more expensive
    @test bia.cumulative_impact == sum(bia.annual_impacts)

    # Decision tree EV
    ev = decision_tree_ev([100_000.0, -50_000.0, 20_000.0], [0.3, 0.5, 0.2])
    @test ev ≈ 100_000.0*0.3 + (-50_000.0)*0.5 + 20_000.0*0.2
    @test_throws ArgumentError decision_tree_ev([1.0, 2.0], [0.3, 0.5])

    # PSA
    psa = probabilistic_sensitivity_analysis(
        () -> rand() * 10_000,
        () -> rand() * 0.5,
        1000; wtp_threshold=50_000.0
    )
    @test length(psa.nmbs) == 1000
    @test 0 <= psa.fraction_cost_effective <= 1
end
