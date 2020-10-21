# Definitions for solving a combined gas and power flow with network expansion.


"Entry point for running gas and electric power expansion planning only."
function run_ne(g_file, p_file, link_file, g_type, p_type, optimizer; kwargs...)
    pm_ref_extensions = [_PM.ref_add_on_off_va_bounds!, _PM.ref_add_ne_branch!]

    return run_model(
        g_file, p_file, link_file, g_type, p_type, optimizer, build_ne;
        gm_ref_extensions=[_GM.ref_add_ne!], pm_ref_extensions=pm_ref_extensions, kwargs...)
end


"Construct the gas flow feasibility problem with demand being the cost model."
function build_ne(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel)
    # Gas-only-related variables and constraints.
    _GM.build_nels(gm)

    # Power-only-related variables and constraints.
    _PM.build_tnep(pm)

    # Gas-power related parts of the problem formulation.
    for i in _GM.ids(gm, :delivery)
       constraint_heat_rate_curve(pm, gm, i)
    end

    # Objective minimizes cost of network expansion.
    objective_min_ne_cost(pm, gm)
end
