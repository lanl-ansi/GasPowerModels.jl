# GasPowerModels.jl 
[![Build Status](https://github.com/lanl-ansi/GasPowerModels.jl/workflows/CI/badge.svg?branch=master)](https://github.com/lanl-ansi/GasPowerModels.jl/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/lanl-ansi/GasPowerModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/lanl-ansi/GasPowerModels.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://lanl-ansi.github.io/GasPowerModels.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://lanl-ansi.github.io/GasPowerModels.jl/dev)

GasPowerModels.jl is a Julia/JuMP package for the joint optimization of steady state natural gas and power transmission networks.
It provides utilities for modeling problems that combine elements of natural gas and electric power systems.
It is designed to enable the computational evaluation of historical and emerging gas-power network optimization formulations and algorithms using a common platform.
The code is engineered to decouple problem specifications (e.g., gas-power flow, network expansion planning) from network formulations (e.g., mixed-integer convex, mixed-integer nonconvex).
This decoupling enables the definition of a variety of optimization formulations and their comparison on common problem specifications.

**Core Problem Specifications**
* Gas-Power Flow (`gpf`)
* Maximum Load Delivery (`mld`)
* Maximum Load Delivery - Unit Commitment  (`mld_uc`)
* Optimal Power Flow (`opf`)
* Network Expansion Planning (`ne`)
* Optimal Power Flow with Network Expansion Planning (`opf_ne`)

## Documentation
The package [documentation](https://lanl-ansi.github.io/GasPowerModels.jl/stable/) includes a [quick start guide](https://lanl-ansi.github.io/GasPowerModels.jl/stable/quickguide).

## Installation
The latest stable release of GasPowerModels can be installed using the Julia package manager with
```julia
] add GasPowerModels
```

For the current development version, install the package using
```julia
] add GasPowerModels#master
```

Finally, test that the package works as expected by executing
```julia
] test GasPowerModels
```

## Usage at a Glance
At least one optimization solver is required to run GasPowerModels.
The solver selected typically depends on the type of problem formulation being employed.
As an example, the mixed-integer nonlinear programming solver [Juniper](https://github.com/lanl-ansi/Juniper.jl) can be used for testing any of the problem formulations considered in this package.
Juniper itself depends on the installation of a nonlinear programming solver (e.g., [Ipopt](https://github.com/jump-dev/Ipopt.jl)) and a mixed-integer linear programming solver (e.g., [CBC](https://github.com/jump-dev/Cbc.jl)).
Installation of the JuMP interfaces to Juniper, Ipopt, and Cbc can be performed via the Julia package manager, i.e.,

```julia
] add JuMP Juniper Ipopt Cbc
```

After installation of the required solvers, an example gas-power flow feasibility problem (whose file inputs can be found in the `test` directory within the [GasPowerModels repository](https://github.com/lanl-ansi/GasPowerModels.jl)) can be solved via
```julia
using JuMP, Juniper, Ipopt, Cbc
using GasPowerModels

# Set up the optimization solvers.
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0, "sb" => "yes")
cbc = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel" => 0)
juniper = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver" => ipopt, "mip_solver" => cbc)

# Specify paths to the gas, power, and linking files.
g_file = "test/data/matgas/GasLib-11-GPF.m" # Gas network.
p_file = "test/data/matpower/case5-GPF.m" # Power network.
link_file = "test/data/json/GasLib-11-case5.json" # Linking data.

# Specify the gas-power formulation type.
gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}

# Solve the gas-power flow (gpf) feasibility problem.
result = run_gpf(g_file, p_file, link_file, gpm_type, juniper;
    solution_processors = [GasPowerModels._GM.sol_psqr_to_p!,
    GasPowerModels._PM.sol_data_model!])
```

After solving the problem, results can then be analyzed, e.g.,
```julia
# The termination status of the optimization solver.
result["termination_status"]

# Generator 1's active (real) power generation.
result["solution"]["it"]["pm"]["gen"]["1"]["pg"]

# Junction 1's pressure.
result["solution"]["it"]["gm"]["junction"]["1"]["p"]
```

## Acknowledgments
The primary developers are Russell Bent, Kaarthik Sundar, and Byron Tasseff.
Significant contributions on the technical model were made by Conrado Borraz-Sanchez, Pascal Van Hentenryck, and Seth Blumsack.
Special thanks to Miles Lubin and Carleton Coffrin for their assistance in integrating with Julia/JuMP and PowerModels.jl.

## License
This code is provided under a BSD license as part of the Multi-Infrastructure Control and Optimization Toolkit (MICOT) project, LA-CC-13-108.
