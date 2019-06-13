# Definitions for running a feasible combined gas and power flow with network expansion
export run_ne
export run_ne_popf

" entry point for running gas and electric power expansion planning only "
function run_ne(power_file, gas_file, power_model_constructor, gas_model_constructor, solver; solution_builder=get_ne_solution, kwargs...)
    return run_generic_model(power_file, gas_file, power_model_constructor, gas_model_constructor, solver, post_ne; power_ref_extensions=[PowerModels.ref_add_on_off_va_bounds!,PowerModels.ref_add_ne_branch!], solution_builder=solution_builder, kwargs...)
end

"Post all the constraints associated with expansion planning in electric power"
function post_tnep(pm::GenericPowerModel)
    PowerModels.variable_branch_ne(pm)      # variable z in the TPS paper
    PowerModels.variable_voltage(pm)        # variable v in the TPS paper
    PowerModels.variable_voltage_ne(pm)     # variable v in the TPS paper
    PowerModels.variable_generation(pm)     # variable p^g, q^g in the TPS paper
    PowerModels.variable_branch_flow(pm)    # variable p,q in the TPS paper
    PowerModels.variable_dcline_flow(pm)    # DC line flows.  Not used in TPS paper
    PowerModels.variable_branch_flow_ne(pm) # variable p,q in the TPS paper

    PowerModels.constraint_model_voltage(pm)      # adds upper and lower bounds on voltage and voltage squared, constraint 11 in TPS paper
    PowerModels.constraint_model_voltage_ne(pm)   # adds upper and lower bounds on voltage and voltage squared, constraint 11 in TPS paper

    for i in ids(pm, :ref_buses)
        PowerModels.constraint_theta_ref(pm, i)  # sets the reference bus phase angle to 0 (not explictly stated in TPS paper)
    end

    for i in ids(pm, :bus)
        PowerModels.constraint_power_balance_shunt_ne(pm, i) # Kirchoff's laws (constraints 1 and 2 in TPS paper)
    end

    for i in ids(pm, :branch)
        PowerModels.constraint_ohms_yt_from(pm, i)                # Ohms laws (constraints 3 and 5 in TPS paper)
        PowerModels.constraint_ohms_yt_to(pm, i)                  # Ohms laws (constraints 4 and 6 in TPS paper)
        PowerModels.constraint_voltage_angle_difference(pm, i)    # limit on phase angle difference (not explictly stated in TPS paper)
        PowerModels.constraint_thermal_limit_from(pm, i)          # thermal limit on lines (constraint 7 in TPS paper)
        PowerModels.constraint_thermal_limit_to(pm, i)            # thermal limit on lines (constraint 8 in TPS paper)
    end

    for i in ids(pm, :ne_branch)
        PowerModels.constraint_ohms_yt_from_ne(pm, i)             # Ohms laws (constraints 3 and 5 in TPS paper)
        PowerModels.constraint_ohms_yt_to_ne(pm, i)               # Ohms laws (constraints 4 and 6 in TPS paper)
        PowerModels.constraint_voltage_angle_difference_ne(pm, i) # limit on phase angle difference (not explictly stated in TPS paper)
        PowerModels.constraint_thermal_limit_from_ne(pm, i)       # thermal limit on lines (constraint 7 in TPS paper)
        PowerModels.constraint_thermal_limit_to_ne(pm, i)         # thermal limit on lines (constraint 8 in TPS paper)
    end

end

"Post all the constraints and variables associated with expansion planning in gas networks"
function post_nels(gm::GenericGasModel)
    GasModels.variable_flow(gm) # variable x in the TPS paper
    GasModels.variable_pressure_sqr(gm)  # variable \pi in the TPS paper
    GasModels.variable_valve_operation(gm)
    GasModels.variable_load_mass_flow(gm)  # variable d in the TPS paper
    GasModels.variable_production_mass_flow(gm)  # variable s in the TPS paper

    # expansion variables
    GasModels.variable_pipe_ne(gm)
    GasModels.variable_compressor_ne(gm)

    GasModels.variable_flow_ne(gm)  # variable x in the TPS paper

    for i in GasModels.ids(gm, :junction)
        GasModels.constraint_junction_mass_flow_ne_ls(gm, i)
    end

    for i in [collect(GasModels.ids(gm,:pipe)); collect(GasModels.ids(gm,:resistor))]
        GasModels.constraint_pipe_flow_ne(gm, i)
    end

    for i in GasModels.ids(gm,:ne_pipe)
        GasModels.constraint_new_pipe_flow_ne(gm, i)
    end

    for i in GasModels.ids(gm, :short_pipe)
        GasModels.constraint_short_pipe_flow_ne(gm, i)
    end

    # We assume that we already have a short pipe connecting two nodes
    # and we just want to add a compressor to it.  Use constraint
    # constraint_on_off_compressor_flow_expansion to disallow flow
    # if the compressor is not built
    for i in GasModels.ids(gm,:compressor)
        GasModels.constraint_compressor_flow_ne(gm, i)
    end

    for i in GasModels.ids(gm, :ne_compressor)
        GasModels.constraint_new_compressor_flow_ne(gm, i)
    end

    for i in GasModels.ids(gm, :valve)
        GasModels.constraint_valve_flow(gm, i)
    end

    for i in GasModels.ids(gm, :control_valve)
        GasModels.constraint_control_valve_flow(gm, i)
    end


end

# construct the gas flow feasbility problem with demand being the cost model
function post_ne(pm::GenericPowerModel, gm::GenericGasModel; kwargs...)
    kwargs = Dict(kwargs)
    gas_ne_weight     = haskey(kwargs, :gas_ne_weight)     ? kwargs[:gas_ne_weight] : 1.0
    power_ne_weight   = haskey(kwargs, :power_ne_weight)   ? kwargs[:power_ne_weight] : 1.0
    obj_normalization = haskey(kwargs, :obj_normalization) ? kwargs[:obj_normalization] : 1.0

    ## Power only related variables and constraints
    post_tnep(pm)

    #### Gas only related variables and constraints
    post_nels(gm)

    ## Gas-Grid related parts of the problem formulation
    for i in GasModels.ids(gm, :consumer)
       constraint_heat_rate_curve(pm, gm, i)
    end

    ### Object function minimizes demand and pressure cost
    objective_min_ne_cost(pm, gm; gas_ne_weight = gas_ne_weight, power_ne_weight = power_ne_weight, normalization =  obj_normalization)
end

function get_ne_solution(pm::GenericPowerModel, gm::GenericGasModel)
    sol = Dict{AbstractString,Any}()
    PowerModels.add_setpoint_bus_voltage!(sol, pm)
    PowerModels.add_setpoint_generator_power!(sol, pm)
    PowerModels.add_setpoint_branch_flow!(sol, pm)
    GasModels.add_junction_pressure_setpoint(sol, gm)
    GasModels.add_connection_ne(sol, gm)
    GasModels.add_load_mass_flow_setpoint(sol, gm)
    GasModels.add_production_mass_flow_setpoint(sol, gm)
    GasModels.add_load_volume_setpoint(sol, gm)
    GasModels.add_production_volume_setpoint(sol, gm)
    GasModels.add_direction_setpoint(sol, gm)
    GasModels.add_direction_ne_setpoint(sol,gm)
    GasModels.add_valve_setpoint(sol, gm)
    PowerModels.add_setpoint_branch_ne_flow!(sol, pm)
    PowerModels.add_setpoint_branch_ne_built!(sol, pm)
    return sol
end
