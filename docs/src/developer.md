# Developer Documentation

The GasPowerModels data format allows the user to specify gas network data, power network data, and data related to the interdependencies between gas and power systems.

## Data Processing functions

`GasPowerModels` relies on the automated data processing routines of `GasModels` and `PowerModels`, which include capabilities for status propagation, nondimensionalization, topology correction, etc.
However, these capabilities are typically used on individual infrastructure data, whereas `GasPowerModels` must join these data.
Thus, in preprocessing routines, it is recommended that capabilities be invoked explictly so that external dependencies are accounted for.
For example, the core data parsing function `parse_files` performs the following operations:

```julia
function parse_files(gas_path::String, power_path::String, link_path::String)
    joint_network_data = parse_link_file(link_path)
    _IM.update_data!(joint_network_data, parse_gas_file(gas_path))
    _IM.update_data!(joint_network_data, parse_power_file(power_path))

    # Store whether or not each network uses per-unit data.
    g_per_unit = get(joint_network_data["it"][_GM.gm_it_name], "is_per_unit", 0) != 0
    p_per_unit = get(joint_network_data["it"][_PM.pm_it_name], "per_unit", false)

    # Correct the network data.
    correct_network_data!(joint_network_data)

    # Ensure all datasets use the same units for power.
    resolve_units!(joint_network_data, g_per_unit, p_per_unit)

    # Return the network dictionary.
    return joint_network_data
end
```

Here, the `parse_gas_file` and `parse_power_file` routines skip their respective data correction steps, i.e.,

```julia
function parse_gas_file(file_path::String; skip_correct::Bool = true)
    data = _GM.parse_file(file_path; skip_correct = skip_correct)
    ...
end

function parse_power_file(file_path::String; skip_correct::Bool = true)
    data = _PM.parse_file(file_path; validate = !skip_correct)
    ...
end
```

This ensures the per-unit statuses within source files are preserved so that `GasPowerModels` can determine if coupling information requires nondimensionalization.
After these routines are called, `correct_network_data!` executes various data and topology correction routines on gas, power, and linking data.
Then, `resolve_units` ensures that linking data is correctly dimensionalized with respect to the initial gas and power dimensionalizations.


## Compositional Problems

A best practice is to adopt a composition approach for building problems in `GasPowerModels`, leveraging problem definitions of `PowerModels` and `GasModels`.
This helps lessen the impact of breaking changes across packages.
For example, the joint network expansion planning problem invokes the network expansion planning problems of `GasModels` and `PowerModels` directly with routines like

```julia
# Gas-only variables and constraints
_GM.build_nels(_get_gasmodel_from_gaspowermodel(gpm))

# Power-only variables and constraints
_PM.build_tnep(_get_powermodel_from_gaspowermodel(gpm))

# Gas-power related parts of the problem formulation.
for i in _get_interdependent_deliveries(gpm)
    constraint_heat_rate(gpm, i)
end

# Objective minimizes cost of network expansion.
objective_min_ne_cost(gpm)
```

Compared to the `GasModels` (`_GM`) and `PowerModels` (`_PM`) routines, the `GasPowerModels` routines only specify interdependency constraints and the joint objective.