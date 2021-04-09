# File IO
Parsing uses the native parsing features of GasModels.jl and PowerModels.jl with extra features to parse information used for coupling infrastructures together.

```@meta
CurrentModule = GasPowerModels
```

## Coupling Data Formats
The GasPowerModels parsing implementation relies on data formats that support extensions to accommodate arbitrary extra data fields such as those required to define couplings between infrastructures.
Thus, GasPowerModels largely relies on parsing of MATPOWER and MATGAS files to incorporate some data fields.
In addition, the coupling between gas generators and delivery points is accomplished via a tertiary JSON linking file of the following form:

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

## Price Zone Data Formats
Many of the problem formulations supported by `GasPowerModels` rely on defining collections of junctions as zones. 
These are used to model things like pricing regions.
To support these features, `GasPowerModels` uses the parsing extensions of the MATGAS format.
A pricing zone is defined with
```%% price_zone data
%column_names% id  cost_q_1  cost_q_2  cost_q_3  cost_p_1  cost_p_2  cost_p_3  min_cost  constant_p  comment
mgc.price_zone = [
...
];
```
where the first column is used to uniquely identify the price zone, the `cost_q` columns are used to define the constants of the quadratic equation used to determine the price of gas in the zone based on the amount of gas consumed in the zone (square, linear, and constant), the `cost_p` columns are used to defined the constants of the quadratic equation used to determine the pressure penalty in the zone based on the maximum pressure in the zone (square, linear, and constant), `min_cost` is a minimum price for gas in the zone, `constant_p` is a weighting term to weight the pressure penalty relative to the price of gas, and `comment` is a string field for information about the pricing zone (such as its name).
Junctions are then linked to the pricing zone with a table of the form
```%% junction data (extended)
%column_names% price_zone
mgc.junction_data = [
...
];
```
where each row is used to provide the `id` of the price zone of the junction (in the same order as the junction table).
The value `-1` is used to denote that the junction is not part of a pricing zone.
