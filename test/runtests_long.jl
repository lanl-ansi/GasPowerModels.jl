using PowerModels
using GasModels
using GasGridModels

using Ipopt
using Pavito
using Cbc
using AmplNLWriter
using GLPKMathProgInterface
using Gurobi

using Compat.Test

bonmin_solver = AmplNLSolver("bonmin")
couenne_solver =  AmplNLSolver("couenne")
cbc_solver     = CbcSolver()
#gurobi_solver = GurobiSolver(Presolve=0, FeasibilityTol=1e-9, OptimalityTol=1e-9, IntFeasTol=1e-9)
gurobi_solver = GurobiSolver()
glpk_solver = GLPKSolverMIP()
ipopt_solver = IpoptSolver(tol=1e-6, print_level=0)
pavito_glpk_solver = PavitoSolver(mip_solver=glpk_solver, cont_solver=ipopt_solver, mip_solver_drives=false, log_level=1)
pavito_cbc_solver = PavitoSolver(mip_solver=cbc_solver, cont_solver=ipopt_solver, mip_solver_drives=false, log_level=1)

misocp_solver = gurobi_solver
minlp_solver = couenne_solver

include("neopf.jl")
include("neopf_long.jl")
