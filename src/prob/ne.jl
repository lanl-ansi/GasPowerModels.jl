# Definitions for solving a feasible combined gas and power flow with network expansion.

"Entry point for running gas and electric power expansion planning only."
function run_ne(gfile, pfile, gtype, ptype, optimizer; kwargs...)
    pm_ref_extensions = [_PM.ref_add_on_off_va_bounds!, _PM.ref_add_ne_branch!]
    return run_model(gfile, pfile, gtype, ptype, optimizer, build_ne;
        gm_ref_extensions=[_GM.ref_add_ne!], pm_ref_extensions=pm_ref_extensions, kwargs...)
end

# construct the gas flow feasbility problem with demand being the cost model
function build_ne(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel; kwargs...)
    kwargs = Dict(kwargs[:kwargs])
    gweight = haskey(kwargs, :gas_ne_weight) ? kwargs[:gas_ne_weight] : 1.0
    pweight = haskey(kwargs, :power_ne_weight) ? kwargs[:power_ne_weight] : 1.0
    obj_normalization = haskey(kwargs, :obj_normalization) ? kwargs[:obj_normalization] : 1.0

    # Gas-only-related variables and constraints.
    _GM.build_nels(gm)

    # Power-only-related variables and constraints.
    _PM.build_tnep(pm)

    # Gas-power related parts of the problem formulation.
    for i in _GM.ids(gm, :delivery)
       constraint_heat_rate_curve(pm, gm, i)
    end

    # This objective function minimizes demand and pressure cost.
    objective_min_ne_cost(pm, gm, gas_ne_weight=gweight,
        power_ne_weight=pweight, normalization=obj_normalization)
end
