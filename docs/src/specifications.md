# Problem Specifications

In these specifications, pm refers to a power system model and gm refers to a gas system model

## Coupled Gas Power Flow (GPF)



### Variables
```julia
PowerModels.variable_voltage(pm)
PowerModels.variable_generation(pm)
PowerModels.variable_branch_flow(pm)
PowerModels.variable_dcline_flow(pm)

GasModels.variable_flow(gm)  
GasModels.variable_pressure_sqr(gm)
GasModels.variable_valve_operation(gm)
GasModels.variable_load_mass_flow(gm)
GasModels.variable_production_mass_flow(gm)
```

### Constraints
```julia
PowerModels.constraint_model_voltage(pm)

for i in PowerModels.ids(pm, :ref_buses)
    PowerModels.constraint_theta_ref(pm, i)
    PowerModels.constraint_voltage_magnitude_setpoint(pm, i)
end

for i in PowerModels.ids(pm, :bus)
    PowerModels.constraint_power_balance_shunt(pm, i)
    if length(ref(pm, :bus_gens, i)) > 0 && !(i in ids(pm,:ref_buses))
        PowerModels.constraint_voltage_magnitude_setpoint(pm, i)
        for j in ref(pm, :bus_gens, i)
            PowerModels.constraint_active_gen_setpoint(pm, j)
        end
    end
end

for i in PowerModels.ids(pm, :branch)
    PowerModels.constraint_ohms_yt_from(pm, i)
    PowerModels.constraint_ohms_yt_to(pm, i)
end

for i in PowerModels.ids(pm, :dcline)
    PowerModels.constraint_active_dcline_setpoint(pm, i)

    f_bus = PowerModels.ref(pm, :bus)[dcline["f_bus"]]
    if f_bus["bus_type"] == 1
        PowerModels.constraint_voltage_magnitude_setpoint(pm, f_bus["index"])
    end

    t_bus = PowerModels.ref(pm, :bus)[dcline["t_bus"]]
    if t_bus["bus_type"] == 1
        PowerModels.constraint_voltage_magnitude_setpoint(pm, t_bus["index"])
    end
end

for i in [collect(GasModels.ids(gm,:pipe)); collect(GasModels.ids(gm,:resistor))] 
    GasModels.constraint_pipe_flow(gm, i) 
end
    
for i in GasModels.ids(gm, :junction)
    GasModels.constraint_junction_mass_flow_ls(gm, i)      
end
    
for i in GasModels.ids(gm, :short_pipe)
    GasModels.constraint_short_pipe_flow(gm, i) 
end
        
for i in GasModels.ids(gm, :compressor) 
    GasModels.constraint_compressor_flow(gm, i) 
end
    
for i in GasModels.ids(gm, :valve)     
    GasModels.constraint_valve_flow(gm, i) 
end
    
for i in GasModels.ids(gm, :control_valve) 
    GasModels.constraint_control_valve_flow(gm, i) 
end

for i in GasModels.ids(gm, :consumer)
    constraint_heat_rate_curve(pm, gm, i)
end
```

## Expansion Planning (NE)

### Objective
```julia
objective_min_ne_cost(pm, gm)
```

### Variables
```julia
PowerModels.variable_branch_ne(pm)
PowerModels.variable_voltage(pm)
PowerModels.variable_voltage_ne(pm)
PowerModels.variable_generation(pm)     
PowerModels.variable_branch_flow(pm)    
PowerModels.variable_dcline_flow(pm)    
PowerModels.variable_branch_flow_ne(pm) 
PowerModels.constraint_model_voltage(pm)
PowerModels.constraint_model_voltage_ne(pm)

GasModels.variable_flow(gm)          
GasModels.variable_pressure_sqr(gm)
GasModels.variable_valve_operation(gm)
GasModels.variable_load_mass_flow(gm)  
GasModels.variable_production_mass_flow(gm)
GasModels.variable_pipe_ne(gm)
GasModels.variable_compressor_ne(gm)
GasModels.variable_flow_ne(gm)
```

### Constraints
```julia
PowerModels.constraint_model_voltage(pm)      
PowerModels.constraint_model_voltage_ne(pm)   

for i in ids(pm, :ref_buses)
    PowerModels.constraint_theta_ref(pm, i)  
end

for i in ids(pm, :bus)
    PowerModels.constraint_power_balance_shunt_ne(pm, i) 
end

for i in ids(pm, :branch)
    PowerModels.constraint_ohms_yt_from(pm, i)
    PowerModels.constraint_ohms_yt_to(pm, i)  
    PowerModels.constraint_voltage_angle_difference(pm, i)
    PowerModels.constraint_thermal_limit_from(pm, i)
    PowerModels.constraint_thermal_limit_to(pm, i)  
end

for i in ids(pm, :ne_branch)
    PowerModels.constraint_ohms_yt_from_ne(pm, i)             
    PowerModels.constraint_ohms_yt_to_ne(pm, i)               
    PowerModels.constraint_voltage_angle_difference_ne(pm, i) 
    PowerModels.constraint_thermal_limit_from_ne(pm, i)       
    PowerModels.constraint_thermal_limit_to_ne(pm, i)         
end

for i in GasModels.ids(gm, :junction)
    GasModels.constraint_junction_mass_flow_ne_ls(gm, i) 
end

for i in [collect(GasModels.ids(gm,:pipe)); collect(GasModels.ids(gm,:resistor))] 
    GasModels.constraint_pipe_flow_ne(gm, i)
end

for i in GasModels.ids(gm,:ne_pipe) 
    GasModels.constraint_new_pipe_flow_ne(gm, i)
end
    
for i in GasModels.ids(gm, :short_pipe) 
    GasModels.constraint_short_pipe_flow_ne(gm, i)
end
    
for i in GasModels.ids(gm,:compressor)       
    GasModels.constraint_compressor_flow_ne(gm, i)
end
 
for i in GasModels.ids(gm, :ne_compressor) 
    GasModels.constraint_new_compressor_flow_ne(gm, i)
end  
          
for i in GasModels.ids(gm, :valve)     
    GasModels.constraint_valve_flow(gm, i)
end
    
for i in GasModels.ids(gm, :control_valve) 
    GasModels.constraint_control_valve_flow(gm, i)       
end

for i in GasModels.ids(gm, :consumer)
    constraint_heat_rate_curve(pm, gm, i)
end    

```

## Expansion Planning with Optimal Power Flow (NEOPF)

### Objective
```julia
objective_min_ne_opf_cost
```

### Variables

NE Model variables and

```julia
variable_zone_demand(gm)
variable_zone_demand_price(gm)
variable_zone_pressure(gm)
variable_pressure_price(gm)
```

### Constraints

NE Model constraints and 

```julia
for (i, price_zone) in gm.ref[:nw][n][:price_zone]
    constraint_zone_demand(gm, i)
    constraint_zone_demand_price(gm, i)
    constraint_zone_pressure(gm, i)
    constraint_pressure_price(gm, i)
end
```
