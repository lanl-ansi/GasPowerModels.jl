##########################################################################
# This file defines objectives used in gas-power problem specifications. #
##########################################################################

function objective_min_opf_cost(gpm::AbstractGasPowerModel; n::Int = gpm.cnw)
    gen_cost = Dict{Tuple{Int, Int}, Any}()

    for (i, gen) in _IM.ref(gpm, _PM.pm_it_sym, n, :gen)
        conductor_ids = _PM.conductor_ids(_get_powermodel_from_gaspowermodel(gpm), n)
        pg = sum(_IM.var(gpm, _PM.pm_it_sym, n, :pg, i)[c] for c in conductor_ids)

        if length(gen["cost"]) == 1
            gen_cost[(n, i)] = gen["cost"][1]
        elseif length(gen["cost"]) == 2
            gen_cost[(n, i)] = gen["cost"][1]*pg + gen["cost"][2]
        elseif length(gen["cost"]) == 3
            gen_cost[(n, i)] = gen["cost"][1]*pg^2 + gen["cost"][2]*pg + gen["cost"][3]
        else
            gen_cost[(n, i)] = 0.0
        end
    end

    # Get objective weights from power network reference data.
    power_opf_weight = get(gpm.data, "power_opf_weight", 1.0)
    gas_price_weight = get(gpm.data, "gas_price_weight", 1.0)

    # Get placeholders for variables in the objective function.
    zone_cost = _IM.var(gpm, _GM.gm_it_sym, n, :zone_cost)
    p_cost = _IM.var(gpm, _GM.gm_it_sym, n, :p_cost)

    JuMP.@objective(gpm.model, _IM._MOI.MIN_SENSE,
      power_opf_weight * sum(gen_cost[(n, i)] for (i, gen) in _IM.ref(gpm, _PM.pm_it_sym, n, :gen)) +
      gas_price_weight * sum(zone_cost[i] for (i, zone) in _IM.ref(gpm, _GM.gm_it_sym, n, :price_zone)) +
      gas_price_weight * sum(zone["constant_p"] * p_cost[i] for (i, zone) in _IM.ref(gpm, _GM.gm_it_sym, n, :price_zone))
    )
end


" function for congestion costs based on demand "
# This is equation 27 in the HICCS paper
function objective_min_ne_opf_cost(gpm::AbstractGasPowerModel; n::Int = gpm.cnw)
    gen_cost = Dict{Tuple{Int, Int}, Any}()

    for (i, gen) in _IM.ref(gpm, _PM.pm_it_sym, n, :gen)
        conductor_ids = _PM.conductor_ids(_get_powermodel_from_gaspowermodel(gpm), n)
        pg = sum(_IM.var(gpm, _PM.pm_it_sym, n, :pg, i)[c] for c in conductor_ids)

        if length(gen["cost"]) == 1
            gen_cost[(n, i)] = gen["cost"][1]
        elseif length(gen["cost"]) == 2
            gen_cost[(n, i)] = gen["cost"][1]*pg + gen["cost"][2]
        elseif length(gen["cost"]) == 3
            gen_cost[(n, i)] = gen["cost"][1]*pg^2 + gen["cost"][2]*pg + gen["cost"][3]
        else
            gen_cost[(n, i)] = 0.0
        end
    end

    gas_ne_weight    = get(gpm.data, "gas_ne_weight", 1.0)
    power_ne_weight  = get(gpm.data, "power_ne_weight", 1.0)
    power_opf_weight = get(gpm.data, "power_opf_weight", 1.0)
    gas_price_weight = get(gpm.data, "gas_price_weight", 1.0)

    p_cost, zone_cost = _IM.var(gpm, _GM.gm_it_sym, n, :p_cost), _IM.var(gpm, _GM.gm_it_sym, n, :zone_cost)
    zp, zc, = _IM.var(gpm, _GM.gm_it_sym, n, :zp), _IM.var(gpm, _GM.gm_it_sym, n, :zc)
    branch_ne, pg = _IM.var(gpm, _PM.pm_it_sym, n, :branch_ne), _IM.var(gpm, _PM.pm_it_sym, n, :pg)
    branches = _IM.ref(gpm, _PM.pm_it_sym, n, :ne_branch)

    JuMP.@objective(gpm.model, _IM._MOI.MIN_SENSE,
        gas_ne_weight    * sum(pipe["construction_cost"] * zp[i] for (i, pipe) in _IM.ref(gpm, _GM.gm_it_sym, n, :ne_pipe))
      + gas_ne_weight    * sum(compressor["construction_cost"] * zc[i] for (i, compressor) in _IM.ref(gpm, _GM.gm_it_sym, n, :ne_compressor)) +
      + power_ne_weight  * sum(branches[i]["construction_cost"] * branch_ne[i] for (i, branch) in branches) +
      + power_opf_weight * sum(gen_cost[(n, i)] for (i, gen) in _IM.ref(gpm, _PM.pm_it_sym, n, :gen)) +
      + gas_price_weight * sum(zone_cost[i] for (i, zone) in _IM.ref(gpm, _GM.gm_it_sym, n, :price_zone)) +
      + gas_price_weight * sum(zone["constant_p"] * p_cost[i] for (i, zone) in _IM.ref(gpm, _GM.gm_it_sym, n, :price_zone))
    )
