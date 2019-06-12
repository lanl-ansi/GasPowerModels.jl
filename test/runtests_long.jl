using PowerModels
using GasModels
using GasPowerModels
using InfrastructureModels

using Ipopt
using Cbc
using AmplNLWriter
using Gurobi
using JuMP
using Juniper
using CPLEX
using Memento
using Test

ipopt_solver = JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-6, print_level=0, sb="yes")
cbc_solver = JuMP.with_optimizer(Cbc.Optimizer, logLevel=0)
juniper_solver = JuMP.with_optimizer(Juniper.Optimizer,
    nl_solver=JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-4, print_level=0),
    mip_solver=cbc_solver, log_levels=[])
gurobi_solver = JuMP.with_optimizer(Gurobi.Optimizer)
cplex_solver = JuMP.with_optimizer(CPLEX.Optimizer, CPX_PARAM_SCRIND = 0)
couenne_solver = JuMP.with_optimizer(AmplNLWriter.Optimizer, "couenne.exe")
bonmin_solver = JuMP.with_optimizer(AmplNLWriter.Optimizer, "bonmin.exe")

misocp_solver = gurobi_solver
minlp_solver = couenne_solver

# Suppress warnings during testing.
Memento.setlevel!(Memento.getlogger(InfrastructureModels), "error")
PowerModels.logger_config!("error")

include("neopf.jl")
include("neopf_long.jl")
