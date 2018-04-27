# stuff that is universal to all gas grid models

export
    GenericGasGridModel,
    setdata, setsolver, solve,
    run_generic_model, build_generic_model, solve_generic_model

@compat abstract type AbstractGasGridFormulation end

"""
```
type GenericGasGridModel{T<:AbstractGasGridFormulation}
    model::JuMP.Model
    data::Dict{String,Any}
    setting::Dict{String,Any}
    solution::Dict{String,Any}
    var::Dict{Symbol,Any} # model variable lookup
    constraint::Dict{Symbol, Dict{Any, Any}} # model constraint lookup
    ref::Dict{Symbol,Any} # reference data
    ext::Dict{Symbol,Any} # user extentions
end
```
where

* `data` is the original data, usually from reading in a `.json` file,
* `setting` usually looks something like `Dict("output" => Dict("flows" => true))`, and
* `ref` is a place to store commonly used pre-computed data from of the data dictionary,
    primarily for converting data-types, filtering out deactivated components, and storing
    system-wide values that need to be computed globally. See `build_ref(data)` for further details.

Methods on `GenericGasGridModel` for defining variables and adding constraints should

* work with the `ref` dict, rather than the original `data` dict,
* add them to `model::JuMP.Model`, and
* follow the conventions for variable and constraint names.
"""
type GenericGasGridModel{T<:AbstractGasGridFormulation} 
    model::Model
    data::Dict{String,Any}
    setting::Dict{String,Any}
    solution::Dict{String,Any}
    ref::Dict{Symbol,Any} # data reference data
    var::Dict{Symbol,Any} # JuMP variables
    constraint::Dict{Symbol,Dict{Any, Any}} # data reference data    
    ext::Dict{Symbol,Any} 
end


" default generic constructor "
function GenericGasGridModel(data::Dict{String,Any}, T::DataType; setting = Dict{String,Any}(), solver = JuMP.UnsetSolver())
    ggm = GenericGasGridModel{T}(
        Model(solver = solver), # model
        data, # data
        setting, # setting
        Dict{String,Any}(), # solution
        build_ref(data), # reference data
        Dict{Symbol,Any}(), # vars
        Dict{Symbol,Dict{Any, ConstraintRef}}(), # constraints
        Dict{Symbol,Any}() # ext
    )
    return ggm
end

" Set the solver "
function JuMP.setsolver(ggm::GenericGasGridModel, solver::MathProgBase.AbstractMathProgSolver)
    setsolver(ggm.model, solver)
end

" Do a solve of the problem "
function JuMP.solve(ggm::GenericGasGridModel)
    status, solve_time, solve_bytes_alloc, sec_in_gc = @timed solve(ggm.model)
    try
        solve_time = getsolvetime(ggm.model)
    catch
        warn("there was an issue with getsolvetime() on the solver, falling back on @timed.  This is not a rigorous timing value.");
    end

    return status, solve_time
end

""
function run_generic_model(coupling_file, power_file, gas_file, model_constructor, power_model_constructor, gas_model_constructor, solver, post_method; solution_builder = get_solution, kwargs...)  
    power_data    = PowerModels.parse_file(power_file)
    gas_data      = GasModels.parse_file(gas_file)
    coupling_data = GasGridModels.parse_file(coupling_file) 
    return run_generic_model(coupling_data, power_data, gas_data, model_constructor, power_model_constructor, gas_model_constructor, solver, post_method; solution_builder = solution_builder, kwargs...)      
end

" Run the optimization on a dictionarized model"
function run_generic_model(coupling_data::Dict{String,Any}, power_data::Dict{String,Any}, gas_data::Dict{String,Any}, model_constructor, power_model_constructor, gas_model_constructor, solver, post_method; solution_builder = get_solution, kwargs...)
    ggm, pm, gm = build_generic_model(coupling_data, power_data, gas_data, model_constructor, power_model_constructor, gas_model_constructor, post_method; kwargs...)
    solution = solve_generic_model(ggm, pm, gm, solver; solution_builder = solution_builder)
    return solution
end

""
function build_generic_model(cfile::String, pfile::String, gfile::String, model_constructor, power_model_constructor, gas_model_constructor, post_method; kwargs...)
    gas_data = GasModels.parse_file(gfile)
    power_data = PowerModels.parse_file(pfile)
    coupling_data = GasGridModels.parse_file(cfile) 
    
    return build_generic_model(coupling_data, power_data, gas_data, model_constructor, power_model_constructor, gas_model_constructor, post_method; kwargs...)
end


""
function build_generic_model(cdata::Dict{String,Any}, pdata::Dict{String,Any}, gdata::Dict{String,Any}, model_constructor, power_model_constructor, gas_model_constructor, post_method; kwargs...)
    gm = gas_model_constructor(gdata; kwargs...)
    pm = power_model_constructor(pdata)
    ggm = model_constructor(cdata)

    # unify all the optimization models... a little bit of a hack...
    pm.model = ggm.model
    gm.model = ggm.model
        
    post_method(ggm, pm, gm; kwargs...) 
    return ggm, pm, gm
end


""
function solve_generic_model(ggm::GenericGasGridModel, pm::GenericPowerModel, gm::GenericGasModel, solver; solution_builder = get_solution)
    setsolver(ggm.model, solver)
    status, solve_time = solve(ggm)
    return build_solution(ggm, pm, gm, status, solve_time; solution_builder = solution_builder)
end

"""
Returns a dict that stores commonly used pre-computed data from of the data dictionary,
primarily for converting data-types, filtering out deactivated components, and storing
system-wide values that need to be computed globally.

Some of the common keys include:

* `:gen` -- the set of gas fired generators in the model
* `:price_zone` -- the set of price zones,
* `:junction_generators` -- the set of generators associcated with gas junction,
* `gen[heat_rate]` -- the coefficients of a heat rate curve for a gas generator,

If `:price_zone` does not exist, then an empty reference is added
If `heat rate` does not exist in the [:gen], then [0, 0.48, 0] is added
"""
function build_ref(data::Dict{String,Any}) 
    # Do some robustness on the data to add missing fields    
    add_default_data(data)
    
    ref = Dict{Symbol,Any}()
    for (key, item) in data
        if isa(item, Dict)
            item_lookup = Dict([(parse(Int, k), v) for (k,v) in item])
            ref[Symbol(key)] = item_lookup
        else
            ref[Symbol(key)] = item
        end
    end
            
    ref[:junction_generators] = Dict()
    for (i, generator) in ref[:gen]
       junction = generator["junction"]
       if !haskey(ref[:junction_generators], junction)
           ref[:junction_generators][junction] = []
       end       
       push!(ref[:junction_generators][junction], i)    
    end   
    
    return ref    
end

" Put some default data into the dictionaries "
function add_default_data(data::Dict{String,Any})
    for (i,gen) in data["gen"]
        if !haskey(gen, "heat_rate")
           gen["heat_rate"] = [ 0, 0.48, 0]   
        end
    end
    
    if !haskey(data, "price_zone")
        data["price_zone"] = []
    end                   
end
