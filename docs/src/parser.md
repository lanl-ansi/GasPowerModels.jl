# File IO

Parsing uses the native parsing features of GasModels.jl and PowerModels.jl with extra features to parse information used for coupling infrastructures together.


```@meta
CurrentModule = GasPowerModels
```

## Coupling Data Formats

The GasPowerModels parsing implementation relies on data formats that support extensions to accommodate arbitrary extra data fields such as those required to define couplings between
infrastructures. Thus, ``GasPowerModels`` largely relies on parsing of Matpower and Matgas files to incorporate extra data fields. Specifically, the coupling between gas generators and delivery points is accomplished by adding a ``gen_gas`` table to a Matpower file of the following form


```%% gas network linking data
%column_names%  delivery  heat_rate_quad_coeff   heat_rate_linear_coeff   heat_rate_constant_coeff
mpc.gen_gas = [
...
]
```

Here, the prefix ``gen`` tells the Matpower parser that this table of information should be added to electric power generators.  The rows of this table should appear in the same
order as the primary ``gen`` table of the Matpower file.  The delivery column is used to store the identifier of the natural gas delivery that is tied to this generator (-1 is reserved for no delivery linkage). The next three columns are used to define the coefficients of the quadratic heat rate curve (square, linear, and constant, respectively)

## Price Zone Data Formats

Many of the problem formulations support by ``GasPowerModels`` rely on defining collections of junctions as zones.  These are used to model things like pricing regions. To support these features, ``GasPowerModels`` uses the parising extensions of the Matgas format.  A pricing zone is defined with

```%% price_zone data
%column_names% id  cost_q_1  cost_q_2  cost_q_3  cost_p_1  cost_p_2  cost_p_3  min_cost  constant_p  comment
mgc.price_zone = [
...
];
```

where the first column is used to uniquely identify the price zone, the cost_q columns are used to define the constants of the quadratic equation used to determine the price of gas in the zone based on the amount of gas consumed in the zone (square, linear, and constant), the cost_p columns are used to defined the constants of the quadratic equation used to determine the pressure penalty in the zone based on the maximum pressure in the zone (square, linear, and constant), min_cost is a minimum price for gas in the zone, constant_p is a weighting term to weight the pressure penalty relative to the price of gas, and comment is a string field for information about the pricing zone (such as its name). Junctions are then linked to the pricing zone with a
table of the form

```%% junction data (extended)
%column_names% price_zone
mgc.junction_data = [
...
];
```

where each row is used to provide the id of the price zone of the junction (in the same order as the junction table). The value -1 is used to denote that the junction is not part of a pricing zone.
