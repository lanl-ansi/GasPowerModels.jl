"""
    instantiate_model(
        g_data, p_data, g_type, p_type, build_method;
        gm_ref_extensions, pm_ref_extensions, kwargs...)

    Instantiates and returns GasModels and PowerModels modeling objects from gas and power
    input data `g_data` and `p_data`, respectively. Here, `g_type` and `p_type` are the gas
    and power modeling types, `build_method` is the build method for the problem
    specification being considered, and `gm_ref_extensions` and `pm_ref_extensions` are
    arrays of functions used to define gas and power modeling extensions.
"""
function instantiate_model(
    g_data::Dict{String,<:Any}, p_data::Dict{String,<:Any}, g_type::Type, p_type::Type,
    build_method::Function; gm_ref_extensions::Vector{<:Function}=Vector{Function}([]),
    pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), kwargs...)

    # Instantiate the GasModels object.
    gm = _GM.instantiate_model(
        g_data, g_type, m->nothing; ref_extensions=gm_ref_extensions)

    # Instantiate the PowerModels object.
    pm = _PM.instantiate_model(
        p_data, p_type, m->nothing; ref_extensions=pm_ref_extensions, jump_model=gm.model)

    # TODO: Change this to a function on g_data and p_data.
    # Assign generator numbers to deliveries.
    _assign_delivery_generators!(gm, pm)

    # Build the corresponding problem.
    build_method(pm, gm)

    # Return the two individual *Models objects.
    return gm, pm
end


"""
    instantiate_model(
        g_file, p_file, g_type, p_type, build_method;
        gm_ref_extensions, pm_ref_extensions, kwargs...)

    Instantiates and returns GasModels and PowerModels modeling objects from gas and power
    input files `g_file` and `p_file`, respectively. Here, `g_type` and `p_type` are the gas
    and power modeling types, `build_method` is the build method for the problem
    specification being considered, and `gm_ref_extensions` and `pm_ref_extensions` are
    arrays of functions used to define gas and power modeling extensions.
"""
function instantiate_model(
    g_file::String, p_file::String, g_type::Type, p_type::Type, build_method::Function;
    gm_ref_extensions::Vector{<:Function}=Vector{Function}([]),
    pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), kwargs...)
    # Read gas and power data from files.
#    g_data, p_data = _GM.parse_file(g_file, skip_correct=true), _PM.parse_file(p_file, validate=false)
    g_data, p_data = _GM.parse_file(g_file, skip_correct=true), _PM.parse_file(p_file, validate=false)


    g_per_unit = get(g_data,"is_per_unit",false)
    p_per_unit = get(p_data,"per_unit", false)

    # Ensure the two datasets use the same units
    _GM.correct_network_data!(g_data)
    _PM.correct_network_data!(p_data)

    if g_per_unit == false
        resolve_gm_units!(g_data)
    end

    if p_per_unit == false
        resolve_pm_units!(p_data)
    end

    # Instantiate GasModels and PowerModels modeling objects.
    return instantiate_model(
        g_data, p_data, g_type, p_type, build_method; gm_ref_extensions=gm_ref_extensions,
        pm_ref_extensions=pm_ref_extensions, kwargs...)
end


