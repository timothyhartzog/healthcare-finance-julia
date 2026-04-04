using Genie, Genie.Router
using Stipple, StippleUI
using DataFrames, CSV

include("../../src/financial_engine.jl")
using .FinancialEngine

Base.@kwdef mutable struct ExtendedDashboard <: ReactiveModel
    file_loaded::R{Bool} = false
    avg_revenue::R{Float64} = 0.0
    avg_cost::R{Float64} = 0.0
    margin::R{Float64} = 0.0
end

function process_file(path)
    df = CSV.read(path, DataFrame)
    avg_rev = mean(df.revenue)
    avg_cost = mean(df.cost)
    margin = operating_margin(avg_rev, avg_cost)
    return avg_rev, avg_cost, margin
end

function ui(model)
    page(model, [
        heading("Extended Dashboard", size=2),
        filefield("Upload CSV", :file),
        btn("Process", @click("process")),
        p(["Average Revenue: ", span("{{ avg_revenue }}")]),
        p(["Average Cost: ", span("{{ avg_cost }}")]),
        p(["Margin: ", span("{{ margin }}")])
    ])
end

model = ExtendedDashboard() |> Stipple.init

route("/") do
    html(ui(model))
end

route("/process", method=POST) do
    # placeholder path
    avg_rev, avg_cost, margin = process_file("data/sample.csv")
    model.avg_revenue[] = avg_rev
    model.avg_cost[] = avg_cost
    model.margin[] = margin
    "ok"
end

Genie.config.run_as_server = true
Genie.startup()
