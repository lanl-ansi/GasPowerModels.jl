using InfrastructureModels
using PowerModels
using GasModels
using GasGridModels
using Memento

# Suppress warnings during testing.
setlevel!(getlogger(GasModels), "error")

using Logging

if VERSION < v"0.7.0-"
    # suppress warnings during testing
    Logging.configure(level=ERROR)
    import Compat: occursin
end

if VERSION > v"0.7.0-"
    # suppress warnings during testing
    disable_logging(Logging.Warn)
end


using Ipopt
using Pavito
using Cbc
using AmplNLWriter
using GLPKMathProgInterface

using Compat.Test



bonmin_solver = AmplNLSolver("bonmin")
couenne_solver =  AmplNLSolver("couenne")
cbc_solver     = CbcSolver()
glpk_solver = GLPKSolverMIP()
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
