# stuff that is universal to all gas grid models

export
    setdata, setsolver, solve,
    run_generic_model, build_generic_model, solve_generic_model

" Set the solver "
function JuMP.setsolver(gm::GenericGasModel, solver::MathProgBase.AbstractMathProgSolver)
    setsolver(gm.model, solver)
end

" Do a solve of the problem "
function JuMP.solve(gm::GenericGasModel)
    status, solve_time, solve_bytes_alloc, sec_in_gc = @timed solve(gm.model)
    try
        solve_time = getsolvetime(gm.model)
    catch
        warn("there was an issue with getsolvetime() on the solver, falling back on @timed.  This is not a rigorous timing value.");
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
function run_generic_model(power_data::Dict{String,Any}, gas_data::Dict{String,Any}, power_model_constructor, gas_model_constructor, solver, post_method; solution_builder = get_solution, kwargs...)
    pm, gm = build_generic_model(power_data, gas_data, power_model_constructor, gas_model_constructor, post_method; kwargs...)
    solution = solve_generic_model(pm, gm, solver; solution_builder = solution_builder)
    return solution
end

""
function build_generic_model(pfile::String, gfile::String, power_model_constructor, gas_model_constructor, post_method; kwargs...)
    gas_data = GasModels.parse_file(gfile)
    power_data = PowerModels.parse_file(pfile)
    
    return build_generic_model(power_data, gas_data, power_model_constructor, gas_model_constructor, post_method; kwargs...)
end


""
function build_generic_model(pdata::Dict{String,Any}, gdata::Dict{String,Any}, power_model_constructor, gas_model_constructor, post_method; kwargs...)
    gm = gas_model_constructor(gdata; kwargs...)
    pm = power_model_constructor(pdata)

    add_junction_generators(pm, gm)
    
    # unify all the optimization models... a little bit of a hack...
    pm.model = gm.model
        
    post_method(pm, gm; kwargs...) 
    return pm, gm
end


""
function solve_generic_model(pm::GenericPowerModel, gm::GenericGasModel, solver; solution_builder = get_solution)
    setsolver(gm.model, solver)
    status, solve_time = solve(gm)
    return build_solution(pm, gm, status, solve_time; solution_builder = solution_builder)
end
