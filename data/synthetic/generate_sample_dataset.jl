using Random
using DataFrames

function generate_dataset(n::Int)
    Random.seed!(369)
    df = DataFrame(
        revenue = rand(n) .* 10000,
        cost = rand(n) .* 8000,
        patients = rand(100:1000, n)
    )
    return df
end

println(generate_dataset(10))
