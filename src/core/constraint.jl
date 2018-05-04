################################################################################
# This file defines commonly used and created constraints for gas grid models
################################################################################

" Constraint for posting the heat rate curve 
  Assumption is mmBTU/h
  To get a daily rate multiply by 24
  To get back in real units, multiply by mvaBase
  To get CFD, divide by 1026 (1026 BTUs is a cubic feet)
  This is equation 21 in the HICCS paper"
function constraint_heat_rate_curve{T,P,G}(ggm::GenericGasGridModel{T}, pm::GenericPowerModel{P}, gm::GenericGasModel{G}, j_idx)
  
    # HACK HACK HACK
    junction = gm.ref[:nw][gm.cnw][:junction][j_idx]
            
    ql = 0
    if haskey(gm.ref[:nw][gm.cnw][:consumer], j_idx)    
        consumer = gm.ref[:nw][gm.cnw][:consumer][j_idx]       
        if consumer["qlmin"] != consumer["qlmax"]  
            ql = gm.var[:nw][gm.cnw][:ql][j_idx] 
        end
    end
    
    pg = pm.var[:nw][pm.cnw][:pg] #pg = pm.var[:pg] 
    generators = haskey(ggm.ref[:junction_generators], j_idx) ? ggm.ref[:junction_generators][j_idx] : []
    
    if !haskey(ggm.constraint, :heat_rate_curve)
        ggm.constraint[:heat_rate_curve] = Dict{Int,ConstraintRef}()
    end    
              
    if length(generators) == 0
        c = @constraint(ggm.model, ql == 0.0)
        ggm.constraint[:heat_rate_curve][j_idx] = c
    end     
     
    # convert from mmBTU/h in per unit to million CFD
    constant = ((24.0 * pm.data["baseMVA"]) / 1026.0)                      
    c = @constraint(ggm.model, ql == constant * sum( ggm.ref[:gen][i]["heat_rate"][1] == 0.0 ? 0 : ggm.ref[:gen][i]["heat_rate"][1]*pg[i]^2 for i in generators) + sum( ggm.ref[:gen][i]["heat_rate"][2]*pg[i] for i in generators) + sum( ggm.ref[:gen][i]["heat_rate"][3] for i in generators))

    ggm.constraint[:heat_rate_curve][j_idx] = c
end

" constraints associated with bounding the demand zone prices 
 This is equation 23 in the HICCS paper "
function constraint_zone_demand{T,G}(ggm::GenericGasGridModel{T}, gm::GenericGasModel{G}, price_zone)
    load_set = filter(i -> gm.ref[:nw][gm.cnw][:consumer][i]["qlmin"] != gm.ref[:nw][gm.cnw][:consumer][i]["qlmax"], collect(keys(gm.ref[:nw][gm.cnw][:consumer])))    
    i = price_zone["index"]
    ql = gm.var[:nw][gm.cnw][:ql]         
    zone_ql = ggm.var[:zone_ql]     
      
    if !haskey(ggm.constraint, :zone_demand)
        ggm.constraint[:zone_demand] = Dict{Int,ConstraintRef}()
    end    
        
    c1 = @constraint(ggm.model, zone_ql[i] == sum(ql[j] for j in intersect(ggm.ref[:price_zone][i]["junctions"],load_set)))
    ggm.constraint[:zone_demand][i] = c1
end

" constraints associated with bounding the demand zone prices 
 This is equation 22 in the HICCS paper"
function constraint_zone_demand_price{T,G}(ggm::GenericGasGridModel{T}, gm::GenericGasModel{G}, price_zone)
    i = price_zone["index"]
    zone_ql = ggm.var[:zone_ql] 
    zone_cost = ggm.var[:zone_cost]         
    c2 = @constraint(ggm.model, zone_cost[i] >= price_zone["cost_q"][1] * zone_ql[i]^2 + price_zone["cost_q"][2] * zone_ql[i] + price_zone["cost_q"][3])      
    c3 = @constraint(ggm.model, zone_cost[i] >= price_zone["min_cost"] * zone_ql[i])                
      
    if !haskey(ggm.constraint, :zone_demand_price)
        ggm.constraint[:zone_demand_price1] = Dict{Int,ConstraintRef}()
        ggm.constraint[:zone_demand_price2] = Dict{Int,ConstraintRef}()          
    end        
    ggm.constraint[:zone_demand_price1][i] = c2  
    ggm.constraint[:zone_demand_price2][i] = c3        
end

" constraints associated with bounding the maximum pressure in a zone 
 This is equation 24 in the HICCS paper "
function constraint_zone_pressure{T,G}(ggm::GenericGasGridModel{T}, gm::GenericGasModel{G}, price_zone)
    i = price_zone["index"]
    zone_p = ggm.var[:zone_p] 
    p = gm.var[:nw][gm.cnw][:p] 

    if !haskey(ggm.constraint, :zone_pressure)
        ggm.constraint[:zone_pressure] = Dict{Int,Dict{Int,ConstraintRef}}()
    end    
    ggm.constraint[:zone_pressure][i] = Dict{Int,ConstraintRef}() 
               
    for j in ggm.ref[:price_zone][i]["junctions"]  
        c = @constraint(ggm.model, zone_p[i] >= p[j])
        ggm.constraint[:zone_pressure][i][j] = c
    end
end

" constraints associated with pressure prices 
 This is equation 25 in the HICCS paper"
function constraint_pressure_price{T,G}(ggm::GenericGasGridModel{T}, gm::GenericGasModel{G}, price_zone)
    i = price_zone["index"]
    zone_p = ggm.var[:zone_p] 
    p_cost = ggm.var[:p_cost]          
      
    if !haskey(ggm.constraint, :pressure_price)
        ggm.constraint[:pressure_price] = Dict{Int,ConstraintRef}()
    end    
            
    c = @constraint(ggm.model, p_cost[i] >= price_zone["cost_p"][1] * zone_p[i]^2 + price_zone["cost_p"][2] * zone_p[i] + price_zone["cost_p"][3])      
    ggm.constraint[:pressure_price][i] = c  
end
