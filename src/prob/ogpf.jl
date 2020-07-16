# Definitions for solving an optimal joint gas and power flow problem.

"Entry point into running the optimal gas-power flow problem."
function run_ogpf(g_file, p_file, g_type, p_type, optimizer; kwargs...)
    return run_model(
        g_file, p_file, g_type, p_type, optimizer, build_ogpf;
        gm_ref_extensions=[ref_add_price_zones!], kwargs...)
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

    # Variables related to the ogpf problem.
    variable_zone_demand(gm)
    variable_zone_demand_price(gm)
    variable_zone_pressure(gm)
    variable_pressure_price(gm)

    # This objective function minimizes operation cost.
    objective_min_ogpf_cost(gm, pm)
end
