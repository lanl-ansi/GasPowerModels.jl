# Definitions for solving a feasible combined gas and power flow.

"Entry point into running the gas-power flow feasibility problem."
function run_gpf(g_file, p_file, g_type, p_type, optimizer; kwargs...)
    return run_model(g_file, p_file, g_type, p_type, optimizer, build_gpf; kwargs...)
end

"Construct the gas-power flow feasbility problem."
function build_gpf(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel)
    # Gas-only related variables and constraints
    _GM.build_gf(gm)

    # Power-only related variables and constraints
    _PM.build_pf(pm)

    # Gas-power related parts of the problem formulation.
    for i in _GM.ids(gm, :delivery)
        constraint_heat_rate_curve(pm, gm, i)
    end

    # Add a feasibility-only objective.
    JuMP.@objective(gm.model, _IM._MOI.FEASIBILITY_SENSE, 0.0)
end
