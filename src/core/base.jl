""
function instantiate_model(gfile::String, pfile::String, gtype::Type, ptype::Type, build_method; kwargs...)
    gdata, pdata = [_GM.parse_file(gfile), _PM.parse_file(pfile)]
    return instantiate_model(gdata, pdata, gtype, ptype, build_method; kwargs...)
end

""
function instantiate_model(gdata::Dict{String,<:Any}, pdata::Dict{String,<:Any}, gtype::Type, ptype::Type, build_method; kwargs...)
    # Instantiate the separate (empty) infrastructure models.
    gm = _GM.instantiate_model(gdata, gtype, m->nothing; kwargs...)
    pm = _PM.instantiate_model(pdata, ptype, m->nothing; kwargs...)

    add_junction_generators(pm, gm)

    # TODO: The below is a bit of a hack.
    gas_grid_per_unit(gm.data, pm.data)

    # Unify all the optimization models.
    pm.model = gm.model

    # Build the corresponding problem.
    build_method(pm, gm; kwargs...)

    return gm, pm
end

""
function solve_model(gdata::Dict{String,<:Any}, pdata::Dict{String,<:Any}, gtype::Type, ptype::Type, optimizer, build_method; gsp=[], psp=[], kwargs...)
    start_time = time()
    gm, pm = instantiate_model(gdata, pdata, gtype, ptype, build_method; kwargs...)
    Memento.debug(_LOGGER, "gpm model build time: $(time() - start_time)")

    start_time = time()
    gas_result = _IM.optimize_model!(gm, optimizer=optimizer, solution_processors=gsp)
    power_result = _IM.build_result(pm, gas_result["solve_time"]; solution_processors=psp)
    Memento.debug(_LOGGER, "gpm model solution time: $(time() - start_time)")

    # Create a combined gas-power result object.
    result = gas_result # Contains most of the result data, already.
    result["solution"] = merge(gas_result["solution"], power_result["solution"])

    # Return the combined result dictionary.
    return result
end

""
function solve_model(gfile::String, pfile::String, gtype::Type, ptype::Type, optimizer, build_method; kwargs...)
    gdata, pdata = [_GM.parse_file(gfile), _PM.parse_file(pfile)]
    return solve_model(gdata, pdata, gtype, ptype, optimizer, build_method; kwargs...)
end
