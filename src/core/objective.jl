################################################################################
# This file is to defines commonly used constraints for gas grid models
################################################################################

" function for congestion costs based on demand "
# This is equation 27 in the HICCS paper
function objective_min_ne_opf_cost{T, P, G}(ggm::GenericGasGridModel{T}, pm::GenericPowerModel{P},gm::GenericGasModel{G}; normalization = 100000.0, gas_ne_weight = 1.0, power_ne_weight = 1.0, power_opf_weight = 1.0, gas_price_weight = 1.0)
    zp = gm.var[:nw][gm.cnw][:zp] 
    zc = gm.var[:nw][gm.cnw][:zc] 
    
    line_ne = pm.var[:nw][pm.cnw][:branch_ne] 
    branches = pm.ref[:nw][pm.cnw][:ne_branch] 
    
    pg = pm.var[:nw][pm.cnw][:pg]  

    # constraint for normalized zone-based demand pricing
    variable_zone_demand(ggm, gm)  
    zone_cost = variable_zone_demand_price(ggm)
    variable_zone_pressure(ggm, gm)
    p_cost = variable_pressure_price(ggm, gm)  

    for (i, price_zone) in ggm.ref[:price_zone]
        constraint_zone_demand(ggm, gm, price_zone)        
        constraint_zone_demand_price(ggm, gm, price_zone)
        constraint_zone_pressure(ggm, gm, price_zone)
        constraint_pressure_price(ggm, gm, price_zone)        
    end      
    
    obj = @objective(ggm.model, Min, 
      gas_ne_weight    * sum(gm.ref[:nw][gm.cnw][:ne_connection][i]["construction_cost"] * zp[i] for i in keys(gm.ref[:nw][gm.cnw][:ne_pipe])) +
      gas_ne_weight    * sum(gm.ref[:nw][gm.cnw][:ne_connection][i]["construction_cost"] * zc[i] for i in keys(gm.ref[:nw][gm.cnw][:ne_compressor])) +
      power_ne_weight  * sum( branches[i]["construction_cost"]*line_ne[i] for (i,branch) in branches) +
      power_opf_weight * sum(gen["cost"][1]*pg[i]^2 + gen["cost"][2]*pg[i] + gen["cost"][3] for (i,gen) in pm.ref[:nw][pm.cnw][:gen]) + 
      gas_price_weight * sum(zone_cost[i] for i in keys(ggm.ref[:price_zone])) +
      gas_price_weight * sum(ggm.ref[:price_zone][i]["constant_p"] * p_cost[i] for i in keys(ggm.ref[:price_zone]))  
    )            
            
    return obj
end

" function for congestion costs based on expansion costs only "
# This is the objective function for the expansion only results in the HICCS paper
function objective_min_ne_cost{T, P, G}(ggm::GenericGasGridModel{T}, pm::GenericPowerModel{P},gm::GenericGasModel{G}; gas_ne_weight = 1.0, power_ne_weight = 1.0, normalization = 1.0)
    zp = gm.var[:nw][gm.cnw][:zp] 
    zc = gm.var[:nw][gm.cnw][:zc] 
    
    line_ne = pm.var[:nw][pm.cnw][:branch_ne]  
    branches = pm.ref[:nw][pm.cnw][:ne_branch] 
          
    obj = @objective(ggm.model, Min, 
      gas_ne_weight      * normalization * sum(gm.ref[:nw][gm.cnw][:ne_connection][i]["construction_cost"] * zp[i] for i in keys(gm.ref[:nw][gm.cnw][:ne_pipe])) 
      + gas_ne_weight    * normalization * sum(gm.ref[:nw][gm.cnw][:ne_connection][i]["construction_cost"] * zc[i] for i in keys(gm.ref[:nw][gm.cnw][:ne_compressor]))
      + power_ne_weight  * normalization * sum( branches[i]["construction_cost"]*line_ne[i] for (i,branch) in branches)
    )  
    
end


