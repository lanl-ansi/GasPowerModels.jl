using InfrastructureModels
using PowerModels
using GasModels
using GasPowerModels
using Memento

# Suppress warnings during testing.
setlevel!(getlogger(GasModels), "error")

GasPowerModels.silence()


#bonmin_solver = AmplNLSolver("bonmin")
#couenne_solver =  AmplNLSolver("couenne")
#cbc_solver     = CbcSolver()
#glpk_solver = GLPKSolverMIP()
#ipopt_solver = IpoptSolver(tol=1e-6, print_level=0)
#pavito_glpk_solver = PavitoSolver(mip_solver=glpk_solver, cont_solver=ipopt_solver, mip_solver_drives=false, log_level=1)
#pavito_cbc_solver = PavitoSolver(mip_solver=cbc_solver, cont_solver=ipopt_solver, mip_solver_drives=false, log_level=1)

using JuMP
using Ipopt
using Cbc
using Juniper
using Test


ipopt_solver = JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-6, print_level=0, sb="yes")
cbc_solver = JuMP.with_optimizer(Cbc.Optimizer, logLevel=0)
juniper_solver = JuMP.with_optimizer(Juniper.Optimizer,
    nl_solver=JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-4, print_level=0),
    mip_solver=cbc_solver, log_levels=[])

misocp_solver = juniper_solver
minlp_solver = juniper_solver

#using Gurobi
#gurobi_solver = JuMP.with_optimizer(Gurobi.Optimizer)
#misocp_solver = gurobi_solver

include("data.jl")
include("gpf.jl")
include("ne.jl")
