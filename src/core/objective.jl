##########################################################################
# This file defines objectives used in gas-power problem specifications. #
##########################################################################

"Helper function for constructing the expression associated with opf cost"
function objective_expression_opf_cost(pm::_PM.AbstractPowerModel; n::Int=gm.cnw)
    gen_cost = Dict{Tuple{Int,Int},Any}()
    seconds_per_hour = 3600.0

    for (i, gen) in _PM.ref(pm, :gen, nw=n)
        pg = sum(_PM.var(pm, n, :pg, i)[c] for c in _PM.conductor_ids(pm, n))

        if length(gen["cost"]) == 1
            gen_cost[(n, i)] = gen["cost"][1] / seconds_per_hour
        elseif length(gen["cost"]) == 2
            gen_cost[(n, i)] = (gen["cost"][1]*pg) / seconds_per_hour + gen["cost"][2] / seconds_per_hour
        elseif length(gen["cost"]) == 3
            gen_cost[(n, i)] = (gen["cost"][1]*pg^2) / seconds_per_hour + (gen["cost"][2]*pg) / seconds_per_hour + gen["cost"][3] / seconds_per_hour
        else
            gen_cost[(n, i)] = 0.0
        end
    end

    return sum(gen_cost[(n, i)] for (i, gen) in _PM.ref(pm, n, :gen))
end


"Objective function for minimizing the gas grid optimal flow as defined in reference
Russell Bent, Seth Blumsack, Pascal Van Hentenryck, Conrado Borraz-Sánchez, Mehdi Shahriari.
Joint Electricity and Natural Gas Transmission Planning With Endogenous Market Feedbacks.
IEEE Transactions on Power Systems. 33 (6):  6397 - 6409, 2018. More formally, this objective
is stated as ``min \\lambda \\sum_{g \\in G} (c^1_g pg_g^2 + c^2_g pg_g + c^3_g) + \\gamma \\sum_{z \\in Z} cost_z + \\gamma \\sum_{z \\in Z} pc_z ``
where ``\\lambda`` and ``\\gamma`` are weighting terms"
function objective_min_opf_cost(gm::_GM.AbstractGasModel, pm::_PM.AbstractPowerModel; n::Int=gm.cnw)

    # Get objective weights from power network reference data.
    power_opf_weight = get(pm.data, "power_opf_weight", 1.0)
    gas_price_weight = get(pm.data, "gas_price_weight", 1.0)

    JuMP.@objective(gm.model, _IM._MOI.MIN_SENSE,
      power_opf_weight * objective_expression_opf_cost(pm; n=n) +
      gas_price_weight * objective_expression_zone_price(gm; n=n) +
      gas_price_weight * objective_expression_pressure_penalty(gm;n=n)
    )
end

"Objective function for minimizing the gas grid optimal flow combined with network expansion costs as defined in reference
Russell Bent, Seth Blumsack, Pascal Van Hentenryck, Conrado Borraz-Sánchez, Mehdi Shahriari.
Joint Electricity and Natural Gas Transmission Planning With Endogenous Market Feedbacks.
IEEE Transactions on Power Systems. 33 (6):  6397 - 6409, 2018. More formally, this objective
is stated as ``min \\alpha \\sum_{(i,j) \\in Pipe \\cup Compressors} \\kappa_{ij} z_{ij} +  \\beta \\sum_{(i,j) \\in Branches} \\kappa_{ij} z_{ij} + \\lambda \\sum_{g \\in G} (c^1_g pg_g^2 + c^2_g pg_g + c^3_g) + \\gamma \\sum_{z \\in Z} cost_z + \\gamma \\sum_{z \\in Z} pc_z ``
where ``\\lambda, \\alpha, \\beta`` and ``\\gamma`` are weighting terms"
function objective_min_ne_opf_cost(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel; n::Int=gm.cnw)
    gas_ne_weight    = get(pm.data, "gas_ne_weight",    1.0)
    power_ne_weight  = get(pm.data, "power_ne_weight",  1.0)
    power_opf_weight = get(pm.data, "power_opf_weight", 1.0)
    gas_price_weight = get(pm.data, "gas_price_weight", 1.0)

    JuMP.@objective(gm.model, _IM._MOI.MIN_SENSE,
        gas_ne_weight    * objective_expression_ne_pipe_cost(gm; n=n) +
      + gas_ne_weight    * objective_expression_ne_compressor_cost(gm; n=n) +
      + power_ne_weight  * objective_expression_ne_line_cost(pm; n=n) +
      + power_opf_weight * objective_expression_opf_cost(pm; n=n) +
      + gas_price_weight * objective_expression_zone_price(gm; n=n) +
      + gas_price_weight * objective_expression_pressure_penalty(gm;n=n)
      )
end

"Objective for minimizing the costs of expansions.  Formally stated as
``min \\alpha \\sum_{(i,j) \\in Pipe \\cup Compressors} \\kappa_{ij} z_{ij} + \\beta \\sum_{(i,j) \\in Branches} \\kappa_{ij} z_{ij} ``
where ``\\alpha`` and ``\\beta`` are weighting terms"
function objective_min_ne_cost(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel; n::Int=gm.cnw)
    gas_ne_weight   = get(pm.data, "gas_ne_weight",   1.0)
    power_ne_weight = get(pm.data, "power_ne_weight", 1.0)

    obj = JuMP.@objective(gm.model, _IM._MOI.MIN_SENSE, gas_ne_weight * objective_expression_ne_compressor_cost(gm; n=n) +
                                                        gas_ne_weight * objective_expression_ne_pipe_cost(gm; n=n) +
                                                        power_ne_weight * objective_expression_ne_line_cost(pm; n=n)
                                                        )
end

"Helper function for expressing compressor costs "
function objective_expression_ne_compressor_cost(gm::_GM.AbstractGasModel; n::Int=gm.cnw)
    zc, ne_comps = _GM.var(gm, n, :zc), _GM.ref(gm, n, :ne_compressor)
    return length(ne_comps) > 0 ? sum(comp["construction_cost"] * zc[i] for (i, comp) in ne_comps) : 0.0
end

"Helper function for expressing pipe costs "
function objective_expression_ne_pipe_cost(gm::_GM.AbstractGasModel; n::Int=gm.cnw)
    zp, ne_pipes = _GM.var(gm, n, :zp), _GM.ref(gm, n, :ne_pipe)
    return length(ne_pipes) > 0 ? sum(pipe["construction_cost"] * zp[i] for (i, pipe) in ne_pipes) : 0.0
end

"Helper function for expressing line costs "
function objective_expression_ne_line_cost(pm::_PM.AbstractPowerModel; n::Int=gm.cnw)
    zb, ne_lines = _PM.var(pm, n, :branch_ne), _PM.ref(pm, n, :ne_branch)
    return length(ne_lines) > 0 ? sum(line["construction_cost"] * zb[i] for (i, line) in ne_lines) : 0.0
end

"Helper function for expressing zone prices "
function objective_expression_zone_price(gm::_GM.AbstractGasModel; n::Int=gm.cnw)
    zone_cost, zones = _GM.var(gm, n, :zone_cost), _GM.ref(gm, n, :price_zone)
    return length(zones) > 0 ? sum(zone_cost[i] for (i, zone) in zones) : 0.0
end

"Helper function for expressing zone prices "
function objective_expression_pressure_penalty(gm::_GM.AbstractGasModel; n::Int=gm.cnw)
    p_cost, zones = _GM.var(gm, n, :p_cost), _GM.ref(gm, n, :price_zone)
    return length(zones) > 0 ? sum(zone["constant_p"] * p_cost[i] for (i, zone) in zones) : 0.0
end
