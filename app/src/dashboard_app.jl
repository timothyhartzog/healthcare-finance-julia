using Genie, Genie.Router
using Stipple, StippleUI

include("../../src/financial_engine.jl")
using .FinancialEngine

Base.@kwdef mutable struct DashboardState <: ReactiveModel
    revenue::R{Float64} = 1_000_000.0
    expense::R{Float64} = 800_000.0
    total_cost::R{Float64} = 500_000.0
    encounters::R{Int64} = 10_000
    fixed_cost::R{Float64} = 100_000.0
    unit_price::R{Float64} = 50.0
    unit_variable_cost::R{Float64} = 30.0
    base_rate::R{Float64} = 6_000.0
    drg_weight::R{Float64} = 1.2
    cases::R{Int64} = 100
    payments::R{Float64} = 800_000.0
    charges::R{Float64} = 1_000_000.0
    contractual_adjustments::R{Float64} = 100_000.0
    operating_margin_value::R{Float64} = 0.0
    cost_per_patient_value::R{Float64} = 0.0
    break_even_units_value::R{Float64} = 0.0
    drg_revenue_value::R{Float64} = 0.0
    net_collection_rate_value::R{Float64} = 0.0
end

function recalc!(model::DashboardState)
    model.operating_margin_value[] = operating_margin(model.revenue[], model.expense[])
    model.cost_per_patient_value[] = cost_per_patient(model.total_cost[], model.encounters[])
    model.break_even_units_value[] = break_even_units(model.fixed_cost[], model.unit_price[], model.unit_variable_cost[])
    model.drg_revenue_value[] = drg_revenue(model.base_rate[], model.drg_weight[], model.cases[])
    model.net_collection_rate_value[] = net_collection_rate(model.payments[], model.charges[], model.contractual_adjustments[])
    return model
end

function ui(model)
    page(model, class = "container", title = "Healthcare Finance Dashboard", [
        heading("Healthcare Finance Dashboard", size = 2),
        p("Interactive MBA-level financial controls for healthcare system analysis."),
        row([
            cell(class = "st-col col-12 col-md-6", [
                heading("Inputs", size = 4),
                numberfield("Revenue", :revenue),
                numberfield("Expense", :expense),
                numberfield("Total Cost", :total_cost),
                numberfield("Encounters", :encounters),
                numberfield("Fixed Cost", :fixed_cost),
                numberfield("Unit Price", :unit_price),
                numberfield("Unit Variable Cost", :unit_variable_cost),
                numberfield("Base Rate", :base_rate),
                numberfield("DRG Weight", :drg_weight),
                numberfield("Cases", :cases),
                numberfield("Payments", :payments),
                numberfield("Charges", :charges),
                numberfield("Contractual Adjustments", :contractual_adjustments),
                btn("Recalculate", @click("recalc"), color = "primary")
            ]),
            cell(class = "st-col col-12 col-md-6", [
                heading("Outputs", size = 4),
                p(["Operating Margin: ", span("{{ operating_margin_value }}")]),
                p(["Cost per Patient: ", span("{{ cost_per_patient_value }}")]),
                p(["Break-even Units: ", span("{{ break_even_units_value }}")]),
                p(["DRG Revenue: ", span("{{ drg_revenue_value }}")]),
                p(["Net Collection Rate: ", span("{{ net_collection_rate_value }}")])
            ])
        ])
    ])
end

model = DashboardState() |> Stipple.init
recalc!(model)

on(model.isready) do _
    recalc!(model)
end

route("/") do
    html(ui(model))
end

route("/recalc", method = POST) do
    recalc!(model)
    "ok"
end

Genie.config.run_as_server = true
Genie.startup()
