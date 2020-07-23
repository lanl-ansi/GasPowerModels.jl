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
    junctions = filter(x -> x.second["price_zone"] != 0, _GM.ref(gm, n, :junction))
    fl_max = Dict{Int,Float64}(i => 0.0 for i in _GM.ids(gm, n, :price_zone))

    for (i, price_zone) in _GM.ref(gm, n, :price_zone)
        for (j, junc) in filter(x -> x.second["price_zone"] == i, junctions)
            dels = _GM.ref(gm, n, :dispatchable_deliveries_in_junction, j)
            fl_max[i] += length(dels) > 0 ? sum(_GM.ref(gm, n, :delivery, k)["withdrawal_max"] for k in dels) : 0.0
            dels = _GM.ref(gm, n, :nondispatchable_deliveries_in_junction, j)
            fl_max[i] += length(dels) > 0 ? sum(_GM.ref(gm, n, :delivery, k)["withdrawal_max"] for k in dels) : 0.0
        end
    end

    _GM.var(gm, n)[:zone_fl] = JuMP.@variable(
        gm.model, [i in _GM.ids(gm, n, :price_zone)], base_name="$(n)_zone_fl",
        lower_bound=0.0, upper_bound=fl_max[i],
        start=getstart(_GM.ref(gm, n, :price_zone), i, "zone_fl_start", 0.0))
end

" function for creating variables associated with zonal demand "
function variable_zone_demand_price(gm::_GM.AbstractGasModel, n::Int=gm.cnw)
    gm.var[:nw][n][:zone_cost] = JuMP.@variable(gm.model,
        [i in keys(gm.ref[:nw][n][:price_zone])],
        base_name="$(n)_zone_cost", lower_bound=0.0, upper_bound=Inf,
        start=getstart(_GM.ref(gm,n,:price_zone), i, "zone_cost_start", 0.0))
end

"Initializes variables associated with zonal demand."
function variable_zone_pressure(gm::_GM.AbstractGasModel, n::Int=gm.cnw)
    junctions = filter(x -> x.second["price_zone"] != 0, _GM.ref(gm, n, :junction))
    p_min, p_max = Dict{Int,Any}(), Dict{Int,Any}()

    for (i, price_zone) in _GM.ref(gm, n, :price_zone)
        juncs_i = filter(x -> x.second["price_zone"] == i, junctions)
        p_min[i] = minimum(junc["p_min"] for (j, junc) in juncs_i)^2
        p_max[i] = maximum(junc["p_max"] for (j, junc) in juncs_i)^2
    end

    # Variables for normalized zone-based demand pricing.
    gm.var[:nw][n][:zone_p] = JuMP.@variable(
        gm.model, [i in _GM.ids(gm, n, :price_zone)], base_name="$(n)_zone_p",
        lower_bound=p_min[i], upper_bound=p_max[i],
        start=getstart(_GM.ref(gm, n, :price_zone), i, "zone_p_start", 0.0))
end

" function for creating variables associated with zonal pressure cost "
function variable_pressure_price(gm::_GM.AbstractGasModel, n::Int=gm.cnw)
    junctions = filter(x -> x.second["price_zone"] != 0, _GM.ref(gm, n, :junction))
    p_min, p_max = Dict{Int,Any}(), Dict{Int,Any}()
    c_min, c_max = Dict{Int,Any}(), Dict{Int,Any}()

    for (i, price_zone) in _GM.ref(gm, n, :price_zone)
        juncs_i = filter(x -> x.second["price_zone"] == i, junctions)
        p_min[i] = minimum(junc["p_min"] for (j, junc) in juncs_i)^2
        p_max[i] = maximum(junc["p_max"] for (j, junc) in juncs_i)^2
        c_min[i] = sum(price_zone["cost_p"] .* [p_min[i]^2, p_min[i], 1.0])
        c_max[i] = sum(price_zone["cost_p"] .* [p_max[i]^2, p_max[i], 1.0])
    end

    gm.var[:nw][n][:p_cost] = JuMP.@variable(
        gm.model, [i in _GM.ids(gm, n, :price_zone)], base_name="$(n)_p_cost",
        lower_bound=max(0, c_min[i]), upper_bound=c_max[i],
        start=getstart(_GM.ref(gm, n, :price_zone), i, "p_cost_start", 0.0))
end
