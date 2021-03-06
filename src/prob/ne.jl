# Definitions for solving a combined gas and power flow with network expansion.


"Entry point for running gas and electric power expansion planning only."
function run_ne(g_file, p_file, link_file, gpm_type, optimizer; kwargs...)
    extensions = [_GM.ref_add_ne!, _PM.ref_add_on_off_va_bounds!, _PM.ref_add_ne_branch!]

    return run_model(
        g_file, p_file, link_file, gpm_type, optimizer, build_ne;
        ref_extensions = extensions, kwargs...)
end


"Entry point for running gas and electric power expansion planning only."
function run_ne(data, gpm_type, optimizer; kwargs...)
    extensions = [_GM.ref_add_ne!, _PM.ref_add_on_off_va_bounds!, _PM.ref_add_ne_branch!]

    return run_model(
        data, gpm_type, optimizer, build_ne; ref_extensions = extensions, kwargs...)
end


"Construct the gas flow feasibility problem with demand being the cost model."
function build_ne(gpm::AbstractGasPowerModel)
    # Gas-only variables and constraints
    _GM.build_nels(_get_gasmodel_from_gaspowermodel(gpm))

    # Power-only variables and constraints
    _PM.build_tnep(_get_powermodel_from_gaspowermodel(gpm))

    # Gas-power related parts of the problem formulation.
    for i in _get_interdependent_deliveries(gpm)
        constraint_heat_rate(gpm, i)
    end

    # Objective minimizes cost of network expansion.
    objective_min_ne_cost(gpm)
end
