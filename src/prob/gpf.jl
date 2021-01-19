# Definitions for solving a feasible combined gas and power flow.


"Entry point into running the gas-power flow feasibility problem."
function run_gpf(g_file, p_file, link_file, model_type, optimizer; kwargs...)
    return run_model(g_file, p_file, link_file, model_type, optimizer, build_gpf; kwargs...)
end


"Entry point into running the gas-power flow feasibility problem."
function run_gpf(data, model_type, optimizer; kwargs...)
    return run_model(data, model_type, optimizer, build_gpf; kwargs...)
end


"Construct the gas-power flow feasbility problem."
function build_gpf(gpm::AbstractGasPowerModel)
    # Gas-only variables and constraints
    _GM.build_gf(_get_gasmodel_from_gaspowermodel(gpm))

    # Power-only variables and constraints
    _PM.build_pf(_get_powermodel_from_gaspowermodel(gpm))

    # Gas-power related parts of the problem formulation.
    for (i, delivery_gen) in _IM.ref_dep(gpm, :delivery_gen)
        constraint_heat_rate(gpm, i)
    end

    # Add a feasibility-only objective.
    JuMP.@objective(gpm.model, _IM._MOI.FEASIBILITY_SENSE, 0.0)
end
