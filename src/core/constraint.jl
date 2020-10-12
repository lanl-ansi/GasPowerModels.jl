#################################################################################
# This file defines commonly used and created constraints for gas-power models. #
#################################################################################

"Constraints that bound the maximum pressure in a gas price zone."
function constraint_zone_pressure(gm::_GM.AbstractGasModel, i::Int; nw::Int=gm.cnw)
    if !haskey(_GM.con(gm, nw), :zone_pressure)
        _GM.con(gm, nw)[:zone_pressure] = Dict{Int,Dict{Int, JuMP.ConstraintRef}}()
    end

    _GM.con(gm, nw, :zone_pressure)[i] = Dict{Int, JuMP.ConstraintRef}()
    p_sqr, zone_p = _GM.var(gm, nw, :psqr), _GM.var(gm, nw, :zone_p)
    junctions = filter(x -> x.second["price_zone"] != -1, _GM.ref(gm, nw, :junction))

    for (j, junction) in filter(x -> x.second["price_zone"] == i, junctions)
        c = JuMP.@constraint(gm.model, zone_p[i] >= p_sqr[j])
        _GM.con(gm, nw, :zone_pressure, i)[j] = c
    end
end

"Constraint that relates the pressure price to the price zone."
function constraint_pressure_price(gm::_GM.AbstractGasModel, n::Int, i::Int, cost_p::Array{Float64,1})
    zone_p, p_cost = _GM.var(gm, n, :zone_p), _GM.var(gm, n, :p_cost)
    rhs = cost_p[1] * zone_p[i]^2 + cost_p[2] * zone_p[i] + cost_p[3]
    c = JuMP.@constraint(gm.model, p_cost[i] >= rhs)
    _GM._add_constraint!(gm, n, :pressure_price, i, c)
end

"Constraint that bounds demand zone price using delivery flows within the zone."
function constraint_zone_demand(gm::_GM.AbstractGasModel, n::Int, i::Int, delivery_ids::Array{Int,1})
    fl, zone_fl = _GM.var(gm, n, :fl), _GM.var(gm, n, :zone_fl, i)
    c = JuMP.@constraint(gm.model, zone_fl == sum(fl[k] for k in delivery_ids))
    _GM._add_constraint!(gm, n, :zone_demand, i, c)
end

"Constraint that bounds demand zone price using delivery flows within the zone."
function constraint_zone_demand_price(gm::_GM.AbstractGasModel, n::Int, i::Int, min_cost::Float64, cost_q::Array{Float64,1}, standard_density::Float64)
    # Get relevant zonal flow and cost variables.
    zone_fl, zone_cost = _GM.var(gm, n, :zone_fl), _GM.var(gm, n, :zone_cost)

    # The cost is in terms of m^3 at standard density. We have consumption in terms of m^3
    # per second. We convert this to a daily cost, where 1 day = 86400 seconds.
    rhs_1_quad = 86400.0^2 * cost_q[1] * (zone_fl[i] * (1.0/standard_density))^2
    rhs_1_linear = 86400.0 * cost_q[2] * zone_fl[i] * (1.0/standard_density) + cost_q[3]
    c_1 = JuMP.@constraint(gm.model, zone_cost[i] >= rhs_1_quad + rhs_1_linear)
    _GM._add_constraint!(gm, n, :zone_demand_price_1, i, c_1)

    rhs_2 = 86400.0 * min_cost * zone_fl[i] * (1.0/standard_density)
    c_2 = JuMP.@constraint(gm.model, zone_cost[i] >= rhs_2)
    _GM._add_constraint!(gm, n, :zone_demand_price_2, i, c_2)
end
