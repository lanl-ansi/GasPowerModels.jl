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

## Price Zone Data formats

Todo
