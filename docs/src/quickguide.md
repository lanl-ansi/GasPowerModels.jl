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

## Solving a Problem
Once the above dependencies have been installed, obtain the files [`belgian-ne_opf.m`](https://raw.githubusercontent.com/lanl-ansi/GasPowerModels.jl/master/examples/data/matgas/belgian-ne_opf.m) and [`case14-ne.m`](https://raw.githubusercontent.com/lanl-ansi/GasPowerModels.jl/master/examples/data/matpower/case14-ne.m).
Here, `belgian-ne_opf.m` is a MATGAS file describing a portion of the Belgian gas network.
In accord, `case14-ne.m` is a MATPOWER file specifying a 14-bus power network.
The combination of data from these two files provides the required information to set up the problem.
After downloading the data, the optimal power flow with network expansion problem can be solved with
```julia
using JuMP, Juniper, Ipopt, Cbc
using GasPowerModels

# Set up the optimization solvers.
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level"=>0, "sb"=>"yes")
cbc = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel"=>0)
juniper = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver"=>ipopt, "mip_solver"=>cbc)

# Specify paths to the gas and power network files.
g_file = "test/data/matgas/GasLib-11-NE.m" # Gas network.
p_file = "test/data/matpower/case5-NE.m" # Power network.

# Specify the gas and power formulation types separately.
g_type, p_type = CRDWPGasModel, SOCWRPowerModel

# Solve the optimal power flow with network expansion problem.
result = run_ne_opf(g_file, p_file, g_type, p_type, juniper;
    gm_solution_processors=[GasPowerModels._GM.sol_psqr_to_p!],
    pm_solution_processors=[GasPowerModels._PM.sol_data_model!])
```

## Obtaining Results
The `run` commands in GasPowerModels return detailed results data in the form of a Julia `Dict`.
This dictionary can be saved for further processing as follows:
```julia
result = run_ne_opf(g_file, p_file, g_type, p_type, juniper;
    gm_solution_processors=[GasPowerModels._GM.sol_psqr_to_p!],
    pm_solution_processors=[GasPowerModels._PM.sol_data_model!])
```

For example, the algorithm's runtime and final objective value can be accessed with
```julia
result["solve_time"] # Total solve time required (seconds).
result["objective"] # Final objective value (in units of the objective).
```

The `"solution"` field contains detailed information about the solution produced by the `run` method.
For example, the following can be used to read the build status of the network expansion pipe in the gas system
```julia
result["solution"]["ne_pipe"]["16"]["z"]
```
As another example, the following can be used to inspect pressures in the solution
```julia
Dict(name => data["p"] for (name, data) in result["solution"]["junction"])
```
As a final example, the following can be used to inspect real power generation in the solution
```julia
Dict(name => data["pg"] for (name, data) in result["solution"]["gen"])
```

For more information about GasPowerModels result data, see the [GasPowerModels Result Data Format](@ref) section.

## Accessing Different Formulations
To solve the preceding problem using the mixed-integer nonconvex model for natural gas flow, the following can be executed:
```julia
# Specify the gas and power formulation types separately.
g_type, p_type = DWPGasModel, SOCWRPowerModel

# Solve the optimal power flow with network expansion problem.
result = run_ne_opf(g_file, p_file, g_type, p_type, juniper;
    gm_solution_processors=[GasPowerModels._GM.sol_psqr_to_p!],
    pm_solution_processors=[GasPowerModels._PM.sol_data_model!])
```

## Modifying Network Data
The following example demonstrates one way to perform GasPowerModels solves while modifying network data.
```julia
# Read in the gas and power network data.
g_data = GasPowerModels._GM.parse_file(g_file)
p_data = GasPowerModels._PM.parse_file(p_file)

# Ensure the two datasets use the same units for power.
resolve_units!(g_data, p_data)

# Reduce the minimum pressures for selected nodes.
g_data["junction"]["1"]["p_min"] *= 0.1
g_data["junction"]["2"]["p_min"] *= 0.1
g_data["junction"]["3"]["p_min"] *= 0.1

# Solve the problem using `g_data` and `p_data`.
result_mod = run_ne_opf(g_data, p_data, g_type, p_type, juniper;
    gm_solution_processors=[GasPowerModels._GM.sol_psqr_to_p!],
    pm_solution_processors=[GasPowerModels._PM.sol_data_model!])
```

## Alternate Methods for Building and Solving Models
The following example demonstrates how to decompose a `run_ne_opf` call into separate model building and solving steps.
This allows inspection of the JuMP model created by GasPowerModels:
```julia
# Read in the gas and power network data.
g_data = GasPowerModels._GM.parse_file(g_file)
p_data = GasPowerModels._PM.parse_file(p_file)

# Ensure the two datasets use the same units for power.
resolve_units!(g_data, p_data)

# Store the required `ref` extensions for the problem.
gm_ref_extensions = [GasPowerModels._GM.ref_add_ne!, ref_add_price_zones!]
pm_ref_extensions = [GasPowerModels._PM.ref_add_on_off_va_bounds!, GasPowerModels._PM.ref_add_ne_branch!]

# Instantiate the model.
gm, pm = instantiate_model(g_data, p_data, g_type, p_type, build_ne_opf,
    gm_ref_extensions=gm_ref_extensions, pm_ref_extensions=pm_ref_extensions)

# Print the contents of the JuMP model.
println(gm.model)
```

The problem can then be solved and its two result dictionaries can be stored via:
```julia
# Create separate gas and power result dictionaries.
gas_result = GasPowerModels._IM.optimize_model!(gm, optimizer=juniper)
power_result = GasPowerModels._IM.build_result(pm, gas_result["solve_time"])
```
