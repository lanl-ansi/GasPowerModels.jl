# Developer Documentation

The data format allows the user to specify a `GasModel` and a `PowerModel` and the connections between these systems. At the moment, data about connections between the two infrastructure systems is stored in the `GasModel` or the `PowerModel.`

## Data Processing functions

`GasPowerModels` relies on the automated data processing of `GasModels` and `PowerModels` which includes capabilities to propagate status, non dimensionalize, correct topology errors, etc.
However, these capabilities assume no external dependencies, such as those induced by `GasPowerModels`. Thus, it is recommended that these capabilities be invoked explictly so that external dependencies are accounted for.  For example,

```julia
g_data, p_data = _GM.parse_file(g_file, skip_correct=true), _PM.parse_file(p_file, validate=false)

# Ensure the two datasets use the same units for power.
g_per_unit = get(g_data,"is_per_unit",false)
p_per_unit = get(p_data,"per_unit",false)

# Ensure the two datasets use the same units
_GM.correct_network_data!(g_data)
_PM.correct_network_data!(p_data)

if g_per_unit == false
    resolve_gm_units!(g_data)
end

if p_per_unit == false
    resolve_pm_units!(p_data)
end
```

ensures the per unit status of the source files is preserved so that `GasPowerModels` can determine if coupling information requires non dimensionalizing.

## Compositional Problems

A best practice to adopt a composition approach to building problems in `GasPowerModels`, leveraging problem definitions of `PowerModels` and `GasModels`.  This will help lessen the impact of breaking changes.  For example, the joint network expansion planning problem invokes the network expansion planning problems of `GasModels` and `PowerModels` directly with code like

```julia
_GM.build_nels(gm)

# Power-only-related variables and constraints.
_PM.build_tnep(pm)

# Gas-power related parts of the problem formulation.
for i in _GM.ids(gm, :delivery)
   constraint_heat_rate_curve(pm, gm, i)
end

# This objective function minimizes cost of network expansion.
objective_min_ne_cost(pm, gm)
```

with the only new code contributed being that which models coupling between power and natural gas.
