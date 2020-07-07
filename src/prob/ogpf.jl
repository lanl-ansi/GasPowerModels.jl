# Definitions for solving a optimal combined gas and power flow.

"Entry point into running the optimal gas-power flow problem."
function run_ogpf(g_file, p_file, g_type, p_type, optimizer; kwargs...)
    return run_model(g_file, p_file, g_type, p_type, optimizer, build_ogpf; kwargs...)
end

"Construct the optimal gas-power flow problem."
function build_ogpf(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel)
    # Gas-only related variables and constraints
    _GM.build_gf(gm)

    # Power-only related variables and constraints
    _PM.build_pf(pm)

    # Gas-power related parts of the problem formulation.
    for i in _GM.ids(gm, :delivery)
        constraint_heat_rate_curve(pm, gm, i)
    end

    # This objective function minimizes operation cost.
    objective_min_opf_cost(gm, pm)
end
