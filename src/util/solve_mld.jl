function solve_mld_gas_prioritized(data::Dict{String, Any}, model_type::Type, optimizer; kwargs...)
    # Solve the MLD problem with only gas prioritized.
    gpm = instantiate_model(data, model_type, build_mld; kwargs...)    
    gas_obj_expr = objective_max_gas_load(gpm) # Get the gas objective.
    result_1 = _IM.optimize_model!(gpm, optimizer = optimizer)

    if result_1["termination_status"] in [TIME_LIMIT, INFEASIBLE, INFEASIBLE_OR_UNBOUNDED]
        return result_1
    else
        # Set up the MLD problem with power prioritized.
        JuMP.@constraint(gpm.model, gas_obj_expr >= result_1["objective"] - 1.0e-7)
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
    gpm = instantiate_model(data, model_type, build_mld; kwargs...)    
    power_obj_expr = objective_max_power_load(gpm) # Get the power objective.
    result_1 = _IM.optimize_model!(gpm, optimizer = optimizer)

    if result_1["termination_status"] in [TIME_LIMIT, INFEASIBLE, INFEASIBLE_OR_UNBOUNDED]
        return result_1
    else
        # Set up the MLD problem with gas prioritized.
        JuMP.@constraint(gpm.model, power_obj_expr >= result_1["objective"] - 1.0e-7)
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
    data["gm_load_priority"] = alpha
    data["pm_load_priority"] = 1.0 - alpha
    
    if alpha >= 1.0
        result = solve_mld_gas_prioritized(data, model_type, optimizer; kwargs...)
    elseif alpha <= 0.0
        result = solve_mld_power_prioritized(data, model_type, optimizer; kwargs...)
    else
        sol_proc = [_GM.sol_psqr_to_p!, _PM.sol_data_model!] 
        result = run_mld(data, model_type, optimizer; solution_processors = sol_proc, kwargs...)
    end

    if result["primal_status"] == FEASIBLE_POINT
        # Get all delivery generator linking components.
        delivery_gens = data["it"]["dep"]["delivery_gen"]

        # Get a list of delivery indices associated with generation production.
        dels_exclude = [x["delivery"]["id"] for (i, x) in delivery_gens]

        # Include only deliveries that are dispatchable within the objective.
        dels = filter(x -> x.second["is_dispatchable"] == 1, data["it"][_GM.gm_it_name]["delivery"])
        dels = filter(x -> x.second["status"] != 0, dels)

        # Include only non-generation deliveries within the objective.
        dels_non_power = filter(x -> !(x.second["index"] in dels_exclude), dels)
        delivery_sol = result["solution"]["it"][_GM.gm_it_name]["delivery"]
        
        if haskey(data["it"]["gm"], "standard_density")
            standard_density = data["it"]["gm"]["standard_density"]
        else
            standard_density = _GM._estimate_standard_density(data)
        end

        if length(delivery_sol) > 0
            gas_load_served = sum([delivery["fd"] for (i, delivery) in delivery_sol])
            gas_coeff = data["it"]["gm"]["base_flow"] / standard_density
            result["gas_load_served"] = gas_coeff * gas_load_served
        else
            result["gas_load_served"] = 0.0
        end

        if length(dels_non_power) > 0
            gas_load_nonpower_served = sum([delivery_sol[i]["fd"] for i in keys(dels_non_power)])
            gas_coeff = data["it"]["gm"]["base_flow"] / standard_density
            result["gas_load_nonpower_served"] = gas_coeff * gas_load_nonpower_served
        else
            result["gas_load_nonpower_served"] = 0.0
        end

        power_load_sol = result["solution"]["it"][_PM.pm_it_name]["load"] 

        if length(power_load_sol) > 0
            active_power_served = sum([abs(load["pd"]) for (i, load) in power_load_sol])
            result["active_power_served"] = data["it"]["pm"]["baseMVA"] * active_power_served

            reactive_power_served = sum([abs(load["qd"]) for (i, load) in power_load_sol])
            result["reactive_power_served"] = data["it"]["pm"]["baseMVA"] * reactive_power_served
        else
            result["active_power_served"] = 0.0
            result["reactive_power_served"] = 0.0
        end
    end

    return result
end
