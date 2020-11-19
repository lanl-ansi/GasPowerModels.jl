# Definitions for solving a joint minimum load shedding problem.


"Entry point into running the minimum load shedding problem."
function run_ls(g_file, p_file, link_file, gpm_type, optimizer; kwargs...)
    return run_model(g_file, p_file, link_file, gpm_type, optimizer, build_ls; kwargs...)
end


"Construct the minimum load shedding problem."
function build_ls(gpm::AbstractGasPowerModel)
    # Gas-only variables and constraints.
    _GM.build_ls(_get_gasmodel_from_gaspowermodel(gpm))

    # Power-only variables and constraints (from PowerModelsRestoration).
    _PMR.build_mld(_get_powermodel_from_gaspowermodel(gpm))

    # Gas-power related parts of the problem formulation.
    for (i, delivery) in _IM.ref(gpm, :ng, :delivery)
        constraint_heat_rate(gpm, i)
    end

    # Objective maximizes the amount of load delivered.
    objective_max_load(gpm)
end