"""
    run_model(
        g_data, p_data, g_type, p_type, optimizer, build_method; gm_solution_processors,
        pm_solution_processors, gm_ref_extensions, pm_ref_extensions, kwargs...)

    Instantiates and solves the joint GasModels and PowerModels modeling objects from gas
    and power input data `g_data` and `p_data`, respectively. Here, `g_type` and `p_type`
    are the gas and power modeling types, `optimizer` it the optimization solver,
    `build_method` is the build method for the problem specification being considered,
    `gm_solution_processors` and `pm_solution_processors` are arrays of gas and power model
    solution processors, and `gm_ref_extensions` and `pm_ref_extensions` are arrays of gas
    and power modeling extensions. Returns a dictionary of combined results.
"""
function run_model(
    g_data::Dict{String,<:Any}, p_data::Dict{String,<:Any}, g_type::Type, p_type::Type,
    optimizer::Union{_MOI.AbstractOptimizer, _MOI.OptimizerWithAttributes},
    build_method::Function; gm_solution_processors::Vector{<:Function}=Vector{Function}([]),
    pm_solution_processors::Vector{<:Function}=Vector{Function}([]),
    gm_ref_extensions::Vector{<:Function}=Vector{Function}([]),
    pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), kwargs...)
    start_time = time()

    gm, pm = instantiate_model(
        g_data, p_data, g_type, p_type, build_method; gm_ref_extensions=gm_ref_extensions,
        pm_ref_extensions=pm_ref_extensions, kwargs...)

    Memento.debug(_LOGGER, "gpm model build time: $(time() - start_time)")

    start_time = time()

    # Solve the optimization model and store the gas modeling result.
    gas_result = _IM.optimize_model!(
        gm, optimizer=optimizer, solution_processors=gm_solution_processors)

    # Build the power modeling result using the same model as above.
    power_result = _IM.build_result(
        pm, gas_result["solve_time"]; solution_processors=pm_solution_processors)

    Memento.debug(_LOGGER, "gpm model solution time: $(time() - start_time)")

    # Create a combined gas-power result object.
    result = gas_result # Contains most of the result data, already.

    # TODO: There could possibly be component name clashes, here, later on.
    result["solution"] = merge(gas_result["solution"], power_result["solution"])

    # Return the combined result dictionary.
    return result
end


"""
    run_model(
        g_file, p_file, g_type, p_type, optimizer, build_method; gm_solution_processors,
        pm_solution_processors, gm_ref_extensions, pm_ref_extensions, kwargs...)

    Instantiates and solves the joint GasModels and PowerModels modeling objects from gas
    and power input files `g_file` and `p_file`, respectively. Here, `g_type` and `p_type`
    are the gas and power modeling types, `optimizer` it the optimization solver,
    `build_method` is the build method for the problem specification being considered,
    `gm_solution_processors` and `pm_solution_processors` are arrays of gas and power model
    solution processors, and `gm_ref_extensions` and `pm_ref_extensions` are arrays of gas
    and power modeling extensions. Returns a dictionary of combined results.
"""
function run_model(
    g_file::String, p_file::String, g_type::Type, p_type::Type,
    optimizer::Union{_MOI.AbstractOptimizer, _MOI.OptimizerWithAttributes},
    build_method::Function; gm_solution_processors::Vector{<:Function}=Vector{Function}([]),
    pm_solution_processors::Vector{<:Function}=Vector{Function}([]),
    gm_ref_extensions::Vector{<:Function}=Vector{Function}([]),
    pm_ref_extensions::Vector{<:Function}=Vector{Function}([]), kwargs...)
    # Read gas and power data from files.
#    g_data, p_data = _GM.parse_file(g_file, skip_correct=true), _PM.parse_file(p_file, validate=false)
    g_data, p_data = _GM.parse_file(g_file, skip_correct=true), _PM.parse_file(p_file, validate=false)

    # Ensure the two datasets use the same units for power.
    g_per_unit = get(g_data,"is_per_unit",false)
    p_per_unit = get(p_data,"per_unit",false)

    # Ensure the two datasets use the same units
    _GM.correct_network_data!(g_data)
    _PM.correct_network_data!(p_data)

    if g_per_unit == false
        resolve_gm_units!(g_data)
    end

    if p_per_unit == false
        resolve_pm_units!(p_data)
    end

    return run_model(
        g_data, p_data, g_type, p_type, optimizer, build_method;
        gm_solution_processors=gm_solution_processors,
        pm_solution_processors=pm_solution_processors, gm_ref_extensions=gm_ref_extensions,
        pm_ref_extensions=pm_ref_extensions, kwargs...)
end
