#################################################################################
# This file defines commonly used and created constraints for gas-power models. #
#################################################################################


"Constraints that bound the maximum pressure in a gas price zone."
function constraint_zone_pressure(gpm::AbstractGasPowerModel, i::Int; nw::Int=nw_id_default)
    junctions = filter(x -> x.second["price_zone"] == i, _IM.ref(gpm, _GM.gm_it_sym, nw, :junction))
    constraint_zone_pressure(gpm, nw, i, keys(junctions))
end


"Constraints that bound the maximum pressure in a gas price zone."
function constraint_zone_pressure(gpm::AbstractGasPowerModel, n::Int, i::Int, junction_ids)
    if !haskey(_IM.con(gpm, _GM.gm_it_sym, n), :zone_pressure)
        _IM.con(gpm, _GM.gm_it_sym, n)[:zone_pressure] = Dict{Int, Dict}()
    end

    p_sqr, zone_p = _IM.var(gpm, _GM.gm_it_sym, n, :psqr), _IM.var(gpm, _GM.gm_it_sym, n, :zone_p)
    _IM.con(gpm, _GM.gm_it_sym, n, :zone_pressure)[i] = Dict{Int, JuMP.ConstraintRef}()

    for j in junction_ids
        c = JuMP.@constraint(gpm.model, zone_p[i] >= p_sqr[j])
        _IM.con(gpm, _GM.gm_it_sym, n, :zone_pressure, i)[j] = c
    end
end


"Constraint that relates the pressure price to the price zone."
function constraint_pressure_price(gpm::AbstractGasPowerModel, n::Int, i::Int, cost_p::Array{Float64,1})
    zone_p, p_cost = _IM.var(gpm, _GM.gm_it_sym, n, :zone_p), _IM.var(gpm, _GM.gm_it_sym, n, :p_cost)
    rhs = cost_p[1] * zone_p[i]^2 + cost_p[2] * zone_p[i] + cost_p[3]
    c = JuMP.@constraint(gpm.model, p_cost[i] >= rhs)
    _IM.con(gpm, _GM.gm_it_sym, n, :pressure_price)[i] = c
end


"Constraint that bounds demand zone price using delivery flows within the zone."
function constraint_zone_demand(gpm::AbstractGasPowerModel, n::Int, i::Int, delivery_ids::Array{Int,1})
    fl, zone_fl = _IM.var(gpm, _GM.gm_it_sym, n, :fl), _IM.var(gpm, _GM.gm_it_sym, n, :zone_fl, i)
    c = JuMP.@constraint(gpm.model, zone_fl == sum(fl[k] for k in delivery_ids))
    _IM.con(gpm, _GM.gm_it_sym, :zone_demand)[i] = c
end


"Constraint that bounds demand zone price using delivery flows within the zone."
function constraint_zone_demand_price(gpm::AbstractGasPowerModel, n::Int, i::Int, min_cost::Float64, cost_q::Array{Float64,1}, standard_density::Float64)
    # Get relevant zonal flow and cost variables.
    zone_fl, zone_cost = _IM.var(gpm, _GM.gm_it_sym, n, :zone_fl), _IM.var(gpm, _GM.gm_it_sym, n, :zone_cost)

    # The cost is in terms of m^3 at standard density. We have consumption in terms of m^3
    # per second. We convert this to a daily cost, where 1 day = 86400 seconds.
    rhs_1_quad = 86400.0^2 * cost_q[1] * (zone_fl[i] * (1.0/standard_density))^2
    rhs_1_linear = 86400.0 * cost_q[2] * zone_fl[i] * (1.0/standard_density) + cost_q[3]
    c_1 = JuMP.@constraint(gpm.model, zone_cost[i] >= rhs_1_quad + rhs_1_linear)

    rhs_2 = 86400.0 * min_cost * zone_fl[i] * (1.0/standard_density)
    c_2 = JuMP.@constraint(gpm.model, zone_cost[i] >= rhs_2)

    _IM.con(gpm, _GM.gm_it_sym, :zone_demand_price)[i] = [c_1, c_2]
end
