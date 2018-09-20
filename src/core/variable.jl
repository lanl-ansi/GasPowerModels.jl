################################################################################
# This file defines common variables used in power flow models
# This will hopefully make everything more compositional
################################################################################

" extracts the start value "
function getstart(set, item_key, value_key, default = 0.0)
    return get(get(set, item_key, Dict()), value_key, default)      
end

" function for creating variables associated with zonal demand "
function variable_zone_demand{G}(gm::GenericGasModel{G}, n::Int=gm.cnw)
    consumers = gm.ref[:nw][n][:consumer]
    
    flmax =  Dict{Any,Any}()  
    for (i, price_zone) in gm.ref[:nw][n][:price_zone]
        flmax[i] = 0
        for j in gm.ref[:nw][n][:price_zone][i]["junctions"]
            consumers = filter( (k, consumer) -> consumer["ql_junc"] == j, gm.ref[:nw][n][:consumer])
            flmax[i] = flmax[i] + sum(GasModels.calc_flmax(gm.data, consumer) for (k, consumer) in consumers)
        end
    end
                 
    gm.var[:nw][n][:zone_fl] = @variable(gm.model, [i in keys(gm.ref[:nw][n][:price_zone])], basename="zone_fl", lowerbound=0.0, upperbound=flmax[i])             
end

" function for creating variables associated with zonal demand "
function variable_zone_demand_price{G}(gm::GenericGasModel{G}, n::Int=gm.cnw)
    gm.var[:nw][n][:zone_cost] = @variable(gm.model, [i in keys(gm.ref[:nw][n][:price_zone])], basename="zone_cost", lowerbound=0.0, upperbound=Inf)      
end

" function for creating variables associated with zonal demand "
function variable_zone_pressure{G}(gm::GenericGasModel{G}, n::Int=gm.cnw)
    junctions = gm.ref[:nw][n][:junction]  
      
    pmin =  Dict{Any,Any}()
    pmax =  Dict{Any,Any}()  
    for (i, price_zone) in gm.ref[:nw][n][:price_zone]
        pmin[i] = minimum(junctions[j]["pmin"] for j in gm.ref[:nw][n][:price_zone][i]["junctions"])^2
        pmax[i] = maximum(junctions[j]["pmax"] for j in gm.ref[:nw][n][:price_zone][i]["junctions"])^2
    end
       
    # variable for normalized zone-based demand pricing  
    gm.var[:nw][n][:zone_p] = @variable(gm.model, [i in keys(gm.ref[:nw][n][:price_zone])], basename="zone_p", lowerbound=pmin[i], upperbound=pmax[i])   
end

" function for creating variables associated with zonal pressure cost "
function variable_pressure_price{G}(gm::GenericGasModel{G}, n::Int=gm.cnw)
    junctions = gm.ref[:nw][n][:junction] 
    baseP     = gm.data["baseP"]
      
    pmin =  Dict{Any,Any}()
    pmax =  Dict{Any,Any}()  
    cmin =  Dict{Any,Any}() 
    cmax =  Dict{Any,Any}() 
    for (i, price_zone) in gm.ref[:nw][n][:price_zone]
        pmin[i] = minimum(junctions[j]["pmin"] for j in gm.ref[:nw][n][:price_zone][i]["junctions"])^2
        pmax[i] = maximum(junctions[j]["pmax"] for j in gm.ref[:nw][n][:price_zone][i]["junctions"])^2

        cmin[i] = gm.ref[:nw][n][:price_zone][i]["cost_p"][1] * pmin[i]^2 + gm.ref[:nw][n][:price_zone][i]["cost_p"][2] * pmin[i] + gm.ref[:nw][n][:price_zone][i]["cost_p"][3]
        cmax[i] = gm.ref[:nw][n][:price_zone][i]["cost_p"][1] * pmax[i]^2 + gm.ref[:nw][n][:price_zone][i]["cost_p"][2] * pmax[i] + gm.ref[:nw][n][:price_zone][i]["cost_p"][3]                              
    end
       
    gm.var[:nw][n][:p_cost] = @variable(gm.model, [i in keys(gm.ref[:nw][n][:price_zone])], basename="p_cost", lowerbound=max(0,cmin[i]), upperbound=cmax[i])    
end