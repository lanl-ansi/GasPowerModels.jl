################################################################################
# This file defines common variables used in power flow models
# This will hopefully make everything more compositional
################################################################################


"Function for extracting the start/initial value of a variable."
function getstart(set, item_key, value_key, default=0.0)
    return get(get(set, item_key, Dict()), value_key, default)
end


"Function for creating variables associated with zonal demand: ``\\psi``."
function variable_zone_demand(gpm::AbstractGasPowerModel, n::Int=nw_id_default, report::Bool=true)
    junctions = filter(x -> haskey(x.second, "price_zone") && x.second["price_zone"] != 0, _IM.ref(gpm, _GM.gm_it_sym, n, :junction))
    fl_max = Dict{Int,Float64}(i => 0.0 for i in _IM.ids(gpm, _GM.gm_it_sym, n, :price_zone))

    for (i, price_zone) in _IM.ref(gpm, _GM.gm_it_sym, n, :price_zone)
        for (j, junc) in filter(x -> x.second["price_zone"] == i, junctions)
            dels = _IM.ref(gpm, _GM.gm_it_sym, n, :dispatchable_deliveries_in_junction, j)
            fl_max[i] += length(dels) > 0 ? sum(_IM.ref(gpm, _GM.gm_it_sym, n, :delivery, k)["withdrawal_max"] for k in dels) : 0.0
            dels = _IM.ref(gpm, _GM.gm_it_sym, n, :nondispatchable_deliveries_in_junction, j)
            fl_max[i] += length(dels) > 0 ? sum(_IM.ref(gpm, _GM.gm_it_sym, n, :delivery, k)["withdrawal_max"] for k in dels) : 0.0
        end
    end

    zone_fl = _IM.var(gpm, _GM.gm_it_sym, n)[:zone_fl] = JuMP.@variable(
        gpm.model, [i in _IM.ids(gpm, _GM.gm_it_sym, n, :price_zone)], base_name = "$(n)_zone_fl",
        lower_bound = 0.0, upper_bound = max(0.0, fl_max[i]),
        start = getstart(_IM.ref(gpm, _GM.gm_it_sym, n, :price_zone), i, "zone_fl_start", 0.0))

    report && _GM.sol_component_value(_get_gasmodel_from_gaspowermodel(gpm), n, :price_zone, :zone_fl, _IM.ids(gpm, _GM.gm_it_sym, n, :price_zone), zone_fl)
end


"Function for creating variables associated with zonal demand price: ``\\gamma``."
function variable_zone_demand_price(gpm::AbstractGasPowerModel, n::Int=nw_id_default, report::Bool=true)
    zone_cost = _IM.var(gpm, _GM.gm_it_sym, n)[:zone_cost] = JuMP.@variable(gpm.model,
        [i in keys(_IM.ref(gpm, _GM.gm_it_sym, n, :price_zone))],
        base_name="$(n)_zone_cost", lower_bound = 0.0, upper_bound = Inf,
        start = getstart(_IM.ref(gpm, _GM.gm_it_sym, n, :price_zone), i, "zone_cost_start", 0.0))

    report && _GM.sol_component_value(_get_gasmodel_from_gaspowermodel(gpm), n, :price_zone, :zone_cost, _IM.ids(gpm, _GM.gm_it_sym, n, :price_zone), zone_cost)
end


"Function for creating variables associated with zonal pressure: ``\\rho``."
function variable_zone_pressure(gpm::AbstractGasPowerModel, n::Int=nw_id_default, report::Bool=true)
    junctions = filter(x -> haskey(x.second, "price_zone") && x.second["price_zone"] != 0, _IM.ref(gpm, _GM.gm_it_sym, n, :junction))
    p_min, p_max = Dict{Int,Any}(), Dict{Int,Any}()

    for (i, price_zone) in _IM.ref(gpm, _GM.gm_it_sym, n, :price_zone)
        juncs_i = filter(x -> x.second["price_zone"] == i, junctions)
        p_min[i] = minimum(junc["p_min"] for (j, junc) in juncs_i)^2
        p_max[i] = maximum(junc["p_max"] for (j, junc) in juncs_i)^2
    end

    # Variables for normalized zone-based demand pricing.
    zone_p = _IM.var(gpm, _GM.gm_it_sym, n)[:zone_p] = JuMP.@variable(
        gpm.model, [i in _IM.ids(gpm, _GM.gm_it_sym, n, :price_zone)], base_name = "$(n)_zone_p",
        lower_bound = p_min[i], upper_bound = p_max[i],
        start = getstart(_IM.ref(gpm, _GM.gm_it_sym, n, :price_zone), i, "zone_p_start", 0.0))

    report && _GM.sol_component_value(_get_gasmodel_from_gaspowermodel(gpm), n, :price_zone, :zone_p, _IM.ids(gpm, _GM.gm_it_sym, n, :price_zone), zone_p)
end


"Function for creating variables associated with zonal pressure price: ``\\omega``."
function variable_pressure_price(gpm::AbstractGasPowerModel, n::Int=nw_id_default, report::Bool=true)
    junctions = filter(x -> haskey(x.second, "price_zone") && x.second["price_zone"] != 0, _IM.ref(gpm, _GM.gm_it_sym, n, :junction))
    p_min, p_max = Dict{Int,Any}(), Dict{Int,Any}()
    c_min, c_max = Dict{Int,Any}(), Dict{Int,Any}()

    for (i, price_zone) in _IM.ref(gpm, _GM.gm_it_sym, n, :price_zone)
        juncs_i = filter(x -> x.second["price_zone"] == i, junctions)
        p_min[i] = minimum(junc["p_min"] for (j, junc) in juncs_i)^2
        p_max[i] = maximum(junc["p_max"] for (j, junc) in juncs_i)^2
        c_min[i] = sum(price_zone["cost_p"] .* [p_min[i]^2, p_min[i], 1.0])
        c_max[i] = sum(price_zone["cost_p"] .* [p_max[i]^2, p_max[i], 1.0])
    end

    p_cost = _IM.var(gpm, _GM.gm_it_sym, n)[:p_cost] = JuMP.@variable(
        gpm.model, [i in _IM.ids(gpm, _GM.gm_it_sym, n, :price_zone)], base_name = "$(n)_p_cost",
        lower_bound = max(0.0, c_min[i]), upper_bound = max(0.0, c_max[i]),
        start = getstart(_IM.ref(gpm, _GM.gm_it_sym, n, :price_zone), i, "p_cost_start", 0.0))

    report && _GM.sol_component_value(_get_gasmodel_from_gaspowermodel(gpm), n, :price_zone, :p_cost, _IM.ids(gpm, _GM.gm_it_sym, n, :price_zone), p_cost)
end
