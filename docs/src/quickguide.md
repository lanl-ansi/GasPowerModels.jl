# Quick Start Guide

Once GasGrid Models is installed, Pavito is installed, and network data files (e.g. `"test/data/belgion.json"`, `"test/data/case14.m"`) have been acquired, a Gas and Power Flow with SOC relaxations can be executed with,

```julia
using GasPowerModels
using Pavito

run_gpf("../test/data/case14.m", "../test/data/belgian.json", SOCWRPowerModel, MISOCPGasModel, PavitoSolver())
```

Similarly, a full non-convex Gas and Power Flow can be executed with a MINLP solver like

```julia
run_gpf("../test/data/case14.m", "../test/data/belgian.json", ACPowerModel, MINLPGasModel, PavitoSolver())
```


## Getting Results

The run commands in GasPowerModels return detailed results data in the form of a dictionary.
This dictionary can be saved for further processing as follows,

```julia
run_gpf("../test/data/case14.m", "../test/data/belgian.json", SOCWRPowerModel, MISOCPGasModel, PavitoSolver())
```

For example, the algorithm's runtime and final objective value can be accessed with,

```
result["solve_time"]
result["objective"]
```

The `"solution"` field contains detailed information about the solution produced by the run method.
For example, the following dictionary comprehension can be used to inspect the junction pressures in the solution,

```
Dict(name => data["p"] for (name, data) in result["solution"]["junction"])
```

For more information about GasPowerModels result data see the [GasPowerModels Result Data Format](@ref) section.


## Inspecting the Formulation
The following example demonstrates how to break a `run_gpf` call into separate model building and solving steps.  This allows inspection of the JuMP model created by GasPowerModels for the gas flow problem,

```julia
pm, gm = build_generic_model("../test/data/case14.m", "../test/data/belgian.json", SOCWRPowerModel, MISOCPGasModel, GasPowerModels.post_gpf)

print(gm.model)
print(pm.model)

solve_generic_model(pm, gm, PavitoSolver())
```
