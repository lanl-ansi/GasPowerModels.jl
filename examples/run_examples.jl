using GasPowerModels
using Test

import Gurobi
import JuMP
import SCIP

# Set up optimization solvers that will be used.
env = Gurobi.Env();
gurobi_solver = JuMP.optimizer_with_attributes(() -> Gurobi.Optimizer(env));
scip_solver = JuMP.optimizer_with_attributes(SCIP.Optimizer);
misocp_solver = mip_solver = lp_solver = gurobi_solver;
minlp_solver = nlp_solver = scip_solver;

# Silence all logging messages from GasPowerModels.
GasPowerModels.silence();

@testset "Examples" begin
    include("neopf_belgian.jl");
    include("neopf_northeast.jl")
end
