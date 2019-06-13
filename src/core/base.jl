# stuff that is universal to all gas grid models

export
    setdata, solve,
    run_generic_model, build_generic_model, solve_generic_model

" Do a solve of the problem "
function JuMP.solve(gm::GenericGasModel)
    status, solve_time, solve_bytes_alloc, sec_in_gc = @timed solve(gm.model)
    try
        solve_time = getsolvetime(gm.model)
    catch
        @warn "there was an issue with getsolvetime() on the solver, falling back on @timed.  This is not a rigorous timing value."
    end

    return status, solve_time
end

""
function run_generic_model(power_file, gas_file, power_model_constructor, gas_model_constructor, solver, post_method; solution_builder = get_solution, kwargs...)
    power_data    = PowerModels.parse_file(power_file)
    gas_data      = GasModels.parse_file(gas_file)
    return run_generic_model(power_data, gas_data, power_model_constructor, gas_model_constructor, solver, post_method; solution_builder = solution_builder, kwargs...)
end

" Run the optimization on a dictionarized model"
function run_generic_model(power_data::Dict{String,Any}, gas_data::Dict{String,Any}, power_model_constructor, gas_model_constructor, solver, post_method; power_ref_extensions=[], solution_builder = get_solution, kwargs...)
    pm, gm = build_generic_model(power_data, gas_data, power_model_constructor, gas_model_constructor, post_method; power_ref_extensions=power_ref_extensions, kwargs...)
    solution = solve_generic_model(pm, gm, solver; solution_builder = solution_builder)
    return solution
end

""
function build_generic_model(pfile::String, gfile::String, power_model_constructor, gas_model_constructor, post_method; kwargs...)
    gas_data = GasModels.parse_file(gfile)
    power_data = PowerModels.parse_file(pfile)
    return build_generic_model(power_data, gas_data, power_model_constructor, gas_model_constructor, post_method; kwargs...)
end

" Dummy post method to do nothing for the individual system"
function empty_post_method(m; kwargs...)
end

""
function build_generic_model(pdata::Dict{String,Any}, gdata::Dict{String,Any}, power_model_constructor, gas_model_constructor, post_method; power_ref_extensions=[], multinetwork=false, multiconductor=false, kwargs...)
    gm = GasModels.build_generic_model(gdata, gas_model_constructor, empty_post_method; multinetwork=multinetwork, kwargs...)
    pm = PowerModels.build_model(pdata, power_model_constructor, empty_post_method; ref_extensions=power_ref_extensions, multinetwork=multinetwork, multiconductor=multiconductor)

    add_junction_generators(pm, gm)

    # a bit of a hack for now
    gas_grid_per_unit(gm.data, pm.data)

    # unify all the optimization models... a little bit of a hack...
    pm.model = gm.model

    post_method(pm, gm; kwargs...)
    return pm, gm
end

""
function solve_generic_model(pm::GenericPowerModel, gm::GenericGasModel, optimizer::JuMP.OptimizerFactory; solution_builder = get_solution)
    termination_status, solve_time = optimize!(pm, gm, optimizer)
    status = GasModels.parse_status(termination_status)

    return build_solution(pm, gm, status, solve_time; solution_builder = solution_builder)
end

" Do a solve of the problem "
function optimize!(pm::GenericPowerModel, gm::GenericGasModel, optimizer::JuMP.OptimizerFactory)
    if gm.model.moi_backend.state == MOIU.NO_OPTIMIZER
        _, solve_time, solve_bytes_alloc, sec_in_gc = @timed JuMP.optimize!(gm.model, optimizer)
    else
        @warn "Model already contains optimizer factory, cannot use optimizer specified in `solve_generic_model`"
        _, solve_time, solve_bytes_alloc, sec_in_gc = @timed JuMP.optimize!(gm.model)
    end

    try
        solve_time = MOI.get(gm.model, MOI.SolveTime())
    catch
        warn(LOGGER, "the given optimizer does not provide the SolveTime() attribute, falling back on @timed.  This is not a rigorous timing value.")
    end

    return JuMP.termination_status(gm.model), solve_time
end
