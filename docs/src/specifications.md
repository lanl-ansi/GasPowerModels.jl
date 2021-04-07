# Problem Specifications
In these specifications, `_GM` refers to `GasModels`, `_PM` refers to `PowerModels`, and `_PMR` refers to `PowerModelsRestoration`.

## Gas-Power Flow (GPF)
### Inherited Variables and Constraints
```julia
# Gas-only variables and constraints
_GM.build_gf(_get_gasmodel_from_gaspowermodel(gpm))

# Power-only variables and constraints
_PM.build_pf(_get_powermodel_from_gaspowermodel(gpm))
```

### Constraints
```julia
# Gas-power related parts of the problem formulation.
for i in _get_interdependent_deliveries(gpm)
    constraint_heat_rate(gpm, i)
end
```

## Optimal Power Flow (OPF)
### Objective
```julia
# Objective minimizes operation cost.
objective_min_opf_cost(gpm)
```

### Inherited Variables and Constraints
```julia
# Gas-only variables and constraints.
_GM.build_gf(_get_gasmodel_from_gaspowermodel(gpm))

# Power-only variables and constraints.
_PM.build_pf(_get_powermodel_from_gaspowermodel(gpm))
```

### Variables
```julia
# Variables related to the OPF problem.
variable_zone_demand(gpm)
variable_zone_demand_price(gpm)
variable_zone_pressure(gpm)
variable_pressure_price(gpm)
```

### Constraints
```julia
# Gas-power related parts of the problem formulation.
for i in _get_interdependent_deliveries(gpm)
    constraint_heat_rate(gpm, i)
end

# Constraints related to price zones.
for (i, price_zone) in _IM.ref(gpm, _GM.gm_it_sym, :price_zone)
    constraint_zone_demand(gpm, i)
    constraint_zone_demand_price(gpm, i)
    constraint_zone_pressure(gpm, i)
    constraint_pressure_price(gpm, i)
end
```

## Network Expansion Planning (NE)
### Objective
```julia
# Objective minimizes cost of network expansion.
objective_min_ne_cost(gpm)
```

### Inherited Variables and Constraints
```julia
# Gas-only variables and constraints
_GM.build_nels(_get_gasmodel_from_gaspowermodel(gpm))

# Power-only variables and constraints
_PM.build_tnep(_get_powermodel_from_gaspowermodel(gpm))
```

### Constraints
```julia
# Gas-power related parts of the problem formulation.
for i in _get_interdependent_deliveries(gpm)
    constraint_heat_rate(gpm, i)
end
```

## Expansion Planning with Optimal Power Flow (NE OPF)
### Objective
```julia
# Objective minimizes network expansion, demand, and pressure cost.
objective_min_ne_opf_cost(gpm)
```

### Inherited Variables and Constraints
```julia
# Gas-only variables and constraints.
_GM.build_nels(_get_gasmodel_from_gaspowermodel(gpm))

# Power-only variables and constraints.
_PM.build_tnep(_get_powermodel_from_gaspowermodel(gpm))
```

### Variables
```julia
# Variables related to the NE OPF problem.
variable_zone_demand(gpm)
variable_zone_demand_price(gpm)
variable_zone_pressure(gpm)
variable_pressure_price(gpm)
```

### Constraints
```julia
# Gas-power related parts of the problem formulation.
for i in _get_interdependent_deliveries(gpm)
    constraint_heat_rate(gpm, i)
end

# Constraints related to price zones.
for (i, price_zone) in _IM.ref(gpm, _GM.gm_it_sym, :price_zone)
    constraint_zone_demand(gpm, i)
    constraint_zone_demand_price(gpm, i)
    constraint_zone_pressure(gpm, i)
    constraint_pressure_price(gpm, i)
end
```

## Maximum Load Delivery (MLD)
### Objective
```julia
# Objective maximizes the amount of load delivered.
objective_max_load(gpm)
```

### Inherited Variables and Constraints
```julia
# Gas-only variables and constraints.
_GM.build_ls(_get_gasmodel_from_gaspowermodel(gpm))

# Power-only variables and constraints (from PowerModelsRestoration).
_PMR.build_mld(_get_powermodel_from_gaspowermodel(gpm))
```

### Constraints
```julia
# Gas-power related parts of the problem formulation.
for i in _get_interdependent_deliveries(gpm)
    constraint_heat_rate_on_off(gpm, i)
end
```

## Maximum Load Delivery with Unit Commitment (MLD UC)
### Objective
```julia
# Objective maximizes the amount of load delivered.
objective_max_load(gpm)
```

### Inherited Variables and Constraints
```julia
# Gas-only variables and constraints.
_GM.build_ls(_get_gasmodel_from_gaspowermodel(gpm))

# Power-only variables and constraints (from PowerModelsRestoration).
_PMR.build_mld_uc(_get_powermodel_from_gaspowermodel(gpm))
```

### Constraints
```julia
# Gas-power related parts of the problem formulation.
for i in _get_interdependent_deliveries(gpm)
    constraint_heat_rate_on_off(gpm, i)
end
```