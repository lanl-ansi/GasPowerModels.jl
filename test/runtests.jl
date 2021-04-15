using GasPowerModels

import Memento
import Logging

const _GM = GasPowerModels._GM
const _IM = GasPowerModels._IM
const _PM = GasPowerModels._PM

# Suppress warnings during testing.
Memento.setlevel!(Memento.getlogger(_GM), "error")
Memento.setlevel!(Memento.getlogger(_IM), "error")
Memento.setlevel!(Memento.getlogger(_PM), "error")
GasPowerModels.logger_config!("error")
Logging.disable_logging(Logging.Info)

import Cbc
import Ipopt
import JuMP
import Juniper

using Test

# Setup for optimizers.
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "acceptable_tol" => 1.0e-8, "print_level" => 0, "sb" => "yes")
cbc = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel" => 0)
juniper = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver" => ipopt, "mip_solver" => cbc, "log_levels" => [])

@testset "GasPowerModels" begin

    include("GasPowerModels.jl")

    include("io.jl")

    include("base.jl")

    include("gpf.jl")

    include("mld.jl")

    include("ne.jl")

    include("ne_opf.jl")

    include("opf.jl")

    include("solve_mld.jl")

end
