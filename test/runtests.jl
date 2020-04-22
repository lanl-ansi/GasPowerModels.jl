using GasPowerModels
import Memento

import MathOptInterface
import InfrastructureModels
import GasModels
import PowerModels

const _MOI = MathOptInterface
const _IM = InfrastructureModels
const _GM = GasModels
const _PM = PowerModels

# Suppress warnings during testing.
Memento.setlevel!(Memento.getlogger(_IM), "error")
Memento.setlevel!(Memento.getlogger(_GM), "error")
Memento.setlevel!(Memento.getlogger(_PM), "error")
GasPowerModels.logger_config!("error")

import Cbc
import Ipopt
import JuMP
import Juniper

using Test

# Setup for optimizers.
ipopt = JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-6, print_level=0, sb="yes")
cbc = JuMP.with_optimizer(Cbc.Optimizer, logLevel=0)
juniper = JuMP.with_optimizer(Juniper.Optimizer, nl_solver=JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-4, print_level=0), mip_solver=cbc, log_levels=[])

@testset "GasPowerModels" begin
    include("data.jl")

    include("gpf.jl")

    #include("ne.jl")
end

#using InfrastructureModels
#using PowerModels
#using GasModels
#using GasPowerModels
#using Memento
#
## Suppress warnings during testing.
#setlevel!(getlogger(GasModels), "error")
#GasPowerModels.silence()
#
#
#using JuMP
#using Ipopt
#using Cbc
#using Juniper
#using Test
#
#
#ipopt_solver = JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-6, print_level=0, sb="yes")
#cbc_solver = JuMP.with_optimizer(Cbc.Optimizer, logLevel=0)
#juniper_solver = JuMP.with_optimizer(Juniper.Optimizer,
#    nl_solver=JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-4, print_level=0),
#    mip_solver=cbc_solver, log_levels=[])
#
#misocp_solver = juniper_solver
#minlp_solver = juniper_solver
#
#include("data.jl")
#include("gpf.jl")
#include("ne.jl")
