"Root of the GasPowerModels formulation hierarchy."
abstract type AbstractGasPowerModel{T1 <: _GM.AbstractGasModel, T2 <: _PM.AbstractPowerModel} <: _IM.AbstractInfrastructureModel end


"A macro for adding the base GasPowerModels fields to a type definition."
_IM.@def gpm_fields begin GasPowerModels.@im_fields end


function instantiate_model(data::Dict{String, <:Any}, model_type::Type, build_method::Function; kwargs...)
    return _IM.instantiate_model(data, model_type, build_method, ref_add_core!, _gpm_global_keys; kwargs...)
end


"""
    instantiate_model(g_file, p_file, link_file, model_type, build_method; kwargs...)

    Instantiates and returns a GasPowerModels modeling object from gas and power input
    files `g_file` and `p_file`. Additionally, `link_file` is an input file that links
    gas and power networks, `model_type` is the gas-power modeling type, and
    `build_method` is the build method for the problem specification being considered.
"""
function instantiate_model(
    g_file::String, p_file::String, link_file::String, model_type::Type,
    build_method::Function; kwargs...)
    # Read gas, power, and linking data from files.
    data = parse_files(g_file, p_file, link_file)

    # Instantiate GasModels and PowerModels modeling objects.
    return instantiate_model(data, model_type, build_method; kwargs...)
end


"""
    run_model(
        data, model_type, optimizer, build_method;
        ref_extensions, solution_processors, kwargs...)

    Instantiates and solves the joint GasPowerModels model from input data `data`, where
    `model_type` is the gas-power modeling type, `build_method` is the build method for
    the problem specification being considered, `ref_extensions` is an array of gas and
    power modeling extensions, and `solution_processors` is an array of gas and power
    modeling solution data postprocessors. Returns a dictionary of model results.
"""
function run_model(
    data::Dict{String,<:Any}, model_type::Type, optimizer, build_method::Function;
    ref_extensions = [], solution_processors = [], kwargs...)
    start_time = time()

    gpm = instantiate_model(
        data, model_type, build_method; ref_extensions = ref_extensions,
        ext = get(kwargs, :ext, Dict{Symbol,Any}()),
        setting = get(kwargs, :setting, Dict{String,Any}()),
        jump_model = get(kwargs, :jump_model, JuMP.Model()))

    Memento.debug(_LOGGER, "gpm model build time: $(time() - start_time)")

    start_time = time()

    solution_processors = transform_solution_processors(gpm, solution_processors)

    result = _IM.optimize_model!(
        gpm, optimizer = optimizer, solution_processors = solution_processors)

    Memento.debug(_LOGGER, "gpm model solution time: $(time() - start_time)")

    return result
end


function transform_solution_processors(gpm::AbstractGasPowerModel, solution_processors::Array)
    gm = _get_gasmodel_from_gaspowermodel(gpm)
    pm = _get_powermodel_from_gaspowermodel(gpm)

    for (i, solution_processor) in enumerate(solution_processors)
        model_type = methods(solution_processor).ms[1].sig.types[2]

        if model_type <: _GM.AbstractGasModel
            solution_processors[i] = (gpm, sol) -> solution_processor(gm, sol)
        elseif model_type <: _PM.AbstractPowerModel
            solution_processors[i] = (gpm, sol) -> solution_processor(pm, sol)
        end
    end

    return solution_processors
end


"""
    run_model(g_file, p_file, link_file, model_type, optimizer, build_method; kwargs...)

    Instantiates and solves a GasPowerModels modeling object from gas and power input
    files `g_file` and `p_file`. Additionally, `link_file` is an input file that links
    gas and power networks, `model_type` is the gas-power modeling type, and
    `build_method` is the build method for the problem specification being considered.
    Returns a dictionary of model results.
"""
function run_model(
    g_file::String, p_file::String, link_file::String, model_type::Type, optimizer,
    build_method::Function; kwargs...)
    # Read gas, power, and linking data from files.
    data = parse_files(g_file, p_file, link_file)

    # Solve the model and return the result dictionary.
    return run_model(data, model_type, optimizer, build_method; kwargs...)
end


function ref_add_core!(ref::Dict{Symbol, <:Any})
    # Populate the GasModels portion of the `ref` dictionary.
    _GM._ref_add_core!(
        ref[:it][_GM.gm_it_sym][:nw], ref[:it][_GM.gm_it_sym][:base_length],
        ref[:it][_GM.gm_it_sym][:base_pressure], ref[:it][_GM.gm_it_sym][:base_flow],
        ref[:it][_GM.gm_it_sym][:sound_speed])

    # Populate the PowerModels portion of the `ref` dictionary.
    _PM.ref_add_core!(ref)

    # Filter out inactive link components.
    _ref_filter_deps!(ref)
end


function _ref_filter_deps!(ref::Dict{Symbol, <:Any})
    for (nw, nw_ref) in ref[:it][:dep][:nw]
        nw_ref[:delivery_gen] = Dict(x for x in nw_ref[:delivery_gen] if x.second["status"] != 0)
    end
end
