################################################################################
# This file defines common variables used in power flow models
# This will hopefully make everything more compositional
################################################################################

" extracts the start value "
function getstart(set, item_key, value_key, default=0.0)
    return get(get(set, item_key, Dict()), value_key, default)
end

" function for creating variables associated with zonal demand "
function variable_zone_demand(gm::_GM.AbstractGasModel, n::Int=gm.cnw)
    consumers = _GM.ref(gm, n, :delivery)
    flmax =  Dict{Int,Float64}(i=>0.0 for i in _GM.ids(gm, n, :price_zone))

    for (i, price_zone) in ref(gm, n, :price_zone)
        for j in ref(gm, n, :price_zone, i)["junctions"]
            junction_consumers = ref(gm, n, :junction_consumers, j)
            flmax[i] += sum(_GM.calc_flmax(gm.data, consumers[k]) for k in junction_consumers)
        end
    end

    gm.var[:nw][n][:zone_fl] = JuMP.@variable(gm.model,
        [i in keys(gm.ref[:nw][n][:price_zone])], base_name="$(n)_zone_fl",
        lower_bound=0.0, upper_bound=flmax[i],
        start = getstart(_GM.ref(gm,n,:price_zone), i, "zone_fl_start", 0.0))
end

" function for creating variables associated with zonal demand "
function variable_zone_demand_price(gm::_GM.AbstractGasModel, n::Int=gm.cnw)
    gm.var[:nw][n][:zone_cost] = JuMP.@variable(gm.model,
        [i in keys(gm.ref[:nw][n][:price_zone])],
        base_name="$(n)_zone_cost", lower_bound=0.0, upper_bound=Inf,
        start=getstart(_GM.ref(gm,n,:price_zone), i, "zone_cost_start", 0.0))
end

" function for creating variables associated with zonal demand "
function variable_zone_pressure(gm::_GM.AbstractGasModel, n::Int=gm.cnw)
    junctions = gm.ref[:nw][n][:junction]

    pmin =  Dict{Any,Any}()
    pmax =  Dict{Any,Any}()
    for (i, price_zone) in gm.ref[:nw][n][:price_zone]
        pmin[i] = minimum(junctions[j]["p_min"] for j in gm.ref[:nw][n][:price_zone][i]["junctions"])^2
        pmax[i] = maximum(junctions[j]["p_max"] for j in gm.ref[:nw][n][:price_zone][i]["junctions"])^2
    end

    # variable for normalized zone-based demand pricing
    gm.var[:nw][n][:zone_p] = JuMP.@variable(gm.model, [i in keys(gm.ref[:nw][n][:price_zone])], base_name="$(n)_zone_p", lower_bound=pmin[i], upper_bound=pmax[i], start = getstart(_GM.ref(gm,n,:price_zone), i, "zone_p_start", 0.0))
end

" function for creating variables associated with zonal pressure cost "
function variable_pressure_price(gm::_GM.AbstractGasModel, n::Int=gm.cnw)
    junctions = gm.ref[:nw][n][:junction]
    baseP     = gm.data["baseP"]

    pmin =  Dict{Any,Any}()
    pmax =  Dict{Any,Any}()
    cmin =  Dict{Any,Any}()
    cmax =  Dict{Any,Any}()
    for (i, price_zone) in gm.ref[:nw][n][:price_zone]
        pmin[i] = minimum(junctions[j]["p_min"] for j in gm.ref[:nw][n][:price_zone][i]["junctions"])^2
        pmax[i] = maximum(junctions[j]["p_max"] for j in gm.ref[:nw][n][:price_zone][i]["junctions"])^2

        cmin[i] = gm.ref[:nw][n][:price_zone][i]["cost_p"][1] * pmin[i]^2 + gm.ref[:nw][n][:price_zone][i]["cost_p"][2] * pmin[i] + gm.ref[:nw][n][:price_zone][i]["cost_p"][3]
        cmax[i] = gm.ref[:nw][n][:price_zone][i]["cost_p"][1] * pmax[i]^2 + gm.ref[:nw][n][:price_zone][i]["cost_p"][2] * pmax[i] + gm.ref[:nw][n][:price_zone][i]["cost_p"][3]
    end

    gm.var[:nw][n][:p_cost] = JuMP.@variable(gm.model, [i in keys(gm.ref[:nw][n][:price_zone])], base_name="$(n)_p_cost", lower_bound=max(0,cmin[i]), upper_bound=cmax[i], start = getstart(_GM.ref(gm,n,:price_zone), i, "p_cost_start", 0.0))
end
