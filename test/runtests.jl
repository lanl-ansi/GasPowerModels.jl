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
ipopt = JuMP.with_optimizer(Ipopt.Optimizer, tol=1.0e-4, print_level=0, sb="yes")
cbc = JuMP.with_optimizer(Cbc.Optimizer, logLevel=0)
juniper = JuMP.with_optimizer(Juniper.Optimizer, nl_solver=ipopt, mip_solver=cbc, log_levels=[])

@testset "GasPowerModels" begin

    include("data.jl")

    include("gpf.jl")

    include("ne.jl")

end
