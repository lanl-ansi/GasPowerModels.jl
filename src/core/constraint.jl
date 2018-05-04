################################################################################
# This file defines commonly used and created constraints for gas grid models
################################################################################

" Constraint for posting the heat rate curve 
  Assumption is mmBTU/h
  To get a daily rate multiply by 24
  To get back in real units, multiply by mvaBase
  To get CFD, divide by 1026 (1026 BTUs is a cubic feet)
  This is equation 21 in the HICCS paper"
function constraint_heat_rate_curve{P,G}(pm::GenericPowerModel{P}, gm::GenericGasModel{G}, j, n::Int=gm.cnw)  
    consumer = gm.ref[:nw][n][:consumer][j]
            
    ql         = consumer["qlmin"] != consumer["qlmax"] ? gm.var[:nw][n][:ql][j] : 0    
    pg         = pm.var[:nw][n][:pg]  
    generators = consumer["gens"] 
    
    if !haskey(gm.con[:nw][n], :heat_rate_curve)
        gm.con[:nw][n][:heat_rate_curve] = Dict{Int,ConstraintRef}()
    end    
              
    if length(generators) == 0
        c = @constraint(pm.model, ql == 0.0)
        gm.con[:nw][n][:heat_rate_curve][j] = c
    end     
     
    # convert from mmBTU/h in per unit to million CFD
    constant = ((24.0 * pm.data["baseMVA"]) / 1026.0)                      
    c = @constraint(gm.model, ql == constant * sum( pm.ref[:nw][n][:gen][i]["heat_rate"][1] == 0.0 ? 0 : pm.ref[:nw][n][:gen][i]["heat_rate"][1]*pg[i]^2 for i in generators) + sum( pm.ref[:nw][n][:gen][i]["heat_rate"][2]*pg[i] for i in generators) + sum( pm.ref[:nw][n][:gen][i]["heat_rate"][3] for i in generators))

    gm.con[:nw][n][:heat_rate_curve][j] = c
end

" constraints associated with bounding the demand zone prices 
 This is equation 23 in the HICCS paper "
function constraint_zone_demand{G}(gm::GenericGasModel{G}, price_zone, n::Int=gm.cnw)
    load_set = filter(i -> gm.ref[:nw][n][:consumer][i]["qlmin"] != gm.ref[:nw][n][:consumer][i]["qlmax"], collect(keys(gm.ref[:nw][n][:consumer])))    
    i = price_zone["index"]
    ql = gm.var[:nw][n][:ql]         
    zone_ql = gm.var[:nw][n][:zone_ql]     
      
    if !haskey(gm.con[:nw][n], :zone_demand)
        gm.con[:nw][n][:zone_demand] = Dict{Int,ConstraintRef}()
    end    
        
    c1 = @constraint(gm.model, zone_ql[i] == sum(ql[j] for j in intersect(gm.ref[:nw][n][:price_zone][i]["junctions"],load_set)))
    gm.con[:nw][n][:zone_demand][i] = c1
end

" constraints associated with bounding the demand zone prices 
 This is equation 22 in the HICCS paper"
function constraint_zone_demand_price{G}(gm::GenericGasModel{G}, price_zone, n::Int=gm.cnw)
    i = price_zone["index"]
    zone_ql = gm.var[:nw][n][:zone_ql] 
    zone_cost = gm.var[:nw][n][:zone_cost]         
    c2 = @constraint(gm.model, zone_cost[i] >= price_zone["cost_q"][1] * zone_ql[i]^2 + price_zone["cost_q"][2] * zone_ql[i] + price_zone["cost_q"][3])      
    c3 = @constraint(gm.model, zone_cost[i] >= price_zone["min_cost"] * zone_ql[i])                
      
    if !haskey(gm.con[:nw][n], :zone_demand_price)
        gm.con[:nw][n][:zone_demand_price1] = Dict{Int,ConstraintRef}()
        gm.con[:nw][n][:zone_demand_price2] = Dict{Int,ConstraintRef}()          
    end        
    gm.con[:nw][n][:zone_demand_price1][i] = c2  
    gm.con[:nw][n][:zone_demand_price2][i] = c3        
end

" constraints associated with bounding the maximum pressure in a zone 
 This is equation 24 in the HICCS paper "
function constraint_zone_pressure{G}(gm::GenericGasModel{G}, price_zone, n::Int=gm.cnw)
    i = price_zone["index"]
    zone_p = gm.var[:nw][n][:zone_p] 
    p = gm.var[:nw][n][:p] 

    if !haskey(gm.con[:nw][n], :zone_pressure)
        gm.con[:nw][n][:zone_pressure] = Dict{Int,Dict{Int,ConstraintRef}}()
    end    
    gm.con[:nw][n][:zone_pressure][i] = Dict{Int,ConstraintRef}() 
               
    for j in gm.ref[:nw][n][:price_zone][i]["junctions"]  
        c = @constraint(gm.model, zone_p[i] >= p[j])
        gm.con[:nw][n][:zone_pressure][i][j] = c
    end
end

" constraints associated with pressure prices 
 This is equation 25 in the HICCS paper"
function constraint_pressure_price{G}(gm::GenericGasModel{G}, price_zone, n::Int=gm.cnw)
    i = price_zone["index"]
    zone_p = gm.var[:nw][n][:zone_p] 
    p_cost = gm.var[:nw][n][:p_cost]          
      
    if !haskey(gm.con[:nw][n], :pressure_price)
        gm.con[:nw][n][:pressure_price] = Dict{Int,ConstraintRef}()
    end    
            
    c = @constraint(gm.model, p_cost[i] >= price_zone["cost_p"][1] * zone_p[i]^2 + price_zone["cost_p"][2] * zone_p[i] + price_zone["cost_p"][3])      
    gm.con[:nw][n][:pressure_price][i] = c  
end
