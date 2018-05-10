using PowerModels
using GasModels
using GasGridModels

using Logging

using Ipopt
using Pajarito
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
pajarito_glpk_solver = PajaritoSolver(mip_solver=glpk_solver, cont_solver=ipopt_solver, log_level=1)
pajarito_cbc_solver = PajaritoSolver(mip_solver=cbc_solver, cont_solver=ipopt_solver, log_level=1)

misocp_solver = pajarito_cbc_solver
minlp_solver = couenne_solver   

include("data.jl")
include("gpf.jl")
include("ne.jl")

