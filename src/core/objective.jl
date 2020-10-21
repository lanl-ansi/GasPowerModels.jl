##########################################################################
# This file defines objectives used in gas-power problem specifications. #
##########################################################################

"Objective function for minimizing the gas grid optimal flow as defined in reference
Russell Bent, Seth Blumsack, Pascal Van Hentenryck, Conrado Borraz-Sánchez, Mehdi Shahriari.
Joint Electricity and Natural Gas Transmission Planning With Endogenous Market Feedbacks.
IEEE Transactions on Power Systems. 33 (6):  6397 - 6409, 2018. More formally, this objective
is stated as ``min \\lambda \\sum_{g \\in G} (c^1_g pg_g^2 + c^2_g pg_g + c^3_g) + \\gamma \\sum_{z \\in Z} cost_z + \\gamma \\sum_{z \\in Z} pc_z ``
where ``\\lambda`` and ``\\gamma`` are weighting terms"
function objective_min_opf_cost(gm::_GM.AbstractGasModel, pm::_PM.AbstractPowerModel; n::Int=gm.cnw)
    gen_cost = Dict{Tuple{Int,Int},Any}()

    for (i, gen) in _PM.ref(pm, :gen, nw=n)
        pg = sum(_PM.var(pm, n, :pg, i)[c] for c in _PM.conductor_ids(pm, n))

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
    power_opf_weight = get(pm.data, "power_opf_weight", 1.0)
    gas_price_weight = get(pm.data, "gas_price_weight", 1.0)

    # Get placeholders for variables in the objective function.
    zone_cost = _GM.var(gm, n, :zone_cost)
    p_cost = _GM.var(gm, n, :p_cost)

    JuMP.@objective(gm.model, _IM._MOI.MIN_SENSE,
      power_opf_weight * sum(gen_cost[(n, i)] for (i, gen) in _PM.ref(pm, n, :gen)) +
      gas_price_weight * sum(zone_cost[i] for (i, zone) in _GM.ref(gm, n, :price_zone)) +
      gas_price_weight * sum(zone["constant_p"] * p_cost[i] for (i, zone) in _GM.ref(gm, n, :price_zone))
    )
end

"Objective function for minimizing the gas grid optimal flow combined with network expansion costs as defined in reference
Russell Bent, Seth Blumsack, Pascal Van Hentenryck, Conrado Borraz-Sánchez, Mehdi Shahriari.
Joint Electricity and Natural Gas Transmission Planning With Endogenous Market Feedbacks.
IEEE Transactions on Power Systems. 33 (6):  6397 - 6409, 2018. More formally, this objective
is stated as ``min \\alpha \\sum_{(i,j) \\in Pipe \\cup Compressors} \\kappa_{ij} z_{ij} +  \\beta \\sum_{(i,j) \\in Branches} \\kappa_{ij} z_{ij} + \\lambda \\sum_{g \\in G} (c^1_g pg_g^2 + c^2_g pg_g + c^3_g) + \\gamma \\sum_{z \\in Z} cost_z + \\gamma \\sum_{z \\in Z} pc_z ``
where ``\\lambda, \\alpha, \\beta`` and ``\\gamma`` are weighting terms"
function objective_min_ne_opf_cost(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel; n::Int=gm.cnw)
    gen_cost = Dict{Tuple{Int,Int},Any}()

    for (i, gen) in _PM.ref(pm, :gen, nw=n)
        pg = sum(_PM.var(pm, n, :pg, i)[c] for c in _PM.conductor_ids(pm, n))

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

    gas_ne_weight    = get(pm.data, "gas_ne_weight", 1.0)
    power_ne_weight  = get(pm.data, "power_ne_weight", 1.0)
    power_opf_weight = get(pm.data, "power_opf_weight", 1.0)
    gas_price_weight = get(pm.data, "gas_price_weight", 1.0)

    p_cost, zone_cost = _GM.var(gm, n, :p_cost), _GM.var(gm, n, :zone_cost)
    zp, zc, = _GM.var(gm, n, :zp), _GM.var(gm, n, :zc)
    branch_ne, pg = _PM.var(pm, n, :branch_ne), _PM.var(pm, n, :pg)
    branches = _PM.ref(pm, n, :ne_branch)

    JuMP.@objective(gm.model, _IM._MOI.MIN_SENSE,
        gas_ne_weight    * sum(pipe["construction_cost"] * zp[i] for (i, pipe) in _GM.ref(gm, n, :ne_pipe))
      + gas_ne_weight    * sum(compressor["construction_cost"] * zc[i] for (i, compressor) in _GM.ref(gm, n, :ne_compressor)) +
      + power_ne_weight  * sum(branches[i]["construction_cost"] * branch_ne[i] for (i, branch) in branches) +
      + power_opf_weight * sum(gen_cost[(n, i)] for (i, gen) in _PM.ref(pm, :gen, nw=n)) +
      + gas_price_weight * sum(zone_cost[i] for (i, zone) in _GM.ref(gm, n, :price_zone)) +
      + gas_price_weight * sum(zone["constant_p"] * p_cost[i] for (i, zone) in _GM.ref(gm, n, :price_zone))
    )
end

"Objective for minimizing the costs of expansions.  Formally stated as
``min \\alpha \\sum_{(i,j) \\in Pipe \\cup Compressors} \\kappa_{ij} z_{ij} + \\beta \\sum_{(i,j) \\in Branches} \\kappa_{ij} z_{ij} ``
where ``\\alpha`` and ``\\beta`` are weighting terms"
function objective_min_ne_cost(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel; n::Int=gm.cnw)
    gas_ne_weight = get(pm.data, "gas_ne_weight", 1.0)
    power_ne_weight = get(pm.data, "power_ne_weight", 1.0)

    zc, ne_comps = _GM.var(gm, n, :zc), _GM.ref(gm, n, :ne_compressor)
    c_cost = length(ne_comps) > 0 ? gas_ne_weight *
        sum(comp["construction_cost"] * zc[i] for (i, comp) in ne_comps) : 0.0

    zp, ne_pipes = _GM.var(gm, n, :zp), _GM.ref(gm, n, :ne_pipe)
    p_cost = length(ne_pipes) > 0 ? gas_ne_weight *
        sum(pipe["construction_cost"] * zp[i] for (i, pipe) in ne_pipes) : 0.0

    zb, ne_lines = _PM.var(pm, n, :branch_ne), _PM.ref(pm, n, :ne_branch)
    l_cost = length(ne_lines) > 0 ? power_ne_weight *
        sum(line["construction_cost"] * zb[i] for (i, line) in ne_lines) : 0.0

    obj = JuMP.@objective(gm.model, _IM._MOI.MIN_SENSE, c_cost + p_cost + l_cost)
end
