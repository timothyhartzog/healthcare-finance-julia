"""
Canonical dashboard launcher.

Usage:
  julia --project=app app/src/app.jl             # launches consolidated dashboard
  DASHBOARD_MODE=enterprise julia --project=app app/src/app.jl
"""

const DASHBOARD_MODE = lowercase(get(ENV, "DASHBOARD_MODE", "consolidated"))

if DASHBOARD_MODE == "consolidated"
    include("dashboard_plus.jl")
elseif DASHBOARD_MODE == "enterprise"
    include("dashboard_enterprise.jl")
elseif DASHBOARD_MODE == "extended"
    include("dashboard_extended.jl")
else
    error("Unsupported DASHBOARD_MODE=$(DASHBOARD_MODE). Supported: consolidated, enterprise, extended")
end
