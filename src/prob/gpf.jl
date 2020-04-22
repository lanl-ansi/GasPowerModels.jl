# Definitions for running a feasible combined gas and power flow

export solve_gpf

" entry point into running the gas grid flow feasability problem"
function solve_gpf(gfile, pfile, gtype, ptype, optimizer; kwargs...)
    return solve_model(gfile, pfile, gtype, ptype, optimizer, post_gpf; kwargs...)
end

"Construct the gas grid flow feasbility problem."
function post_gpf(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel; kwargs...)
    # Power-only related variables and constraints
    post_gpf_pm(pm)

    # Gas-only related variables and constraints
    post_gpf_gm(gm)

    # Gas-Grid related parts of the problem formulation
    for i in _GM.ids(gm, :delivery)
        constraint_heat_rate_curve(pm, gm, i)
    end
end

"Post the electric power variables and constraints."
function post_gpf_pm(pm::_PM.AbstractPowerModel; kwargs...)
    _PM.variable_bus_voltage(pm, bounded=false)
    _PM.variable_gen_power(pm, bounded=false)
    _PM.variable_branch_power(pm, bounded=false)
    _PM.variable_dcline_power(pm, bounded=false)

    _PM.constraint_model_voltage(pm)

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i)
        _PM.constraint_voltage_magnitude_setpoint(pm, i)
    end

    for i in _PM.ids(pm, :bus)
        _PM.constraint_power_balance(pm, i)

        # PV Bus Constraints
        if length(_PM.ref(pm, :bus_gens, i)) > 0 && !(i in _PM.ids(pm,:ref_buses))
            _PM.constraint_voltage_magnitude_setpoint(pm, i)

            for j in _PM.ref(pm, :bus_gens, i)
                _PM.constraint_gen_setpoint_active(pm, j)
            end
        end
    end

    for i in _PM.ids(pm, :branch)
        _PM.constraint_ohms_yt_from(pm, i)
        _PM.constraint_ohms_yt_to(pm, i)
    end

    for i in _PM.ids(pm, :dcline)
        _PM.constraint_dcline_setpoint_active(pm, i)

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

"Post the gas flow variables and constraints."
function post_gpf_gm(gm::_GM.AbstractGasModel; kwargs...)
    _GM.variable_flow(gm)
    _GM.variable_pressure_sqr(gm)
    _GM.variable_valve_operation(gm)
    _GM.variable_load_mass_flow(gm)
    _GM.variable_production_mass_flow(gm)

    for i in _GM.ids(gm, :pipe)
        _GM.constraint_pipe_pressure(gm, i)
        _GM.constraint_pipe_mass_flow(gm,i)
        _GM.constraint_pipe_weymouth(gm,i)
    end

    for i in _GM.ids(gm, :resistor)
        _GM.constraint_resistor_pressure(gm, i)
        _GM.constraint_resistor_mass_flow(gm,i)
        _GM.constraint_resistor_weymouth(gm,i)
    end

    for i in _GM.ids(gm, :junction)
        _GM.constraint_mass_flow_balance(gm, i)
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

    for i in _GM.ids(gm, :regulator)
        _GM.constraint_on_off_regulator_mass_flow(gm, i)
        _GM.constraint_on_off_regulator_pressure(gm, i)
    end
end
