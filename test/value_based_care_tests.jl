using Test

@testset "Value-Based Care Engine" begin
    @test value_score(10.0, 2.0) == 5.0
    @test qalys(3.0, 0.8) == 2.4

    @test_throws ArgumentError value_score(10.0, 0.0)
end
