# GasPowerModels Network Data Format
## The Network Data Dictionary
Internally, GasPowerModels uses a dictionary to store network data for power systems (see PowerModels) and gas models (see GasModels.jl).
The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange.
The I/O for GasPowerModels utilizes the serializations available in PowerModels.jl and GasModels.jl to construct the two network models.
All data is assumed to be in per unit (non-dimenisionalized) or SI units.

Besides the standard network data supported by GasModels.jl and PowerModels.jl, there are a few extra fields that are required to couple the two systems together.
These are discussed as follows:

### Gas Networks
```json
{
    "energy_factor": <Float64>,      # Factor for converting the Joules per second used by a generator to m^3 per second gas consumption. SI units are m^3 per Joules.
    "price_zone": {
        "1": {
          "cost_q_1": <Float64>,     # Quadratic coefficient on the cost curve for non-firm gas consumed in the zone. SI units are dollars per m^3 at standard pressure.
          "cost_q_2": <Float64>,     # Linear coefficient on the cost curve for non-firm gas consumed in the zone. SI units are dollars per m^3 at standard pressure.
          "cost_q_3": <Float64>,     # Constant term on the cost curve for non-firm gas consumed in the zone. SI units are dollars per m^3 at standard pressure.
          "cost_p_1": <Float64>,     # Quadratic coefficient on the cost curve for pressure squared in the zone. SI units are dollars per Pascal^2.
          "cost_p_2": <Float64>,     # Linear coefficient on the cost curve for pressure squared in the zone. SI units are dollars per Pascal^2.
          "cost_p_3": <Float64>,     # Constant term on the cost curve for pressure squared in the zone. SI units are dollars per Pascal^2.
          "min_cost": <Float64>,     # Minimum cost per unit of non-firm gas consumed in the zone. SI units are dollars per m^3 at standard pressure.
          "constant_p": <Float64>,   # Bias factor for weighting pressure penalty cost relative to demand penalty cost.
           ...
        },
        "2": {
            ...
        },
        ...
    },
    "junction": {
        "1": {
          "price_zone": <Int64>        # Index of the corresponding price zone for the junction. -1 implies no zone.
          ...
        },
        "2": {
          ...
        },
        ...
    },
    ...
}
```

### Power Networks
```json
{
"gen":{
    "1":{
       "heat_rate_quad_coeff": <Float64>,      # Quadratic term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second   
       "heat_rate_linear_coeff": <Float64>,    # Linear term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second   
       "heat_rate_constant_coeff": <Float64>,  # Constant term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second
       ...
    },
    "2": {
      ...
    },
    ...
}
```
