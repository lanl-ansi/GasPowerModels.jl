# Definitions for solving an optimal joint power flow problem with network expansion.

"Entry point for running gas and electric power expansion planning with demand-based pricing
and a pressure penalty (in TPS paper)."
function run_ne_opf(g_file, p_file, link_file, gpm_type, optimizer; kwargs...)
    ref_extensions = [_GM.ref_add_ne!, ref_add_price_zones!,
        _PM.ref_add_on_off_va_bounds!, _PM.ref_add_ne_branch!]

    return run_model(
        g_file, p_file, link_file, gpm_type, optimizer, build_ne_opf;
        ref_extensions = ref_extensions, kwargs...)
end


"Entry point for running gas and electric power expansion planning with demand-based pricing
and a pressure penalty (in TPS paper)."
function run_ne_opf(data, gpm_type, optimizer; kwargs...)
    ref_extensions = [_GM.ref_add_ne!, ref_add_price_zones!,
        _PM.ref_add_on_off_va_bounds!, _PM.ref_add_ne_branch!]

    return run_model(
        data, gpm_type, optimizer, build_ne_opf; ref_extensions = ref_extensions, kwargs...)
end


"Construct the expansion planning with optimal power flow problem."
function build_ne_opf(gpm::AbstractGasPowerModel)
    # Gas-only variables and constraints.
    _GM.build_nels(_get_gasmodel_from_gaspowermodel(gpm))

    # Power-only variables and constraints.
    _PM.build_tnep(_get_powermodel_from_gaspowermodel(gpm))

    # Gas-power related parts of the problem formulation.
    for i in _get_interdependent_deliveries(gpm)
        constraint_heat_rate(gpm, i)
    end

    # Variables related to the NE OGPF problem.
    variable_zone_demand(gpm)
    variable_zone_demand_price(gpm)
    variable_zone_pressure(gpm)
    variable_pressure_price(gpm)

    # Constraints related to price zones.
    for (i, price_zone) in _IM.ref(gpm, _GM.gm_it_sym, :price_zone)
        constraint_zone_demand(gpm, i)
        constraint_zone_demand_price(gpm, i)
        constraint_zone_pressure(gpm, i)
        constraint_pressure_price(gpm, i)
    end

    # Objective minimizes network expansion, demand, and pressure cost.
    objective_min_ne_opf_cost(gpm)
end
