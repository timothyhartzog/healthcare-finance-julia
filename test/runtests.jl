using HealthcareFinance
using Test

@testset "Basic Financial Tests" begin
    cf = [100.0, 100.0, 100.0]
    result = npv(0.05, cf)
    @test result > 0
end
