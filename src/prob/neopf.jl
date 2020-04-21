# Definitions for running a optimal operations combined gas and power flow with network expansion

" entry point for running gas and electric power expansion planning with demand-based pricing and a pressure penalty (in TPS paper) "
function run_ne_opf(power_file, gas_file, power_model_constructor, gas_model_constructor, solver; solution_builder=get_ne_opf_solution, kwargs...)
    return run_generic_model(power_file, gas_file, power_model_constructor, gas_model_constructor, solver, post_ne_opf; power_ref_extensions=[_PM.ref_add_on_off_va_bounds!,_PM.ref_add_ne_branch!], solution_builder=solution_builder, kwargs...)
end

" Construct the gas flow feasbility problem with demand being the cost model"
function post_ne_opf(pm::AbstractPowerModel, gm::GenericGasModel; kwargs...)
    kwargs = Dict(kwargs)
    gas_ne_weight    = haskey(kwargs, :gas_ne_weight)      ? kwargs[:gas_ne_weight] : 1.0
    power_ne_weight  = haskey(kwargs, :power_ne_weight)    ? kwargs[:power_ne_weight] : 1.0
    power_opf_weight = haskey(kwargs, :power_opf_weight)   ? kwargs[:power_opf_weight] : 1.0
    gas_price_weight = haskey(kwargs, :gas_price_weight)   ? kwargs[:gas_price_weight] : 1.0

    ## Power only related variables and constraints
    post_tnep(pm)

    #### Gas only related variables and constraints
    post_nels(gm)

    ## Gas-Grid related parts of the problem formulation
    for i in _GM.ids(gm, :consumer)
       c = constraint_heat_rate_curve(pm, gm, i)
    end

    ### Object function minimizes demand and pressure cost
    objective_min_ne_opf_cost(pm, gm; gas_ne_weight = gas_ne_weight, power_ne_weight = power_ne_weight, power_opf_weight = power_opf_weight, gas_price_weight = gas_price_weight)
end

function get_ne_opf_solution(pm::AbstractPowerModel, gm::GenericGasModel)
    sol = Dict{AbstractString,Any}()
    _PM.add_setpoint_bus_voltage!(sol, pm)
    _PM.add_setpoint_generator_power!(sol, pm)
    _PM.add_setpoint_branch_flow!(sol, pm)
    _GM.add_junction_pressure_setpoint(sol, gm)
    _GM.add_connection_ne(sol, gm)
    _GM.add_load_mass_flow_setpoint(sol, gm)
    _GM.add_production_mass_flow_setpoint(sol, gm)
    _GM.add_load_volume_setpoint(sol, gm)
    _GM.add_production_volume_setpoint(sol, gm)
    _GM.add_direction_setpoint(sol, gm)
    _GM.add_direction_ne_setpoint(sol,gm)
    _GM.add_valve_setpoint(sol, gm)
    _PM.add_setpoint_branch_ne_flow!(sol, pm)
    _PM.add_setpoint_branch_ne_built!(sol, pm)
    add_zone_cost_setpoint(sol, gm)
    return sol
end

# Add locational marginal prices
function add_zone_cost_setpoint(sol, gm::GenericGasModel)
    _GM.add_setpoint(sol, gm, "price_zone", "lm",    :zone_cost)
    _GM.add_setpoint(sol, gm, "price_zone", "lf",    :zone_fl)
    _GM.add_setpoint(sol, gm, "price_zone", "lq",    :zone_ql, scale = (x,item) -> _GM.getvalue(x) / gm.data["standard_density"])
    _GM.add_setpoint(sol, gm, "price_zone", "lp",    :p_cost)
    _GM.add_setpoint(sol, gm, "price_zone", "max_p", :zone_p)
end
