##########################################################################
# This file defines objectives used in gas-power problem specifications. #
##########################################################################

function objective_min_opf_cost(gpm::AbstractGasPowerModel; n::Int = gpm.cnw)
    gen_cost = Dict{Tuple{Int, Int}, Any}()

    for (i, gen) in _IM.ref(gpm, :ep, n, :gen)
        conductor_ids = _PM.conductor_ids(_get_powermodel_from_gaspowermodel(gpm), n)
        pg = sum(_IM.var(gpm, :ep, n, :pg, i)[c] for c in conductor_ids)

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
    zone_cost = _IM.var(gpm, :ng, n, :zone_cost)
    p_cost = _IM.var(gpm, :ng, n, :p_cost)

    JuMP.@objective(gpm.model, _IM._MOI.MIN_SENSE,
      power_opf_weight * sum(gen_cost[(n, i)] for (i, gen) in _IM.ref(gpm, :ep, n, :gen)) +
      gas_price_weight * sum(zone_cost[i] for (i, zone) in _IM.ref(gpm, :ng, n, :price_zone)) +
      gas_price_weight * sum(zone["constant_p"] * p_cost[i] for (i, zone) in _IM.ref(gpm, :ng, n, :price_zone))
    )
end


" function for congestion costs based on demand "
# This is equation 27 in the HICCS paper
function objective_min_ne_opf_cost(gpm::AbstractGasPowerModel; n::Int = gpm.cnw)
    gen_cost = Dict{Tuple{Int, Int}, Any}()

    for (i, gen) in _IM.ref(gpm, :ep, n, :gen)
        conductor_ids = _PM.conductor_ids(_get_powermodel_from_gaspowermodel(gpm), n)
        pg = sum(_IM.var(gpm, :ep, n, :pg, i)[c] for c in conductor_ids)

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

    p_cost, zone_cost = _IM.var(gpm, :ng, n, :p_cost), _IM.var(gpm, :ng, n, :zone_cost)
    zp, zc, = _IM.var(gpm, :ng, n, :zp), _IM.var(gpm, :ng, n, :zc)
    branch_ne, pg = _IM.var(gpm, :ep, n, :branch_ne), _IM.var(gpm, :ep, n, :pg)
    branches = _IM.ref(gpm, :ep, n, :ne_branch)

    JuMP.@objective(gpm.model, _IM._MOI.MIN_SENSE,
        gas_ne_weight    * sum(pipe["construction_cost"] * zp[i] for (i, pipe) in _IM.ref(gpm, :ng, n, :ne_pipe))
      + gas_ne_weight    * sum(compressor["construction_cost"] * zc[i] for (i, compressor) in _IM.ref(gpm, :ng, n, :ne_compressor)) +
      + power_ne_weight  * sum(branches[i]["construction_cost"] * branch_ne[i] for (i, branch) in branches) +
      + power_opf_weight * sum(gen_cost[(n, i)] for (i, gen) in _IM.ref(gpm, :ep, n, :gen)) +
      + gas_price_weight * sum(zone_cost[i] for (i, zone) in _IM.ref(gpm, :ng, n, :price_zone)) +
      + gas_price_weight * sum(zone["constant_p"] * p_cost[i] for (i, zone) in _IM.ref(gpm, :ng, n, :price_zone))
    )
end


"Objective that minimizes expansion costs only (as in the HICCS paper)."
function objective_min_ne_cost(gpm::AbstractGasPowerModel; n::Int = gpm.cnw)
    gas_ne_weight = get(gpm.data, "gas_ne_weight", 1.0)
    power_ne_weight = get(gpm.data, "power_ne_weight", 1.0)

    zc, ne_comps = _IM.var(gpm, :ng, n, :zc), _IM.ref(gpm, :ng, n, :ne_compressor)
    c_cost = length(ne_comps) > 0 ? gas_ne_weight *
        sum(comp["construction_cost"] * zc[i] for (i, comp) in ne_comps) : 0.0

    zp, ne_pipes = _IM.var(gpm, :ng, n, :zp), _IM.ref(gpm, :ng, n, :ne_pipe)
    p_cost = length(ne_pipes) > 0 ? gas_ne_weight *
        sum(pipe["construction_cost"] * zp[i] for (i, pipe) in ne_pipes) : 0.0

    zb, ne_lines = _IM.var(gpm, :ep, n, :branch_ne), _IM.ref(gpm, :ep, n, :ne_branch)
    l_cost = length(ne_lines) > 0 ? power_ne_weight *
        sum(line["construction_cost"] * zb[i] for (i, line) in ne_lines) : 0.0

    obj = JuMP.@objective(gpm.model, _IM._MOI.MIN_SENSE, c_cost + p_cost + l_cost)
end

function objective_max_load(gpm::AbstractGasPowerModel)
    # Get the objective for the power part of the problem.
    pm = _get_powermodel_from_gaspowermodel(gpm)
    ep_mld_objective = _PMR.objective_max_loadability(pm)

    # Get the objective for the gas part of the problem.
    gm = _get_gasmodel_from_gaspowermodel(gpm)
    ng_mld_objective = _GM.objective_max_load(gm)

    # Combine the objective functions (which are affine expressions).
    mld_objective = ep_mld_objective + ng_mld_objective

    JuMP.@objective(gpm.model, _IM._MOI.MAX_SENSE, mld_objective)
end
