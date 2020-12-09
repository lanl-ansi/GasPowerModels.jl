function solve_mld_gas_prioritized(data::Dict{String, Any}, model_type::Type, optimizer; kwargs...)
    # Solve the MLD problem with only gas prioritized.
    data["ng_load_priority"], data["ep_load_priority"] = 1.0, 0.0
    gpm = instantiate_model(data, model_type, build_mld; kwargs...)    
    result_1 = _IM.optimize_model!(gpm, optimizer = optimizer)

    # Set up the MLD problem with power prioritized.
    data["ng_load_priority"], data["ep_load_priority"] = 0.0, 1.0
    gpm = instantiate_model(data, model_type, build_mld; kwargs...) 
    gas_obj_expr = objective_max_gas_load(gpm) # Get the gas objective.
    c = JuMP.@constraint(gpm.model, gas_obj_expr >= result_1["objective"])
    power_obj_expr = objective_max_power_load(gpm) # Set the power objective.

    # Solve the final MLD problem.
    sol_proc = [_GM.sol_psqr_to_p!, _PM.sol_data_model!] 
    sol_proc = transform_solution_processors(gpm, sol_proc)
    result_2 = _IM.optimize_model!(gpm, optimizer = optimizer, solution_processors = sol_proc)

    # Include both solve times in the returned solution.
    result_2["solve_time"] += result_1["solve_time"]

    # Return the result dictionary.
    return result_2
end

function solve_mld_power_prioritized(data::Dict{String, Any}, model_type::Type, optimizer; kwargs...)
    # Solve the MLD problem with only power prioritized.
    data["ng_load_priority"], data["ep_load_priority"] = 0.0, 1.0
    gpm = instantiate_model(data, model_type, build_mld; kwargs...)    
    result_1 = _IM.optimize_model!(gpm, optimizer = optimizer)

    # Set up the MLD problem with gas prioritized.
    data["ng_load_priority"], data["ep_load_priority"] = 1.0, 0.0
    gpm = instantiate_model(data, model_type, build_mld; kwargs...)
    power_obj_expr = objective_max_power_load(gpm) # Get the power objective.
    c = JuMP.@constraint(gpm.model, power_obj_expr >= result_1["objective"])
    gas_obj_expr = objective_max_gas_load(gpm) # Get the gas objective.

    # Solve the final MLD problem.
    sol_proc = [_GM.sol_psqr_to_p!, _PM.sol_data_model!] 
    sol_proc = transform_solution_processors(gpm, sol_proc)
    result_2 = _IM.optimize_model!(gpm, optimizer = optimizer, solution_processors = sol_proc)

    # Include both solve times in the returned solution.
    result_2["solve_time"] += result_1["solve_time"]

    # Return the result dictionary.
    return result_2
end