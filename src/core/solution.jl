function build_solution{T, P, G}(ggm::GenericGasGridModel{T}, pm::GenericPowerModel{P}, gm::GenericGasModel{G}, status, solve_time; objective = NaN, solution_builder = get_solution)
    if status != :Error
        objective = getobjectivevalue(ggm.model)
        status = solver_status_dict(Symbol(typeof(ggm.model.solver).name.module), status)
    end

    solution = Dict{AbstractString,Any}(
        "solver" => string(typeof(ggm.model.solver)),
        "status" => status,
        "objective" => objective,
        "objective_lb" => guard_getobjbound(ggm.model),
        "solve_time" => solve_time,
        "solution" => solution_builder(ggm, pm, gm),
        "machine" => Dict(
            "cpu" => Sys.cpu_info()[1].model,
            "memory" => string(Sys.total_memory()/2^30, " Gb")
            ),
        "data" => Dict(
            "name" => ggm.data["name"],
            )
        )

    ggm.solution = solution

    return solution
end

function get_solution{T, P, G}(ggm::GenericGasGridModel{T}, pm::GenericPowerModel{P}, gm::GenericGasModel{G})
    sol = Dict{AbstractString,Any}()
    PowerModels.add_bus_voltage_setpoint(sol, pm)
    PowerModels.add_generator_power_setpoint(sol, pm)
    PowerModels.add_branch_flow_setpoint(sol, pm)
    GasModels.add_junction_pressure_setpoint(sol, gm)    
    return sol
end

solver_status_lookup = Dict{Any, Dict{Symbol, Symbol}}()
solver_status_lookup[:Ipopt] = Dict(:Optimal => :LocalOptimal, :Infeasible => :LocalInfeasible)
solver_status_lookup[:ConicNonlinearBridge] = Dict(:Optimal => :LocalOptimal, :Infeasible => :LocalInfeasible)

# note that AmplNLWriter.AmplNLSolver is the solver type of bonmin
solver_status_lookup[:AmplNLWriter] = Dict(:Optimal => :LocalOptimal, :Infeasible => :LocalInfeasible)

# translates solver status codes to our status codes
function solver_status_dict(solver_module_symbol, status)
    for (st, solver_stat_dict) in solver_status_lookup
        if solver_module_symbol == st
            if status in keys(solver_stat_dict)
                return solver_stat_dict[status]
            else
                return status
            end
        end
    end
    return status
end

function guard_getobjbound(model)
    try
        getobjbound(model)
    catch
        -Inf
    end
end

function add_setpoint{T}(sol, ggm::GenericGasGridModel{T}, dict_name, param_name, variable_symbol; index_name = nothing, default_value = (item) -> NaN, scale = (x,item) -> x, extract_var = (var,idx,item) -> var[idx])
    sol_dict = get(sol, dict_name, Dict{String,Any}())
    if length(ggm.data[dict_name]) > 0
        sol[dict_name] = sol_dict
    end
    
    for (i,item) in ggm.data[dict_name]
        idx = parse(Int64,i)        
        if index_name != nothing
            idx = Int(item[index_name])
        end
        sol_item = sol_dict[i] = get(sol_dict, i, Dict{String,Any}())
        sol_item[param_name] = default_value(item)
        try
            var = extract_var(ggm.var[variable_symbol], idx, item)
            sol_item[param_name] = scale(getvalue(var), item)
        catch
        end
    end
end


