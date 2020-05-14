################################################################################
# This file defines commonly used and created constraints for gas grid models
################################################################################

#### Constraints without Templates #######

" constraints associated with bounding the maximum pressure in a zone
 This is equation 24 in the HICCS paper "
function constraint_zone_pressure(gm::_GM.AbstractGasModel, n::Int, i)
    price_zone = _GM.ref(gm, n, :price_zone, i)
    zone_p = _GM.var(gm, n, :zone_p)
    p = _GM.var(gm, n, :p)

    if !haskey(gm.con[:nw][n], :zone_pressure)
        gm.con[:nw][n][:zone_pressure] = Dict{Int,Dict{Int,ConstraintRef}}()
    end

    gm.con[:nw][n][:zone_pressure][i] = Dict{Int,ConstraintRef}()

    for j in gm.ref[:nw][n][:price_zone][i]["junctions"]
        c = JuMP.@constraint(gm.model, zone_p[i] >= p[j])
        gm.con[:nw][n][:zone_pressure][i][j] = c
    end
end

function constraint_zone_pressure(gm::_GM.AbstractGasModel, i::Int) 
    constraint_zone_pressure(gm, gm.cnw, i)
end

#### Constraints with Templates #####
function constraint_zone_demand(gm::_GM.AbstractGasModel, n::Int, i, loads)
    fl = _GM.var(gm, n, :fl)
    zone_fl = _GM.var(gm, n, :zone_fl)
    c = JuMP.@constraint(gm.model, zone_fl[i] == sum(fl[j] for j in loads))
    _GM.add_constraint(gm, n, :zone_demand, i, c)
end

" constraints associated with bounding the demand zone prices
 This is equation 22 in the HICCS paper"
function constraint_zone_demand_price(gm::_GM.AbstractGasModel, n::Int, i, min_cost, cost_q, standard_density)
    zone_fl = _GM.var(gm, n, :zone_fl)
    zone_cost = _GM.var(gm, n, :zone_cost)

    "The cost is in terms of m^3 at standard density. We have consumption in
    terms of m^3 per second. We convert this to a daily cost, where 1 day =
    86400 seconds."

    rhs_1 = 86400.0^2 * cost_q[1] * (zone_fl[i] / standard_density)^2 + 86400.0 * cost_q[2] * zone_fl[i] / standard_density + cost_q[3]
    c_1 = JuMP.@constraint(gm.model, zone_cost[i] >= rhs_1)
    _GM.add_constraint(gm, n, :zone_demand_price1, i, c_1)

    rhs_2 = 86400.0 * min_cost * zone_fl[i] / standard_density
    c_2 = JuMP.@constraint(gm.model, zone_cost[i] >= rhs_2)
    _GM.add_constraint(gm, n, :zone_demand_price2, i, c_2)
end

" constraints associated with pressure prices
 This is equation 25 in the HICCS paper"
function constraint_pressure_price(gm::_GM.AbstractGasModel, n::Int, i, cost_p)
    zone_p = _GM.var(gm, n, :zone_p)
    p_cost = _GM.var(gm, n, :p_cost)

    rhs = cost_p[1] * zone_p[i]^2 + cost_p[2] * zone_p[i] + cost_p[3]
    c = JuMP.@constraint(gm.model, p_cost[i] >= rhs)
    _GM.add_constraint(gm, n, :pressure_price, i, c)
end