end


"Objective that minimizes expansion costs only (as in the HICCS paper)."
function objective_min_ne_cost(gpm::AbstractGasPowerModel; n::Int = gpm.cnw)
    gas_ne_weight = get(gpm.data, "gas_ne_weight", 1.0)
    power_ne_weight = get(gpm.data, "power_ne_weight", 1.0)

    zc, ne_comps = _IM.var(gpm, _GM.gm_it_sym, n, :zc), _IM.ref(gpm, _GM.gm_it_sym, n, :ne_compressor)
    c_cost = length(ne_comps) > 0 ? gas_ne_weight *
        sum(comp["construction_cost"] * zc[i] for (i, comp) in ne_comps) : 0.0

    zp, ne_pipes = _IM.var(gpm, _GM.gm_it_sym, n, :zp), _IM.ref(gpm, _GM.gm_it_sym, n, :ne_pipe)
    p_cost = length(ne_pipes) > 0 ? gas_ne_weight *
        sum(pipe["construction_cost"] * zp[i] for (i, pipe) in ne_pipes) : 0.0

    zb, ne_lines = _IM.var(gpm, _PM.pm_it_sym, n, :branch_ne), _IM.ref(gpm, _PM.pm_it_sym, n, :ne_branch)
    l_cost = length(ne_lines) > 0 ? power_ne_weight *
        sum(line["construction_cost"] * zb[i] for (i, line) in ne_lines) : 0.0

    obj = JuMP.@objective(gpm.model, _IM._MOI.MIN_SENSE, c_cost + p_cost + l_cost)
end


function objective_max_gas_load(gpm::AbstractGasPowerModel)
    # Initialize the affine expression for the objective function.
    objective, scalar = JuMP.AffExpr(0.0), 0.0

    for (nw, nw_ref) in _IM.nws(gpm, _GM.gm_it_sym)
        # Get all delivery generator linking components.
        delivery_gens = _IM.ref(gpm, :dep, nw, :delivery_gen)

        # Get a list of delivery indices associated with generation production.
        dels_exclude = [x["delivery"]["id"] for (i, x) in delivery_gens]

        # Include only deliveries that are dispatchable within the objective.
        gm_deliveries = _IM.ref(gpm, _GM.gm_it_sym, nw, :delivery)
        dels = filter(x -> x.second["is_dispatchable"] == 1, gm_deliveries)

        # Include only non-generation deliveries within the objective.
        dels_non_power = filter(x -> !(x.second["index"] in dels_exclude), dels)

        for (i, del) in dels_non_power
            # Add the prioritized gas load to the maximum load delivery objective.
            objective += get(del, "priority", 1.0) * _IM.var(gpm, _GM.gm_it_sym, nw, :fl, del["id"])
            scalar += get(del, "priority", 1.0) * abs(del["withdrawal_max"])
        end
    end

    # Correct the scalar if necessary.
    scalar = scalar > 0.0 ? scalar : 1.0

    # Return the objective, which maximizes prioritized gas load deliveries.
    return JuMP.@objective(gpm.model, _IM._MOI.MAX_SENSE, objective / scalar)
end


function objective_max_power_load(gpm::AbstractGasPowerModel)
    # Initialize the affine expression for the objective function.
    objective, scalar = JuMP.AffExpr(0.0), 0.0

    for (nw, nw_ref) in _IM.nws(gpm, _PM.pm_it_sym)
        for (i, load) in _IM.ref(gpm, _PM.pm_it_sym, nw, :load)
            # Add the prioritized power load to the maximum load delivery objective.
            time_elapsed = get(_IM.ref(gpm, _PM.pm_it_sym, nw), :time_elapsed, 1.0)
            demand = _IM.var(gpm, _PM.pm_it_sym, nw, :z_demand, load["index"]) * abs(load["pd"])
            objective += get(load, "weight", 1.0) * time_elapsed * demand
            scalar += get(load, "weight", 1.0) * abs(load["pd"]) * time_elapsed
        end
    end

    # Correct the scalar if necessary.
    scalar = scalar > 0.0 ? scalar : 1.0

    # Return the objective, which maximizes prioritized power load deliveries.
    return JuMP.@objective(gpm.model, _IM._MOI.MAX_SENSE, objective / scalar)
end


function objective_max_load(gpm::AbstractGasPowerModel)
    ng_mld_objective = objective_max_gas_load(gpm)
    ep_mld_objective = objective_max_power_load(gpm)

    # Get the priorities associated with each subnetwork's MLD.
    ng_priority = get(gpm.data, "gm_load_priority", 1.0)
    ep_priority = get(gpm.data, "pm_load_priority", 1.0)

    # Combine the objective functions (which are affine expressions).
    mld_objective = ng_priority * ng_mld_objective + ep_priority * ep_mld_objective
    return JuMP.@objective(gpm.model, _IM._MOI.MAX_SENSE, mld_objective)
end
