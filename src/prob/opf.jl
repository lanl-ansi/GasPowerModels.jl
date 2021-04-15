# Definitions for solving an optimal joint power flow problem.


"Entry point into running the optimal power flow problem."
function run_opf(g_file, p_file, link_file, gpm_type, optimizer; kwargs...)
    return run_model(
        g_file, p_file, link_file, gpm_type, optimizer, build_opf;
        ref_extensions = [ref_add_price_zones!], kwargs...)
end


"Entry point into running the optimal power flow problem."
function run_opf(data, gpm_type, optimizer; kwargs...)
    return run_model(
        data, gpm_type, optimizer, build_opf;
        ref_extensions = [ref_add_price_zones!], kwargs...)
end


"Construct the optimal power flow problem."
function build_opf(gpm::AbstractGasPowerModel)
    # Gas-only variables and constraints.
    _GM.build_gf(_get_gasmodel_from_gaspowermodel(gpm))

    # Power-only variables and constraints.
    _PM.build_pf(_get_powermodel_from_gaspowermodel(gpm))

    # Gas-power related parts of the problem formulation.
    for i in _get_interdependent_deliveries(gpm)
        constraint_heat_rate(gpm, i)
    end

    # Variables related to the OPF problem.
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

    # Objective minimizes operation cost.
    objective_min_opf_cost(gpm)
end
