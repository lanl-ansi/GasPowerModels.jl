# GasPowerModels Result Data Format

## The Result Data Dictionary
GasPowerModels uses a dictionary to organize the results of a `run_` command.
The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange.
The data dictionary organization is designed to be consistent with [The Network Data Dictionary](@ref).

At the top level the results data dictionary is structured as follows:
```json
{
  "optimizer": <string>,        # name of the solver used to solve the model
  "termination_status": <type>, # optimizer status at termination
  "dual_status": <type>,        # optimizer dual status at termination
  "primal_status": <type>,      # optimizer primal status at termination
  "solve_time": <float>,        # reported solve time (in seconds)
  "objective": <float>,         # the final evaluation of the objective function
  "objective_lb": <float>,      # the final lower bound of the objective function (if available)
  "solution": {...}             # complete solution information (details below)
}
```

### Solution Data
The solution object provides detailed information about the problem solution produced by the `run` command.
The solution is organized similarly to [The Network Data Dictionary](@ref) with the same nested structure and parameter names, when available.
The solution object merges the solution information for both the power system and the natural gas system into the same object.
For example `result["solution"]["it"]["gm"]["junction"]["1"]` reports all the solution values associated with natural gas junction 1, i.e.,
```json
{
    "psqr": 0.486908,
    "p": 0.697788
}
```
and `result["solution"]["it"]["pm"]["gen"]["1"]` reports all the solution values associated with electric power generator 1, i.e.,
```json
{
    "pg": 1.45,
    "qg": 0.02
}
```

Because the data dictionary and the solution dictionary have the same structure, the InfrastructureModels `update_data!` helper function can be used to update a data dictionary with values from a solution, e.g.,

```
_IM.update_data!(data["it"]["gm"]["junction"]["1"], result["solution"]["it"]["gm"]["junction"]["1"])
```

By default, all results are reported per-unit (non-dimensionalized).
Functions from GasModels and PowerModels can be used to convert such data back to their dimensionalized forms.
