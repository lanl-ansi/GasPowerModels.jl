# Definitions for running a optimal operations combined gas and power flow with network expansion

" entry point for running gas and electric power expansion planning with demand-based pricing and a pressure penalty (in TPS paper) "
function run_ne_opf(coupling_file, power_file, gas_file, model_constructor, power_model_constructor, gas_model_constructor, solver; solution_builder=get_ne_opf_solution, kwargs...)
    return run_generic_model(coupling_file, power_file, gas_file, model_constructor, power_model_constructor, gas_model_constructor, solver, post_ne_opf; solution_builder=solution_builder, kwargs...)     
end

" Construct the gas flow feasbility problem with demand being the cost model"
function post_ne_opf{T,P,G}(ggm::GenericGasGridModel{T}, pm::GenericPowerModel{P}, gm::GenericGasModel{G})
    gas_ne_weight    = haskey(ggm.data, "gas_ne_weight") ? ggm.data["gas_ne_weight"] : 1.0 
    power_ne_weight  = haskey(ggm.data, "power_ne_weight") ? ggm.data["power_ne_weight"] : 1.0
    power_opf_weight = haskey(ggm.data, "power_opf_weight") ? ggm.data["power_opf_weight"] : 1.0 
    gas_price_weight = haskey(ggm.data, "gas_price_weight") ? ggm.data["gas_price_weight"] : 1.0
      
    ## Power only related variables and constraints
    post_tnep(pm)
  
    #### Gas only related variables and constraints
    post_nels(gm)
    
    ## Gas-Grid related parts of the problem formulation
    for i in GasModels.ids(gm, :junction)
       c = constraint_heat_rate_curve(ggm, pm, gm, i)
    end
            
    ### Object function minimizes demand and pressure cost
    objective_min_ne_opf_cost(ggm, pm, gm; gas_ne_weight = gas_ne_weight, power_ne_weight = power_ne_weight, power_opf_weight = power_opf_weight, gas_price_weight = gas_price_weight)     
end

function get_ne_opf_solution{T, P, G}(ggm::GenericGasGridModel{T}, pm::GenericPowerModel{P}, gm::GenericGasModel{G})
    sol = Dict{AbstractString,Any}()
    PowerModels.add_bus_voltage_setpoint(sol, pm)
    PowerModels.add_generator_power_setpoint(sol, pm)
    PowerModels.add_branch_flow_setpoint(sol, pm)
    GasModels.add_junction_pressure_setpoint(sol, gm) 
    GasModels.add_connection_ne(sol, gm)
    GasModels.add_load_setpoint(sol, gm)
    GasModels.add_production_setpoint(sol, gm)    
    GasModels.add_direction_setpoint(sol, gm)
    GasModels.add_direction_ne_setpoint(sol,gm)
    GasModels.add_valve_setpoint(sol, gm)            
    PowerModels.add_branch_ne_setpoint(sol, pm)  
    add_zone_cost_setpoint(sol, ggm)
    return sol
end

# Add locational marginal prices
function add_zone_cost_setpoint{T}(sol, ggm::GenericGasGridModel{T})
    add_setpoint(sol, ggm, "price_zone", "lm",    :zone_cost)
    add_setpoint(sol, ggm, "price_zone", "lq",    :zone_ql)
    add_setpoint(sol, ggm, "price_zone", "lp",    :p_cost)
    add_setpoint(sol, ggm, "price_zone", "max_p", :zone_p)    
end