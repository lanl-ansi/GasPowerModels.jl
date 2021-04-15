# GasPowerModels Network Data Format

## The Network Data Dictionary
Internally, GasPowerModels uses a dictionary to store network data for both power systems (see PowerModels.jl) and gas systems (see GasModels.jl).
The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange.
The I/O for GasPowerModels utilizes the serializations available in PowerModels.jl and GasModels.jl to construct the joint network model.
All data are assumed to be in per unit (non-dimenisionalized) or SI units.
Gas, power, and interdependency data are each stored in the `data["it"]["gm"]`, `data["it"]["pm"]`, and `data["it"]["dep"]` subdictionaries of `data`, respectively.

Besides the standard network data supported by GasModels.jl and PowerModels.jl, there are a few extra fields that are required to couple the two systems together.
These are discussed as follows:

### Gas Networks
```json
{
  "it": {
      "gm": {
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
  }
}
```

### Interdependency Information
```json
{
  "it": {
      "dep": {
          "delivery_gen": {
              "1": {
                  "delivery": {
                      "id": <String> # Index of the gas delivery corresponding to the interdependency.
                  },
                  "gen": {
                      "id": <String> # Index of the power generator to be fueled by the above delivery.
                  },
                  "heat_rate_curve_coefficients": <Array{Float64}>,
                  # First number is a quadratic term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second.
                  # Second number is a linear term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second.
                  # Third number is a constant term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second.
                  "status": <Int64> # Indicator (0 or 1) specifying whether or not this interdependency component is active.
              },
              "2": {
                ...
              },
              ...
          }
      }
  }
}
```

Further, the global parameters, `gas_ne_weight`, `power_ne_weight`, `power_opf_weight`, `gas_price_weight`, `gm_load_priority`, and `pm_load_priority` may be included at the top level of the data dictionary (i.e., above `data["it"]` as top-level entries of `data`) to weight the objective terms associated with expansion of gas components, expansion of power components, the generation cost, the cost of gas zones, nongeneration gas delivery load prioritization, and active power delivery load prioritization, respectively.
