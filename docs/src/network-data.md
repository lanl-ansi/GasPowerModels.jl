# GasPowerModels Network Data Format

## The Network Data Dictionary

Internally GasPowerModels utilizes a dictionary to store network data for power systems (see PowerModels) and gas models (see GasModels.jl). The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange. The I/O for GasPowerModels utilizes the serializations available in PowerModels.jl and GasModels.jl to construct the two network models. All data is assumed to be in per_unit (non dimenisionalized) or SI units.

Besides the standard network data supported by GasModels.jl and PowerModels.jl, there are a few extra fields that are required to couple the two systems together. These are discussed as follows:


### Gas Networks

```json
{
"energy_factor": <float>,          # factor for converting the Joules per second used by a generator to m^3 per second gas consumption. SI units are m^3 per Joules
"price_zone":{
    "1":{
      "junctions": <array>,   # array of junction ids for a natural gas price zone
      "cost_q": <array>,      # array of floats that model a quadractic cost curve on non-firm gas consumed in the zone. SI units are dollars per m^3 at standard pressure
      "cost_p": <array>,      # array of floats that model a quadractic cost curve on pressure squared in the zone. SI units are dollars per pascals^2
      "min_cost" <float>,     # minimum cost per unit of non-firm gas consumed in the zone.  SI units are dollars per m^3 at standard pressure
      "constant_p" <float>,   # bias factor for weighting pressure penalty cost relative to demand penalty cost      
       ...
    },
    "2":{...},
    ...
}
}
```

### Power Networks

```json
{
"gen":{
    "1":{
       "heat_rate_quad_coeff":   <float>,  # quadratic term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second   
       "heat_rate_linear_coeff": <float>,  # linear term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second   
       "heat_rate_constant_coeff": <float>,  # constant term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second
       ...
    },
    "2":{...},
    ...
}
}
```




