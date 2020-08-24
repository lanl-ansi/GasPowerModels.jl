# GasPowerModels Result Data Format

## The Result Data Dictionary
GasPowerModels uses a dictionary to organize the results of a `run_` command.
The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange.
The data dictionary organization is designed to be consistent with the GasPowerModels [The Network Data Dictionary](@ref).

At the top level the results data dictionary is structured as follows:

```json
{
    "optimizer": <string>,                # name of the JuMP optimizer used to solve the model
    "termination_status": <julia symbol>, # solver status at termination
    "dual_status": <julia symbol>,        # dual feasibility status at termination
    "primal_status": <julia symbol>,      # primal feasibility status at termination
    "solve_time": <float>,                # reported time required for solution
    "objective": <float>,                 # the final evaluation of the objective function
    "objective_lb": <float>,              # the final lower bound of the objective function (if available)
    "solution": {...}                     # problem solution information (details below)
}
```

### Solution Data
The solution object provides detailed information about the problem solution produced by the `run` command.
The solution is organized similarly to [The Network Data Dictionary](@ref) with the same nested structure and parameter names, when available.
A network solution most often only includes a small subset of the data included in the network data.
For example the data for a gas network junction, e.g., `g_data["junction"]["1"]` is structured as follows:
```json
{
    "lat": 0.0,
    ...
}
```

A solution specifying a pressure for the same object, i.e., `result["solution"]["junction"]["1"]`, would result in,

```json
{
    "psqr": 0.486908,
    "p": 0.697788
}
```

Because the data dictionary and the solution dictionary have the same structure, the InfrastructureModels `update_data!` helper function can be used to update a data dictionary with values from a solution, e.g.,
```
GasPowerModels._IM.update_data!(g_data["junction"]["1"], result["solution"]["junction"]["1"])
```
By default, all results are reported per-unit (non-dimensionalized).
Functions from GasModels and PowerModels can be used to convert such data back to their dimensional forms.
