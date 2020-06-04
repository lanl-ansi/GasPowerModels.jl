# Definitions for running a optimal operations combined gas and power flow with network expansion.

" entry point for running gas and electric power expansion planning with demand-based pricing and a pressure penalty (in TPS paper) "
function run_ne_opf(power_file, gas_file, power_model_constructor, gas_model_constructor, solver; solution_builder=get_ne_opf_solution, kwargs...)
    return run_generic_model(power_file, gas_file, power_model_constructor,
        gas_model_constructor, solver, build_ne_opf;
        power_ref_extensions=[_PM.ref_add_on_off_va_bounds!,_PM.ref_add_ne_branch!],
        solution_builder=solution_builder, kwargs...)
end

" Construct the gas flow feasbility problem with demand being the cost model"
function build_ne_opf(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel)
    # Gas-only-related variables and constraints.
    _GM.build_nels(gm)

    # Power-only-related variables and constraints.
    _PM.build_tnep(pm)

    # Gas-power related parts of the problem formulation.
    for i in _GM.ids(gm, :delivery)
       constraint_heat_rate_curve(pm, gm, i)
    end
    
    # Objective function minimizes demand and pressure cost.
    objective_min_ne_opf_cost(pm, gm)
end
