""
function instantiate_model(gfile::String, pfile::String, gtype::Type, ptype::Type, build_method; gm_ref_extensions=[], pm_ref_extensions=[], kwargs...)
    gdata, pdata = _GM.parse_file(gfile), _PM.parse_file(pfile)
    return instantiate_model(gdata, pdata, gtype, ptype, build_method; gm_ref_extensions=gm_ref_extensions, pm_ref_extensions=pm_ref_extensions, kwargs...)
end

""
function instantiate_model(gdata::Dict{String,<:Any}, pdata::Dict{String,<:Any}, gtype::Type, ptype::Type, build_method; gm_ref_extensions=[], pm_ref_extensions=[], kwargs...)
    # Instantiate the GasModels object.
    gm = _GM.instantiate_model(gdata, gtype, m->nothing; ref_extensions=gm_ref_extensions)

    # Instantiate the PowerModels object.
    pm = _PM.instantiate_model(pdata, ptype, m->nothing; ref_extensions=pm_ref_extensions, jump_model=gm.model)

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
function run_model(gdata::Dict{String,<:Any}, pdata::Dict{String,<:Any}, gtype::Type, ptype::Type, optimizer, build_method; gm_solution_processors=[], pm_solution_processors=[], gm_ref_extensions=[], pm_ref_extensions=[], kwargs...)
    start_time = time()
    gm, pm = instantiate_model(gdata, pdata, gtype, ptype, build_method; gm_ref_extensions=gm_ref_extensions, pm_ref_extensions=pm_ref_extensions, kwargs...)
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
function run_model(gfile::String, pfile::String, gtype::Type, ptype::Type, optimizer, build_method; gm_ref_extensions=[], pm_ref_extensions=[], kwargs...)
    gdata, pdata = _GM.parse_file(gfile), _PM.parse_file(pfile)
    return run_model(gdata, pdata, gtype, ptype, optimizer, build_method; gm_ref_extensions=gm_ref_extensions, pm_ref_extensions=pm_ref_extensions, kwargs...)
end
