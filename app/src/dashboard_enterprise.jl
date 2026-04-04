using Genie, Genie.Router
using JSON
using CSV, DataFrames

include("../../src/financial_engine.jl")
include("../../src/forecasting_models.jl")

using .FinancialEngine
using .ForecastingModels

# Simple in-memory storage
const DATASETS = Dict{String, DataFrame}()

function load_folder(path::String)
    files = filter(f -> endswith(f, ".csv"), readdir(path, join=true))
    for f in files
        try
            DATASETS[f] = CSV.read(f, DataFrame)
        catch
        end
    end
    return length(DATASETS)
end

function compute_metrics(df::DataFrame)
    if !all(x -> x in names(df), [:revenue, :expense])
        return Dict("error" => "Missing required columns")
    end

    rev = df.revenue
    exp = df.expense

    margin = operating_margin(sum(rev), sum(exp))

    forecast = forecast_series(rev, method=:linear_trend, horizon=5)

    return Dict(
        "margin" => margin,
        "revenue_series" => rev,
        "forecast" => forecast
    )
end

route("/") do
    "Enterprise Healthcare Finance Dashboard Running"
end

route("/load_folder") do
    path = Genie.Requests.params(:path, "")
    count = load_folder(path)
    return "Loaded $count datasets"
end

route("/analyze") do
    results = Dict()
    for (k, df) in DATASETS
        results[k] = compute_metrics(df)
    end
    return JSON.json(results)
end

route("/dashboard") do
    html = """
    <html>
    <head>
    <script src='https://cdn.jsdelivr.net/npm/chart.js'></script>
    </head>
    <body>
    <h2>Healthcare Finance Dashboard</h2>
    <canvas id='chart'></canvas>
    <script>
    fetch('/analyze').then(r=>r.json()).then(data=>{
        let first = Object.values(data)[0];
        let ctx = document.getElementById('chart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: first.revenue_series.map((_,i)=>i+1),
                datasets: [
                    {label:'Revenue', data:first.revenue_series},
                    {label:'Forecast', data:first.forecast}
                ]
            }
        });
    });
    </script>
    </body>
    </html>
    """
    return html
end

Genie.config.run_as_server = true
Genie.startup()
