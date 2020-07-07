# Definitions for running a optimal operations combined gas and power flow with network expansion.

"Entry point for running gas and electric power expansion planning with
demand-based pricing and a pressure penalty (in TPS paper)."
function run_neopf(g_file, p_file, g_type, p_type, optimizer; kwargs...)
    pm_ref_extensions = [_PM.ref_add_on_off_va_bounds!, _PM.ref_add_ne_branch!]
    return run_model(g_file, p_file, g_type, p_type, optimizer, build_neopf;
        gm_ref_extensions=[_GM.ref_add_ne!], pm_ref_extensions=pm_ref_extensions, kwargs...)
end

" Construct the gas flow feasbility problem with demand being the cost model"
function build_neopf(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel)
    # Gas-only-related variables and constraints.
    _GM.build_nels(gm)

    # Power-only-related variables and constraints.
    _PM.build_tnep(pm)

    # Gas-power related parts of the problem formulation.
    for i in _GM.ids(gm, :delivery)
       constraint_heat_rate_curve(pm, gm, i)
    end
    
    # Objective function minimizes demand and pressure cost.
    objective_min_neopf_cost(pm, gm)
end
