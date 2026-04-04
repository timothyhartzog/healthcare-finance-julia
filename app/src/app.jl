using Genie
using Genie.Router
using Stipple
using StippleUI

Genie.config.run_as_server = true

route("/") do
    "Healthcare Finance Dashboard Running"
end

Genie.startup()
