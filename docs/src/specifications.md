# Problem Specifications
In these specifications, `pm` refers to a PowerModels model and `gm` refers to a GasModels model.

## Gas-Power Flow (GPF)
### Inherited Variables and Constraints
```julia
# Gas-only related variables and constraints
_GM.build_gf(gm)

# Power-only related variables and constraints
_PM.build_pf(pm)
```

### Constraints
```julia
# Gas-power related parts of the problem formulation.
for i in _GM.ids(gm, :delivery)
    constraint_heat_rate_curve(pm, gm, i)
end
```

## Optimal Gas Power Flow (OGPF)
### Objective
```julia
# This objective function minimizes operation cost.
objective_min_opf_cost(gm, pm)
```

### Inherited Variables and Constraints
```julia
# Gas-only related variables and constraints
_GM.build_gf(gm)

# Power-only related variables and constraints
_PM.build_pf(pm)
```

### Variables
```julia
# Variables related to the OGPF problem.
variable_zone_demand(gm)
variable_zone_demand_price(gm)
variable_zone_pressure(gm)
variable_pressure_price(gm)
```

### Constraints
```julia
# Gas-power related parts of the problem formulation.
for i in _GM.ids(gm, :delivery)
    constraint_heat_rate_curve(pm, gm, i)
end

# Constraints related to price zones.
for (i, price_zone) in _GM.ref(gm, :price_zone)
    constraint_zone_demand(gm, i)
    constraint_zone_demand_price(gm, i)
    constraint_zone_pressure(gm, i)
    constraint_pressure_price(gm, i)
end
```

## Network Expansion Planning (NE)
### Objective
```julia
# This objective function minimizes cost of network expansion.
objective_min_ne_cost(pm, gm)
```

### Inherited Variables and Constraints
```julia
# Gas-only-related variables and constraints.
_GM.build_nels(gm)

# Power-only-related variables and constraints.
_PM.build_tnep(pm)
```

### Constraints
```julia
# Gas-power related constraints of the problem formulation.
for i in _GM.ids(gm, :delivery)
   constraint_heat_rate_curve(pm, gm, i)
end
```

## Expansion Planning with Optimal Gas-Power Flow (NE OGPF)
### Objective
```julia
# Objective function minimizes network expansion, demand, and pressure cost.
objective_min_ne_opf_cost(pm, gm)
```

### Inherited Variables and Constraints
```julia
# Gas-only-related variables and constraints.
_GM.build_nels(gm)

# Power-only-related variables and constraints.
_PM.build_tnep(pm)
```

### Variables
```julia
# Variables related to the NE OGPF problem.
variable_zone_demand(gm)
variable_zone_demand_price(gm)
variable_zone_pressure(gm)
variable_pressure_price(gm)
```

### Constraints
```julia
# Constraints related to price zones.
for (i, price_zone) in _GM.ref(gm, :price_zone)
    constraint_zone_demand(gm, i)
    constraint_zone_demand_price(gm, i)
    constraint_zone_pressure(gm, i)
    constraint_pressure_price(gm, i)
end
```
