# Definitions for solving a joint minimum load shedding problem.


"Entry point into running the minimum load shedding problem."
function run_mld(g_file, p_file, link_file, gpm_type, optimizer; kwargs...)
    return run_model(g_file, p_file, link_file, gpm_type, optimizer, build_mld; kwargs...)
end


"Construct the minimum load shedding problem."
function build_mld(gpm::AbstractGasPowerModel)
    # Gas-only variables and constraints.
    _GM.build_ls(_get_gasmodel_from_gaspowermodel(gpm))

    # Power-only variables and constraints (from PowerModelsRestoration).
    _PMR.build_mld(_get_powermodel_from_gaspowermodel(gpm))

    # Gas-power related parts of the problem formulation.
    for (i, delivery_gen) in gpm.ref[:link_component][:delivery_gen]
        constraint_heat_rate(gpm, i)
    end

    # Objective maximizes the amount of load delivered.
    objective_max_load(gpm)
end
