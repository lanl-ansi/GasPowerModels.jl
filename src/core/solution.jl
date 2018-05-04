function build_solution{P, G}(pm::GenericPowerModel{P}, gm::GenericGasModel{G}, status, solve_time; objective = NaN, solution_builder = get_solution)
    if status != :Error
        objective = getobjectivevalue(gm.model)
        status = solver_status_dict(Symbol(typeof(gm.model.solver).name.module), status)
    end

    solution = Dict{AbstractString,Any}(
        "solver" => string(typeof(gm.model.solver)),
        "status" => status,
        "objective" => objective,
        "objective_lb" => guard_getobjbound(gm.model),
        "solve_time" => solve_time,
        "solution" => solution_builder(pm, gm),
        "machine" => Dict(
            "cpu" => Sys.cpu_info()[1].model,
            "memory" => string(Sys.total_memory()/2^30, " Gb")
            ),
        "data" => Dict(
            )
        )

    gm.solution = solution

    return solution
end

function get_solution{P, G}(pm::GenericPowerModel{P}, gm::GenericGasModel{G})
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

