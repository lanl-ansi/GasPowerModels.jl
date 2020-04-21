
""
function build_solution(pm::AbstractPowerModel, gm::GenericGasModel, status, solve_time; objective = NaN, solution_builder = get_solution)
    if status != :Error
        objective = JuMP.objective_value(gm.model)
        status = _GM.optimizer_status_dict(Symbol(typeof(gm.model.moi_backend).name.module), status)
    end

    solution = Dict{AbstractString,Any}(
        "optimizer" => string(typeof(gm.model.moi_backend.optimizer)), 
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

function get_solution(pm::AbstractPowerModel, gm::GenericGasModel)
    sol = Dict{AbstractString,Any}()
    _PM.add_setpoint_bus_voltage!(sol, pm)
    _PM.add_setpoint_generator_power!(sol, pm)
    _PM.add_setpoint_branch_flow!(sol, pm)
    _GM.add_junction_pressure_setpoint(sol, gm)
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
