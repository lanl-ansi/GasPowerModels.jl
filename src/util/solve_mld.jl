function solve_mld_gas_prioritized(data::Dict{String, Any}, model_type::Type, optimizer; kwargs...)
    # Solve the MLD problem with only gas prioritized.
    data["ng_load_priority"], data["ep_load_priority"] = 1.0, 0.0
    gpm = instantiate_model(data, model_type, build_mld; kwargs...)    
    result_1 = _IM.optimize_model!(gpm, optimizer = optimizer)

    if result_1["termination_status"] in [TIME_LIMIT, INFEASIBLE]
        return result_1
    else
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
end

function solve_mld_power_prioritized(data::Dict{String, Any}, model_type::Type, optimizer; kwargs...)
    # Solve the MLD problem with only power prioritized.
    data["ng_load_priority"], data["ep_load_priority"] = 0.0, 1.0
    gpm = instantiate_model(data, model_type, build_mld; kwargs...)    
    result_1 = _IM.optimize_model!(gpm, optimizer = optimizer)

    if result_1["termination_status"] in [TIME_LIMIT, INFEASIBLE]
        return result_1
    else
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
end

function solve_mld(data::Dict{String, Any}, model_type::Type, optimizer, alpha::Float64; kwargs...)
    data["ng_load_priority"], data["ep_load_priority"] = alpha, 1.0 - alpha
    
    if alpha <= 0.0
        result = solve_mld_gas_prioritized(data, model_type, optimizer)
    elseif alpha >= 1.0
        result = solve_mld_power_prioritized(data, model_type, optimizer)
    else
        result = run_mld(data, model_type, optimizer)
    end

    if result["primal_status"] == FEASIBLE_POINT
        # Get all delivery generator linking components.
        delivery_gens = data["link_component"]["delivery_gen"]

        # Get a list of delivery indices associated with generation production.
        dels_exclude = [x["delivery"]["id"] for (i, x) in delivery_gens]

        # Include only deliveries that are dispatchable within the objective.
        dels = filter(x -> x.second["is_dispatchable"] == 1, data["it"]["ng"]["delivery"])

        # Include only non-generation deliveries within the objective.
        dels_non_power = filter(x -> !(x.second["index"] in dels_exclude), dels)
        delivery_sol = result["solution"]["it"]["ng"]["delivery"]

        if length(delivery_sol) > 0
            gas_load_served = sum([delivery["fd"] for (i, delivery) in delivery_sol])
            result["gas_load_served"] = gas_load_served
        else
            result["gas_load_served"] = 0.0
        end

        if length(dels_non_power) > 0
            gas_load_nonpower_served = sum([delivery_sol[string(i)]["fd"] for i in keys(dels_non_power)])
            result["gas_load_nonpower_served"] = gas_load_nonpower_served
        else
            result["gas_load_nonpower_served"] = 0.0
        end

        power_load_sol = result["solution"]["it"]["ep"]["load"] 

        if length(power_load_sol) > 0
            active_power_served = sum([abs(load["pd"]) for (i, load) in power_load_sol])
            result["active_power_served"] = active_power_served

            reactive_power_served = sum([abs(load["qd"]) for (i, load) in power_load_sol])
            result["reactive_power_served"] = reactive_power_served
        else
            result["active_power_served"] = 0.0
            result["reactive_power_served"] = 0.0
        end
    end

    return result
end