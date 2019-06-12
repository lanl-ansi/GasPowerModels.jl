# GasPowerModels Result Data Format

## The Result Data Dictionary

GasPowerModels utilizes a dictionary to organize the results of a run command. The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange.
The data dictionary organization is designed to be consistent with the GasModels [The Network Data Dictionary](@ref).

At the top level the results data dictionary is structured as follows:

```json
{
"solver":<string>,       # name of the Julia class used to solve the model
"status":<julia symbol>, # solver status at termination
"solve_time":<float>,    # reported solve time (seconds)
"objective":<float>,     # the final evaluation of the objective function
"objective_lb":<float>,  # the final lower bound of the objective function (if available)
"machine":{...},         # computer hardware information (details below)
"data":{...},            # test case information (details below)
"solution":{...}         # complete solution information (details below)
}
```

### Machine Data

This object provides basic information about the hardware that was 
used when the run command was called.

```json
{
"cpu":<string>,    # CPU product name
"memory":<string>  # the amount of system memory (units given)
}
```

### Solution Data

The solution object provides detailed information about the solution 
produced by the run command.  The solution is organized similarly to 
[The Network Data Dictionary](@ref) with the same nested structure and 
parameter names, when available.  A network solution most often only includes
a small subset of the data included in the network data.

For example the data for a junction, `data["price_zone"]["1"]` is structured as follows,

```
{
"min_cost": 700,
...
}
```

A solution specifying a pressure for the same case, i.e. `result["solution"]["price_zone"]["1"]`, would result in,

```
{
"ql": 200,
}
```

Because the data dictionary and the solution dictionary have the same structure 
InfrastructureModels `update_data!` helper function can be used to 
update a data dictionary with the values from a solution as follows,

```
InfrastructureModels.update_data!(data, result["solution"])
```

By default, all results are reported in per-unit (non-dimenionalized). Below are common outputs of implemented optimization models

GasModels.add_setpoint(sol, gm, "price_zone", "lm",    :zone_cost)
    GasModels.add_setpoint(sol, gm, "price_zone", "lf",    :zone_fl)
    GasModels.add_setpoint(sol, gm, "price_zone", "lq",    :zone_ql, scale = (x,item) -> GasModels.getvalue(x) / gm.data["standard_density"])  
    GasModels.add_setpoint(sol, gm, "price_zone", "lp",    :p_cost)
    GasModels.add_setpoint(sol, gm, "price_zone", "max_p", :zone_p)  


```json
{
"price_zone":{
    "1":{
      "lm": <float>,     # cost incurred by the zone for satisfying non firm demand. 
      "lf": <float>,     # non firm demand in the zone in terms of mass flux. Reported in per unit,  Multiply by baseQ to get kg/s
      "lq": <float>,     # non firm demand in the zone in terms of volume flux. Reported in per unit,  Multiply by baseQ to get m^3/s     
      "lp": <float>,     # cost incurred by the zone by high pressure     
      "max_p": <float>,  # Maximum pressure squared in the zone. Reported in per unit.  Multiply by baseP^2 to get pascals   
      ...
    },
    "2":{...},
    ...
}}
```

