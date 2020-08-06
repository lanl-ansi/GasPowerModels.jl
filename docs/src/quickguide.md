# Quick Start Guide
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

### Installation of Optimization Solvers
At least one optimization solver is required to run GasPowerModels.
The solver selected typically depends on the type of problem formulation being employed.
As an example, the mixed-integer nonlinear programming solver [Juniper](https://github.com/lanl-ansi/Juniper.jl) can be used for testing any of the problem formulations considered in this package.
Juniper itself depends on the installation of a nonlinear programming solver (e.g., [Ipopt](https://github.com/jump-dev/Ipopt.jl)) and a mixed-integer linear programming solver (e.g., [CBC](https://github.com/jump-dev/Cbc.jl)).
Installation of the JuMP interfaces to Juniper, Ipopt, and Cbc can be performed via the Julia package manager, i.e.,

```julia
] add JuMP Juniper Ipopt Cbc
```

## Solving an Optimal Gas-Power Flow with Network Expansion Problem
Once the above dependencies have been installed, obtain the files [`belgian-ne_opf.m`](https://raw.githubusercontent.com/lanl-ansi/GasPowerModels.jl/master/examples/data/matgas/belgian-ne_opf.m) and [`case14-ne.m`](https://raw.githubusercontent.com/lanl-ansi/GasPowerModels.jl/master/examples/data/matpower/case14-ne.m).
Here, `belgian-ne_opf.m` is a MATGAS file describing a portion of the Belgian gas network.
In accord, `case14-ne.m` is a MATPOWER file specifying a 14-bus power network.
The combination of data from these two files provides the required information to set up the problem.
After downloading the data, the optimal gas-power flow with network expansion problem can be solved with
```julia
using JuMP, Juniper, Ipopt, Cbc
using GasPowerModels

# Set up the optimization solvers.
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level"=>0, "sb"=>"yes")
cbc = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel"=>0)
juniper = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver"=>ipopt, "mip_solver"=>cbc)

# Specify paths to the gas and power network files.
g_file = "examples/data/matgas/belgian-ne_opf.m" # Gas network.
p_file = "examples/data/matpower/case14-ne.m" # Power network.

# Specify the gas and power formulation types separately.
g_type, p_type = MISOCPGasModel, SOCWRPowerModel

# Solve the optimal gas-power flow with network expansion problem.
result = run_ne_ogpf(g_file, p_file, g_type, p_type, juniper;
    gm_solution_processors=[GasPowerModels._GM.sol_psqr_to_p!],
    pm_solution_processors=[GasPowerModels._PM.sol_data_model!])
```
