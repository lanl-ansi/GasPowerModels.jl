# Definitions for running a feasible combined gas and power flow

export run_gpf

" entry point into running the gas grid flow feasability problem"
function run_gpf(power_file, gas_file, power_model_constructor, gas_model_constructor, solver; kwargs...)
    return run_generic_model(power_file, gas_file, power_model_constructor, gas_model_constructor, solver, post_gpf; kwargs...)
end

" construct the gas grid flow feasbility problem"
function post_gpf(pm::GenericPowerModel, gm::GenericGasModel)

    ## Power only related variables and constraints
    post_gpf(pm)

    #### Gas only related variables and constraints
    post_gpf(gm)

    ## Gas-Grid related parts of the problem formulation
    for i in GasModels.ids(gm, :consumer)
       constraint_heat_rate_curve(pm, gm, i)
    end

    ### The objective is nothing
    @objective(gm.model, Max, 0)

end

" Post the electric power constraints "
function post_gpf(pm::GenericPowerModel)
    PowerModels.variable_voltage(pm, bounded = false)
    PowerModels.variable_generation(pm, bounded = false)
    PowerModels.variable_branch_flow(pm, bounded = false)
    PowerModels.variable_dcline_flow(pm, bounded = false)

    PowerModels.constraint_model_voltage(pm)

    for i in PowerModels.ids(pm, :ref_buses)
        PowerModels.constraint_theta_ref(pm, i)
        PowerModels.constraint_voltage_magnitude_setpoint(pm, i)
    end

    for i in PowerModels.ids(pm, :bus)
        PowerModels.constraint_power_balance_shunt(pm, i)

        # PV Bus Constraints
        if length(ref(pm, :bus_gens, i)) > 0 && !(i in ids(pm,:ref_buses))
            PowerModels.constraint_voltage_magnitude_setpoint(pm, i)
            for j in ref(pm, :bus_gens, i)
                PowerModels.constraint_active_gen_setpoint(pm, j)
            end
        end
    end

    for i in PowerModels.ids(pm, :branch)
        PowerModels.constraint_ohms_yt_from(pm, i)
        PowerModels.constraint_ohms_yt_to(pm, i)
    end

    for i in PowerModels.ids(pm, :dcline)
        PowerModels.constraint_active_dcline_setpoint(pm, i)

        f_bus = PowerModels.ref(pm, :bus)[dcline["f_bus"]]
        if f_bus["bus_type"] == 1
            PowerModels.constraint_voltage_magnitude_setpoint(pm, f_bus["index"])
        end

        t_bus = PowerModels.ref(pm, :bus)[dcline["t_bus"]]
        if t_bus["bus_type"] == 1
            PowerModels.constraint_voltage_magnitude_setpoint(pm, t_bus["index"])
        end
    end

end

"Post the gas flow variables and constraints"
function post_gpf(gm::GenericGasModel)
    GasModels.variable_flow(gm)
    GasModels.variable_pressure_sqr(gm)
    GasModels.variable_valve_operation(gm)
    GasModels.variable_load_mass_flow(gm)
    GasModels.variable_production_mass_flow(gm)


    for i in [collect(GasModels.ids(gm,:pipe)); collect(GasModels.ids(gm,:resistor))]
        GasModels.constraint_pipe_flow(gm, i)
    end

    for i in GasModels.ids(gm, :junction)
        GasModels.constraint_junction_mass_flow_ls(gm, i)
    end

    for i in GasModels.ids(gm, :short_pipe)
        GasModels.constraint_short_pipe_flow(gm, i)
    end

    for i in GasModels.ids(gm, :compressor)
        GasModels.constraint_compressor_flow(gm, i)
    end

    for i in GasModels.ids(gm, :valve)
        GasModels.constraint_valve_flow(gm, i)
    end

    for i in GasModels.ids(gm, :control_valve)
        GasModels.constraint_control_valve_flow(gm, i)
    end


end
