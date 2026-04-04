using Genie, Genie.Router
using Stipple, StippleUI
using CSV, DataFrames

include("../../src/financial_engine.jl")
using .FinancialEngine

Base.@kwdef mutable struct DashboardPlusState <: ReactiveModel
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
    scenario_a_margin::R{Float64} = 0.0
    scenario_b_margin::R{Float64} = 0.0
    scenario_delta_margin::R{Float64} = 0.0
    scenario_a_revenue::R{Float64} = 1_000_000.0
    scenario_a_expense::R{Float64} = 800_000.0
    scenario_b_revenue::R{Float64} = 1_100_000.0
    scenario_b_expense::R{Float64} = 850_000.0
    chart_labels::R{Vector{String}} = ["Operating Margin", "Cost per Patient", "Break-even Units", "DRG Revenue", "Net Collection Rate"]
    chart_values::R{Vector{Float64}} = [0.0, 0.0, 0.0, 0.0, 0.0]
    upload_status::R{String} = "No file loaded"
end

function recalc!(model::DashboardPlusState)
    model.operating_margin_value[] = operating_margin(model.revenue[], model.expense[])
    model.cost_per_patient_value[] = cost_per_patient(model.total_cost[], model.encounters[])
    model.break_even_units_value[] = break_even_units(model.fixed_cost[], model.unit_price[], model.unit_variable_cost[])
    model.drg_revenue_value[] = drg_revenue(model.base_rate[], model.drg_weight[], model.cases[])
    model.net_collection_rate_value[] = net_collection_rate(model.payments[], model.charges[], model.contractual_adjustments[])
    model.chart_values[] = [
        model.operating_margin_value[],
        model.cost_per_patient_value[],
        model.break_even_units_value[],
        model.drg_revenue_value[],
        model.net_collection_rate_value[]
    ]
    return model
end

function compare_scenarios!(model::DashboardPlusState)
    model.scenario_a_margin[] = operating_margin(model.scenario_a_revenue[], model.scenario_a_expense[])
    model.scenario_b_margin[] = operating_margin(model.scenario_b_revenue[], model.scenario_b_expense[])
    model.scenario_delta_margin[] = model.scenario_b_margin[] - model.scenario_a_margin[]
    return model
end

function load_csv_summary!(model::DashboardPlusState, path::AbstractString)
    df = CSV.read(path, DataFrame)
    nrow(df) == 0 && error("CSV has no rows")
    if all(x -> x in names(df), [:revenue, :expense, :total_cost, :encounters])
        model.revenue[] = Float64(df[1, :revenue])
        model.expense[] = Float64(df[1, :expense])
        model.total_cost[] = Float64(df[1, :total_cost])
        model.encounters[] = Int(df[1, :encounters])
        model.upload_status[] = "Loaded summary row from CSV"
    else
        model.upload_status[] = "CSV loaded, but required columns not found: revenue, expense, total_cost, encounters"
    end
    recalc!(model)
    return model
end

function ui(model)
    page(model, class = "container", title = "Healthcare Finance Dashboard Plus", [
        heading("Healthcare Finance Dashboard", size = 2),
        p("Interactive dashboard with metrics, upload workflow, and scenario comparison."),
        row([
            cell(class = "st-col col-12 col-md-6", [
                heading("Financial Inputs", size = 4),
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
                heading("Calculated Outputs", size = 4),
                p(["Operating Margin: ", span("{{ operating_margin_value }}")]),
                p(["Cost per Patient: ", span("{{ cost_per_patient_value }}")]),
                p(["Break-even Units: ", span("{{ break_even_units_value }}")]),
                p(["DRG Revenue: ", span("{{ drg_revenue_value }}")]),
                p(["Net Collection Rate: ", span("{{ net_collection_rate_value }}")])
            ])
        ]),
        row([
            cell(class = "st-col col-12 col-md-6", [
                heading("Scenario Comparison", size = 4),
                numberfield("Scenario A Revenue", :scenario_a_revenue),
                numberfield("Scenario A Expense", :scenario_a_expense),
                numberfield("Scenario B Revenue", :scenario_b_revenue),
                numberfield("Scenario B Expense", :scenario_b_expense),
                btn("Compare Scenarios", @click("compare_scenarios"), color = "secondary"),
                p(["Scenario A Margin: ", span("{{ scenario_a_margin }}")]),
                p(["Scenario B Margin: ", span("{{ scenario_b_margin }}")]),
                p(["Margin Delta: ", span("{{ scenario_delta_margin }}")])
            ]),
            cell(class = "st-col col-12 col-md-6", [
                heading("Chart Data", size = 4),
                table(:chart_values, pagination = "false", flat = true, bordered = true,
                    columns = [Dict("name" => "metric", "label" => "Metric", "field" => "metric"),
                               Dict("name" => "value", "label" => "Value", "field" => "value")],
                    rows = :chart_rows)
            ])
        ]),
        row([
            cell(class = "st-col col-12", [
                heading("CSV Upload Workflow", size = 4),
                p("Upload handling is wired through the /load_sample route. Place a CSV on the server and call the route with a path query parameter."),
                p(["Status: ", span("{{ upload_status }}")])
            ])
        ])
    ])
end

model = DashboardPlusState() |> Stipple.init
recalc!(model)
compare_scenarios!(model)

Stipple.js_watch(model, :chart_values, "this.chart_rows = this.chart_labels.map((label, i) => ({ metric: label, value: this.chart_values[i] }))")

route("/") do
    html(ui(model))
end

route("/recalc", method = POST) do
    recalc!(model)
    "ok"
end

route("/compare", method = POST) do
    compare_scenarios!(model)
    "ok"
end

route("/load_sample") do
    path = Genie.Requests.params(:path, "")
    if isempty(path)
        model.upload_status[] = "No path provided"
    else
        try
            load_csv_summary!(model, path)
        catch err
            model.upload_status[] = "Load failed: $(err)"
        end
    end
    html(ui(model))
end

Genie.config.run_as_server = true
Genie.startup()
