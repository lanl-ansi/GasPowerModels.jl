# Definitions for solving a feasible combined gas and power flow.

"Entry point into running the gas-power flow feasibility problem."
function run_gpf(gfile, pfile, gtype, ptype, optimizer; kwargs...)
    return run_model(gfile, pfile, gtype, ptype, optimizer, build_gpf; kwargs...)
end

"Construct the gas-power flow feasbility problem."
function build_gpf(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel; kwargs...)
    # Gas-only related variables and constraints
    _GM.build_gf(gm)

    # Power-only related variables and constraints
    _PM.build_pf(pm)

    # Gas-power related parts of the problem formulation.
    for i in _GM.ids(gm, :delivery)
        constraint_heat_rate_curve(pm, gm, i)
    end

    # Add a feasibility-only objective.
    JuMP.@objective(gm.model, _MOI.FEASIBILITY_SENSE, 0.0)
end
