##########################################################################
# This file defines objectives used in gas-power problem specifications. #
##########################################################################

function objective_min_ogpf_cost(gm::_GM.AbstractGasModel, pm::_PM.AbstractPowerModel, n::Int=gm.cnw)
    power_opf_weight = get(_PM.ref(pm, n), :power_opf_weight, 1.0)
    gas_price_weight = get(_PM.ref(pm, n), :gas_price_weight, 1.0)
    ne_normalization = get(_PM.ref(pm, n), :ne_normalization, 1.0)

    pg = _PM.var(pm, n, :pg)

    # constraint for normalized zone-based demand pricing
    zone_cost = _GM.var(gm, n, :zone_cost)
    p_cost = _GM.var(gm, n, :p_cost)

    for (i, price_zone) in _GM.ref(gm, n, :price_zone)
        constraint_zone_demand(gm, i)
        constraint_zone_demand_price(gm, i)
        constraint_zone_pressure(gm, i)
        constraint_pressure_price(gm, i)
    end

    gen_cost = Dict()

    for (i, gen) in _PM.ref(pm, :gen, nw=n)
        pg = sum(_PM.var(pm, n, c, :pg, i) for c in _PM.conductor_ids(pm, n))

        if length(gen["cost"]) == 1
            gen_cost[(n,i)] = gen["cost"][1]
        elseif length(gen["cost"]) == 2
            gen_cost[(n,i)] = gen["cost"][1]*pg + gen["cost"][2]
        elseif length(gen["cost"]) == 3
            gen_cost[(n,i)] = gen["cost"][1]*pg^2 + gen["cost"][2]*pg + gen["cost"][3]
        else
            gen_cost[(n,i)] = 0.0
        end
    end

    obj = JuMP.@objective(gm.model, Min,
      power_opf_weight * sum(gen_cost[(n,i)] for (i,gen) in _PM.ref(pm, :gen, nw=n)) +
      gas_price_weight * sum(zone_cost[i] for (i,zone) in _GM.ref(gm,n,:price_zone)) +
      gas_price_weight * sum(zone["constant_p"] * p_cost[i] for (i,zone) in _GM.ref(gm,n,:price_zone))
    )
end

" function for congestion costs based on demand "
# This is equation 27 in the HICCS paper
function objective_min_ne_ogpf_cost(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel, n::Int=gm.cnw)
    gas_ne_weight = get(_PM.ref(pm, n), :gas_ne_weight, 1.0)
    power_ne_weight = get(_PM.ref(pm, n), :power_ne_weight, 1.0)
    power_opf_weight = get(_PM.ref(pm, n), :power_opf_weight, 1.0)
    gas_price_weight = get(_PM.ref(pm, n), :gas_price_weight, 1.0)
    ne_normalization = get(_PM.ref(pm, n), :ne_normalization, 1.0)

    zp, zc, = _GM.var(gm, n, :zp), _GM.var(gm, n, :zc)
    branch_ne, pg = _PM.var(pm, n, :branch_ne), _PM.var(pm, n, :pg)
    branches = _PM.ref(pm, n, :ne_branch)

    # constraint for normalized zone-based demand pricing
    zone_cost = _GM.var(gm, n, :zone_cost)
    p_cost = _GM.var(gm, n, :p_cost)

    for (i, price_zone) in _GM.ref(gm, n, :price_zone)
        constraint_zone_demand(gm, i)
        constraint_zone_demand_price(gm, i)
        constraint_zone_pressure(gm, i)
        constraint_pressure_price(gm, i)
    end

    gen_cost = Dict()

    for (i, gen) in _PM.ref(pm, :gen, nw=n)
        pg = sum(_PM.var(pm, n, :pg, i))

        if length(gen["cost"]) == 1
            gen_cost[(n,i)] = gen["cost"][1]
        elseif length(gen["cost"]) == 2
            gen_cost[(n,i)] = gen["cost"][1]*pg + gen["cost"][2]
        elseif length(gen["cost"]) == 3
            gen_cost[(n,i)] = gen["cost"][1]*pg^2 + gen["cost"][2]*pg + gen["cost"][3]
        else
            gen_cost[(n,i)] = 0.0
        end
    end

    obj = JuMP.@objective(gm.model, Min,
      gas_ne_weight * ne_normalization    * sum(pipe["construction_cost"] * zp[i] for (i,pipe) in _GM.ref(gm,n,:ne_pipe)) +
      gas_ne_weight * ne_normalization    * sum(compressor["construction_cost"] * zc[i] for (i,compressor) in _GM.ref(gm,n,:ne_compressor)) +
      power_ne_weight * ne_normalization  * sum(branches[i]["construction_cost"]*branch_ne[i] for (i,branch) in branches) +
      power_opf_weight * ne_normalization * sum(gen_cost[(n,i)] for (i,gen) in _PM.ref(pm, :gen, nw=n)) +
      gas_price_weight * ne_normalization * sum(zone_cost[i] for (i,zone) in _GM.ref(gm,n,:price_zone)) +
      gas_price_weight * ne_normalization * sum(zone["constant_p"] * p_cost[i] for (i,zone) in _GM.ref(gm,n,:price_zone))
    )
end

"Objective that minimizes expansion costs only (as in the HICCS paper)."
function objective_min_ne_cost(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel, n::Int=gm.cnw)
    gas_ne_weight = get(_PM.ref(pm, n), :gas_ne_weight, 1.0)
    power_ne_weight = get(_PM.ref(pm, n), :power_ne_weight, 1.0)
    ne_normalization = get(_PM.ref(pm, n), :ne_normalization, 1.0)

    zc, ne_comps = _GM.var(gm, n, :zc), _GM.ref(gm, n, :ne_compressor)
    c_cost = length(ne_comps) > 0 ? gas_ne_weight * ne_normalization *
        sum(comp["construction_cost"] * zc[i] for (i, comp) in ne_comps) : 0.0

    zp, ne_pipes = _GM.var(gm, n, :zp), _GM.ref(gm, n, :ne_pipe)
    p_cost = length(ne_pipes) > 0 ? gas_ne_weight * ne_normalization *
        sum(pipe["construction_cost"] * zp[i] for (i, pipe) in ne_pipes) : 0.0

    zb, ne_lines = _PM.var(pm, n, :branch_ne), _PM.ref(pm, n, :ne_branch)
    l_cost = length(ne_lines) > 0 ? power_ne_weight * ne_normalization *
        sum(line["construction_cost"] * zb[i] for (i, line) in ne_lines) : 0.0

    obj = JuMP.@objective(gm.model, _IM._MOI.MIN_SENSE, c_cost + p_cost + l_cost)
end
