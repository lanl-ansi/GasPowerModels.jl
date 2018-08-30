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
### NEEDS CONVERSION FROM VOLUME TO FLUX   ############################
function constraint_zone_demand{G}(gm::GenericGasModel{G}, n::Int, i, loads)
    fl = gm.var[:nw][n][:fl]         
    zone_ql = gm.var[:nw][n][:zone_ql]     
      
    if !haskey(gm.con[:nw][n], :zone_demand)
        gm.con[:nw][n][:zone_demand] = Dict{Int,ConstraintRef}()
    end    
        
    gm.con[:nw][n][:zone_demand][i] = @constraint(gm.model, zone_ql[i] == sum(fl[j] for j in loads))
end

" constraints associated with bounding the demand zone prices 
 This is equation 22 in the HICCS paper"
function constraint_zone_demand_price{G}(gm::GenericGasModel{G}, n::Int, i, min_cost, cost_q)
    zone_ql = gm.var[:nw][n][:zone_ql] 
    zone_cost = gm.var[:nw][n][:zone_cost]         
      
    if !haskey(gm.con[:nw][n], :zone_demand_price)
        gm.con[:nw][n][:zone_demand_price1] = Dict{Int,ConstraintRef}()
        gm.con[:nw][n][:zone_demand_price2] = Dict{Int,ConstraintRef}()          
    end        
    
    gm.con[:nw][n][:zone_demand_price1][i] = @constraint(gm.model, zone_cost[i] >= cost_q[1] * zone_ql[i]^2 + cost_q[2] * zone_ql[i] + cost_q[3])      
    gm.con[:nw][n][:zone_demand_price2][i] = @constraint(gm.model, zone_cost[i] >= min_cost * zone_ql[i])                    
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













