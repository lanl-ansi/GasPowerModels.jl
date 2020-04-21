# Definitions for running a feasible combined gas and power flow

export run_gpf

" entry point into running the gas grid flow feasability problem"
function run_gpf(power_file, gas_file, power_model_constructor, gas_model_constructor, solver; kwargs...)
    return run_generic_model(power_file, gas_file, power_model_constructor, gas_model_constructor, solver, post_gpf; kwargs...)
end

" construct the gas grid flow feasbility problem"
function post_gpf(pm::AbstractPowerModel, gm::GenericGasModel)
    # Power-only related variables and constraints
    post_gpf(pm)

    # Gas-only related variables and constraints
    post_gpf(gm)

    # Gas-Grid related parts of the problem formulation
    for i in _GM.ids(gm, :consumer)
       constraint_heat_rate_curve(pm, gm, i)
    end

    # The objective is nothing
    @objective(gm.model, Max, 0)
end

" Post the electric power constraints "
function post_gpf(pm::AbstractPowerModel)
    _PM.variable_voltage(pm, bounded = false)
    _PM.variable_generation(pm, bounded = false)
    _PM.variable_branch_flow(pm, bounded = false)
    _PM.variable_dcline_flow(pm, bounded = false)

    _PM.constraint_model_voltage(pm)

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i)
        _PM.constraint_voltage_magnitude_setpoint(pm, i)
    end

    for i in _PM.ids(pm, :bus)
        _PM.constraint_power_balance(pm, i)

        # PV Bus Constraints
        if length(ref(pm, :bus_gens, i)) > 0 && !(i in ids(pm,:ref_buses))
            _PM.constraint_voltage_magnitude_setpoint(pm, i)
            for j in ref(pm, :bus_gens, i)
                _PM.constraint_active_gen_setpoint(pm, j)
            end
        end
    end

    for i in _PM.ids(pm, :branch)
        _PM.constraint_ohms_yt_from(pm, i)
        _PM.constraint_ohms_yt_to(pm, i)
    end

    for i in _PM.ids(pm, :dcline)
        _PM.constraint_active_dcline_setpoint(pm, i)

        f_bus = _PM.ref(pm, :bus)[dcline["f_bus"]]
        if f_bus["bus_type"] == 1
            _PM.constraint_voltage_magnitude_setpoint(pm, f_bus["index"])
        end

        t_bus = _PM.ref(pm, :bus)[dcline["t_bus"]]
        if t_bus["bus_type"] == 1
            _PM.constraint_voltage_magnitude_setpoint(pm, t_bus["index"])
        end
    end

end

"Post the gas flow variables and constraints"
function post_gpf(gm::GenericGasModel)
    _GM.variable_flow(gm)
    _GM.variable_pressure_sqr(gm)
    _GM.variable_valve_operation(gm)
    _GM.variable_load_mass_flow(gm)
    _GM.variable_production_mass_flow(gm)

    for i in _GM.ids(gm, :junction)
        _GM.constraint_mass_flow_balance_ls(gm, i)
    end

    for i in _GM.ids(gm, :pipe)
        _GM.constraint_pipe_pressure(gm, i)
        _GM.constraint_pipe_mass_flow(gm,i)
        _GM.constraint_weymouth(gm,i)
    end

    for i in _GM.ids(gm, :resistor)
        _GM.constraint_pipe_pressure(gm, i)
        _GM.constraint_pipe_mass_flow(gm,i)
        _GM.constraint_weymouth(gm,i)
    end

    for i in _GM.ids(gm, :short_pipe)
        _GM.constraint_short_pipe_pressure(gm, i)
        _GM.constraint_short_pipe_mass_flow(gm, i)
    end

    for i in _GM.ids(gm, :compressor)
        _GM.constraint_compressor_ratios(gm, i)
        _GM.constraint_compressor_mass_flow(gm, i)
    end

    for i in _GM.ids(gm, :valve)
        _GM.constraint_on_off_valve_mass_flow(gm, i)
        _GM.constraint_on_off_valve_pressure(gm, i)
    end

    for i in _GM.ids(gm, :control_valve)
        _GM.constraint_on_off_control_valve_mass_flow(gm, i)
        _GM.constraint_on_off_control_valve_pressure(gm, i)
    end
end
