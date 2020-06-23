""
function instantiate_model(g_file::String, p_file::String, g_type::Type, p_type::Type, build_method; gm_ref_extensions=[], pm_ref_extensions=[], kwargs...)
    g_data, p_data = _GM.parse_file(g_file), _PM.parse_file(p_file)

    return instantiate_model(g_data, p_data, g_type, p_type,
        build_method; gm_ref_extensions=gm_ref_extensions,
        pm_ref_extensions=pm_ref_extensions, kwargs...)
end

""
function instantiate_model(g_data::Dict{String,<:Any}, p_data::Dict{String,<:Any}, g_type::Type, p_type::Type, build_method; gm_ref_extensions=[], pm_ref_extensions=[], kwargs...)
    # Instantiate the GasModels object.
    gm = _GM.instantiate_model(g_data, g_type, m->nothing; ref_extensions=gm_ref_extensions)

    # Instantiate the PowerModels object.
    pm = _PM.instantiate_model(p_data, p_type, m->nothing; ref_extensions=pm_ref_extensions, jump_model=gm.model)

    # Assign generator numbers to junctions.
    add_junction_generators(gm, pm)

    # TODO: The below is a bit of a hack.
    gas_grid_per_unit(gm.data, pm.data)

    # Build the corresponding problem.
    build_method(pm, gm)

    # Return the two individual *Models objects.
    return gm, pm
end

""
function run_model(g_data::Dict{String,<:Any}, p_data::Dict{String,<:Any}, g_type::Type, p_type::Type, optimizer, build_method; gm_solution_processors=[], pm_solution_processors=[], gm_ref_extensions=[], pm_ref_extensions=[], kwargs...)
    start_time = time()
    gm, pm = instantiate_model(g_data, p_data, g_type, p_type,
        build_method; gm_ref_extensions=gm_ref_extensions,
        pm_ref_extensions=pm_ref_extensions, kwargs...)
    Memento.debug(_LOGGER, "gpm model build time: $(time() - start_time)")

    start_time = time()
    gas_result = _IM.optimize_model!(gm, optimizer=optimizer, solution_processors=gm_solution_processors)
    power_result = _IM.build_result(pm, gas_result["solve_time"]; solution_processors=pm_solution_processors)
    Memento.debug(_LOGGER, "gpm model solution time: $(time() - start_time)")

    # Create a combined gas-power result object.
    result = gas_result # Contains most of the result data, already.

    # TODO: There could possibly be component name clashes, here, later on.
    result["solution"] = merge(gas_result["solution"], power_result["solution"])

    # Return the combined result dictionary.
    return result
end

""
function run_model(g_file::String, p_file::String, g_type::Type, p_type::Type, optimizer, build_method; gm_ref_extensions=[], pm_ref_extensions=[], kwargs...)
    g_data, p_data = _GM.parse_file(g_file), _PM.parse_file(p_file)

    return run_model(g_data, p_data, g_type, p_type, optimizer,
        build_method; gm_ref_extensions=gm_ref_extensions,
        pm_ref_extensions=pm_ref_extensions, kwargs...)
end
