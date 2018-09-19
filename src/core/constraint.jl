################################################################################
# This file defines commonly used and created constraints for gas grid models
################################################################################

#### Constraints without Templates #######

" constraints associated with bounding the maximum pressure in a zone 
 This is equation 24 in the HICCS paper "
function constraint_zone_pressure{G}(gm::GenericGasModel{G}, n::Int, i)
    price_zone = gm.ref[:nw][n][:price_zone][i]
    zone_p = gm.var[:nw][n][:zone_p] 
    p = gm.var[:nw][n][:p] 

    if !haskey(gm.con[:nw][n], :zone_pressure)
        gm.con[:nw][n][:zone_pressure] = Dict{Int,Dict{Int,ConstraintRef}}()
    end    
    gm.con[:nw][n][:zone_pressure][i] = Dict{Int,ConstraintRef}() 
               
    for j in gm.ref[:nw][n][:price_zone][i]["junctions"]  
        gm.con[:nw][n][:zone_pressure][i][j] = @constraint(gm.model, zone_p[i] >= p[j])
    end
end
constraint_zone_pressure(gm::GenericGasModel, i::Int) = constraint_zone_pressure(gm, gm.cnw, i)

#### Constraints with Templates #####
function constraint_zone_demand{G}(gm::GenericGasModel{G}, n::Int, i, loads)
    fl = gm.var[:nw][n][:fl]         
    zone_fl = gm.var[:nw][n][:zone_fl]     
      
    if !haskey(gm.con[:nw][n], :zone_demand)
        gm.con[:nw][n][:zone_demand] = Dict{Int,ConstraintRef}()
    end    
        
    gm.con[:nw][n][:zone_demand][i] = @constraint(gm.model, zone_fl[i] == sum(fl[j] for j in loads))    
end

" constraints associated with bounding the demand zone prices 
 This is equation 22 in the HICCS paper"
function constraint_zone_demand_price{G}(gm::GenericGasModel{G}, n::Int, i, min_cost, cost_q, standard_density)
    zone_fl = gm.var[:nw][n][:zone_fl] 
    zone_cost = gm.var[:nw][n][:zone_cost]         
      
    if !haskey(gm.con[:nw][n], :zone_demand_price)
        gm.con[:nw][n][:zone_demand_price1] = Dict{Int,ConstraintRef}()
        gm.con[:nw][n][:zone_demand_price2] = Dict{Int,ConstraintRef}()          
    end        
    
    " the cost is in terms of m^3 at standard density.  We have consumption in terms of m^3 per second.  We convert this to a daily cost 1 day = 86400 seconds"
    gm.con[:nw][n][:zone_demand_price1][i] = @constraint(gm.model, zone_cost[i] >= 86400^2 * cost_q[1] * (zone_fl[i] / standard_density)^2 + 86400 * cost_q[2] * zone_fl[i] / standard_density + cost_q[3])      
    gm.con[:nw][n][:zone_demand_price2][i] = @constraint(gm.model, zone_cost[i] >= 86400 * min_cost * zone_fl[i] / standard_density)
      
    println(i, " ", gm.con[:nw][n][:zone_demand_price1][i])
    println(i, " ", gm.con[:nw][n][:zone_demand_price2][i])           
                 
end

" constraints associated with pressure prices 
 This is equation 25 in the HICCS paper"
function constraint_pressure_price{G}(gm::GenericGasModel{G}, n::Int, i, cost_p)
    zone_p = gm.var[:nw][n][:zone_p] 
    p_cost = gm.var[:nw][n][:p_cost]          
      
    if !haskey(gm.con[:nw][n], :pressure_price)
        gm.con[:nw][n][:pressure_price] = Dict{Int,ConstraintRef}()
    end                
    gm.con[:nw][n][:pressure_price][i] = @constraint(gm.model, p_cost[i] >= cost_p[1] * zone_p[i]^2 + cost_p[2] * zone_p[i] + cost_p[3])      
end   













