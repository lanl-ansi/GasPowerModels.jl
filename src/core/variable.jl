################################################################################
# This file defines common variables used in power flow models
# This will hopefully make everything more compositional
################################################################################

" extracts the start value "
function getstart(set, item_key, value_key, default = 0.0)
    return get(get(set, item_key, Dict()), value_key, default)      
end

" function for creating variables associated with zonal demand "
function variable_zone_demand{T,G}(ggm::GenericGasGridModel{T}, gm::GenericGasModel{G})
    consumers = gm.ref[:nw][gm.cnw][:consumer]    
    ggm.var[:zone_ql] = @variable(ggm.model, [i in keys(ggm.ref[:price_zone])], basename="zone_ql", lowerbound=0.0, upperbound=sum(consumers[j]["qlmax"] for j in ggm.ref[:price_zone][i]["junctions"]))             
end

" function for creating variables associated with zonal demand "
function variable_zone_demand_price{T}(ggm::GenericGasGridModel{T})
    ggm.var[:zone_cost] = @variable(ggm.model, [i in keys(ggm.ref[:price_zone])], basename="zone_cost", lowerbound=0.0, upperbound=Inf)      
end

" function for creating variables associated with zonal demand "
function variable_zone_pressure{T,G}(ggm::GenericGasGridModel{T}, gm::GenericGasModel{G})
    junctions = gm.ref[:nw][gm.cnw][:junction]  
      
    pmin =  Dict{Any,Any}()
    pmax =  Dict{Any,Any}()  
    for (i, price_zone) in ggm.ref[:price_zone]
        pmin[i] = minimum(junctions[j]["pmin"] for j in ggm.ref[:price_zone][i]["junctions"])^2
        pmax[i] = maximum(junctions[j]["pmax"] for j in ggm.ref[:price_zone][i]["junctions"])^2
    end
       
    # variable for normalized zone-based demand pricing  
    ggm.var[:zone_p] = @variable(ggm.model, [i in keys(ggm.ref[:price_zone])], basename="zone_p", lowerbound=pmin[i], upperbound=pmax[i])   
end

" function for creating variables associated with zonal pressure cost "
function variable_pressure_price{T,G}(ggm::GenericGasGridModel{T}, gm::GenericGasModel{G})
    junctions = gm.ref[:nw][gm.cnw][:junction] 
    
    pmin =  Dict{Any,Any}()
    pmax =  Dict{Any,Any}()  
    cmin = Dict{Any,Any}() 
    cmax = Dict{Any,Any}() 
    for (i, price_zone) in ggm.ref[:price_zone]
        pmin[i] = minimum(junctions[j]["pmin"] for j in ggm.ref[:price_zone][i]["junctions"])^2
        pmax[i] = maximum(junctions[j]["pmax"] for j in ggm.ref[:price_zone][i]["junctions"])^2
        cmin[i] = ggm.ref[:price_zone][i]["cost_p"][1] * pmin[i]^2 + ggm.ref[:price_zone][i]["cost_p"][2] * pmin[i] + ggm.ref[:price_zone][i]["cost_p"][3]
        cmax[i] = ggm.ref[:price_zone][i]["cost_p"][1] * pmax[i]^2 + ggm.ref[:price_zone][i]["cost_p"][2] * pmax[i] + ggm.ref[:price_zone][i]["cost_p"][3]                    
    end
       
    ggm.var[:p_cost] = @variable(ggm.model, [i in keys(ggm.ref[:price_zone])], basename="p_cost", lowerbound=max(0,cmin[i]), upperbound=cmax[i])    
end