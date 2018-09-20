using PowerModels
using GasModels
using GasGridModels
using Memento

# Suppress warnings during testing.
setlevel!(getlogger(InfrastructureModels), "error")
setlevel!(getlogger(PowerModels), "error")
setlevel!(getlogger(GasModels), "error")

using Logging

using Ipopt
using Pavito
using Cbc
using AmplNLWriter
using CoinOptServices
using GLPKMathProgInterface

using Base.Test



bonmin_solver  = AmplNLSolver(CoinOptServices.bonmin)
couenne_solver = AmplNLSolver(CoinOptServices.couenne)
cbc_solver     = CbcSolver()
glpk_solver = GLPKSolverMIP(msg_lev=GLPK.MSG_OFF)
ipopt_solver = IpoptSolver(tol=1e-6, print_level=0)
pavito_glpk_solver = PavitoSolver(mip_solver=glpk_solver, cont_solver=ipopt_solver, mip_solver_drives=false, log_level=1)
pavito_cbc_solver = PavitoSolver(mip_solver=cbc_solver, cont_solver=ipopt_solver, mip_solver_drives=false, log_level=1)

misocp_solver = pavito_cbc_solver
minlp_solver = couenne_solver   

#using Gurobi
#gurobi_solver = GurobiSolver()
#misocp_solver = gurobi_solver

include("ne.jl")
include("data.jl")
include("gpf.jl")

