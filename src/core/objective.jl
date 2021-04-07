##########################################################################
# This file defines objectives used in gas-power problem specifications. #
##########################################################################

"Helper function for expressing compressor costs."
function objective_expression_ne_compressor_cost(gpm::AbstractGasPowerModel; n::Int = nw_id_default)
    zc = _IM.var(gpm, _GM.gm_it_sym, n, :zc)
    ne_comps = _IM.ref(gpm, _GM.gm_it_sym, n, :ne_compressor)

    if length(ne_comps) > 0
        return sum(x["construction_cost"] * zc[i] for (i, x) in ne_comps)
    else
        return 0.0
    end
end


"Helper function for expressing pipe costs."
function objective_expression_ne_pipe_cost(gpm::AbstractGasPowerModel; n::Int = nw_id_default)
    zp = _IM.var(gpm, _GM.gm_it_sym, n, :zp)
    ne_pipes = _IM.ref(gpm, _GM.gm_it_sym, n, :ne_pipe)

    if length(ne_pipes) > 0
        return sum(x["construction_cost"] * zp[i] for (i, x) in ne_pipes)
    else
        return 0.0
    end
end


"Helper function for expressing line costs."
function objective_expression_ne_line_cost(gpm::AbstractGasPowerModel; n::Int = nw_id_default)
    zb = _IM.var(gpm, _PM.pm_it_sym, n, :branch_ne)
    ne_lines = _IM.ref(gpm, _PM.pm_it_sym, n, :ne_branch)

    if length(ne_lines) > 0
        return sum(x["construction_cost"] * zb[i] for (i, x) in ne_lines)
    else
        return 0.0
    end
end


"Helper function for expressing zonal prices."
function objective_expression_zone_price(gpm::AbstractGasPowerModel; n::Int = nw_id_default)
    zone_cost = _IM.var(gpm, _GM.gm_it_sym, n, :zone_cost)
    zones = _IM.ref(gpm, _GM.gm_it_sym, n, :price_zone)

    if length(zones) > 0
        return sum(zone_cost[i] for (i, x) in zones)
    else
        return 0.0
    end
end


"Helper function for expressing zonal pressure penalty prices."
function objective_expression_pressure_penalty(gpm::AbstractGasPowerModel; n::Int = nw_id_default)
    p_cost = _IM.var(gpm, _GM.gm_it_sym, n, :p_cost)
    zones = _IM.ref(gpm, _GM.gm_it_sym, n, :price_zone)

    if length(zones) > 0
        return sum(x["constant_p"] * p_cost[i] for (i, x) in zones)
    else
        return 0.0
    end
end


"Helper function for constructing the expression associated with the OPF objective."
function objective_expression_opf_cost(gpm::AbstractGasPowerModel; n::Int = nw_id_default)
    gen_cost = Dict{Tuple{Int, Int}, Any}()

    for (i, gen) in _IM.ref(gpm, _PM.pm_it_sym, n, :gen)
        conductor_ids = _PM.conductor_ids(_get_powermodel_from_gaspowermodel(gpm), n)
        pg = sum(_IM.var(gpm, _PM.pm_it_sym, n, :pg, i)[c] for c in conductor_ids)

        if length(gen["cost"]) == 1
            gen_cost[(n, i)] = gen["cost"][1]
        elseif length(gen["cost"]) == 2
            gen_cost[(n, i)] = gen["cost"][1] * pg + gen["cost"][2]
        elseif length(gen["cost"]) == 3
            gen_cost[(n, i)] = gen["cost"][1] * pg^2 + gen["cost"][2] * pg + gen["cost"][3]
        else
            gen_cost[(n, i)] = 0.0
        end
    end

    return sum(gen_cost[(n, i)] for (i, gen) in _IM.ref(gpm, _PM.pm_it_sym, n, :gen))
end


"""
Objective function for minimizing the gas-grid optimal flow as defined in reference
Russell Bent, Seth Blumsack, Pascal Van Hentenryck, Conrado Borraz-Sánchez, Mehdi
Shahriari. Joint Electricity and Natural Gas Transmission Planning With Endogenous Market
Feedbacks. IEEE Transactions on Power Systems. 33 (6): 6397-6409, 2018. More formally,
this objective is stated as
```math
\\min \\lambda \\sum_{g \\in G} (c^1_g pg_g^2 + c^2_g pg_g + c^3_g) +
\\gamma \\sum_{z \\in Z} cost_z + \\gamma \\sum_{z \\in Z} pc_z,
```
where ``\\lambda`` and ``\\gamma`` are weighting terms.
"""
function objective_min_opf_cost(gpm::AbstractGasPowerModel; n::Int = nw_id_default)
    # Get objective weights from power network reference data.
    power_opf_weight = get(gpm.data, "power_opf_weight", 1.0)
    gas_price_weight = get(gpm.data, "gas_price_weight", 1.0)

    # Set the objective using the objective helper functions.
    JuMP.@objective(gpm.model, _IM._MOI.MIN_SENSE,
        power_opf_weight * objective_expression_opf_cost(gpm; n = n) +
        gas_price_weight * objective_expression_zone_price(gpm; n = n) +
        gas_price_weight * objective_expression_pressure_penalty(gpm; n = n))
end


"""
Objective function for minimizing the gas-grid optimal flow combined with network
expansion costs as defined in reference Russell Bent, Seth Blumsack, Pascal Van
Hentenryck, Conrado Borraz-Sánchez, Mehdi Shahriari. Joint Electricity and Natural Gas
Transmission Planning With Endogenous Market Feedbacks. IEEE Transactions on Power
Systems. 33 (6): 6397-6409, 2018. More formally, this objective is stated as
```math
\\min \\alpha \\sum_{(i,j) \\in Pipe \\cup Compressors} \\kappa_{ij} z_{ij} +
\\beta \\sum_{(i,j) \\in Branches} \\kappa_{ij} z_{ij} +
\\lambda \\sum_{g \\in G} (c^1_g pg_g^2 + c^2_g pg_g + c^3_g) +
\\gamma \\sum_{z \\in Z} cost_z + \\gamma \\sum_{z \\in Z} pc_z,
```
where ``\\lambda, \\alpha, \\beta`` and ``\\gamma`` are weighting terms.
"""
function objective_min_ne_opf_cost(gpm::AbstractGasPowerModel; n::Int = nw_id_default)
    gas_ne_weight = get(gpm.data, "gas_ne_weight", 1.0)
    power_ne_weight = get(gpm.data, "power_ne_weight", 1.0)
    power_opf_weight = get(gpm.data, "power_opf_weight", 1.0)
    gas_price_weight = get(gpm.data, "gas_price_weight", 1.0)

    return JuMP.@objective(gpm.model, _IM._MOI.MIN_SENSE,
        gas_ne_weight * objective_expression_ne_pipe_cost(gpm; n = n) +
        gas_ne_weight * objective_expression_ne_compressor_cost(gpm; n = n) +
        power_ne_weight * objective_expression_ne_line_cost(gpm; n = n) +
        power_opf_weight * objective_expression_opf_cost(gpm; n = n) +
        gas_price_weight * objective_expression_zone_price(gpm; n = n) +
        gas_price_weight * objective_expression_pressure_penalty(gpm; n = n))
end


"""
Objective for minimizing the costs of expansion. Formally stated as
```math
\\min \\alpha \\sum_{(i,j) \\in Pipe \\cup Compressors} \\kappa_{ij} z_{ij} +
\\beta \\sum_{(i,j) \\in Branches} \\kappa_{ij} z_{ij},
```
where ``\\alpha`` and ``\\beta`` are weighting terms.
"""
function objective_min_ne_cost(gpm::AbstractGasPowerModel; n::Int = nw_id_default)
    gas_ne_weight = get(gpm.data, "gas_ne_weight", 1.0)
    power_ne_weight = get(gpm.data, "power_ne_weight", 1.0)

    return JuMP.@objective(gpm.model, _IM._MOI.MIN_SENSE,
        gas_ne_weight * objective_expression_ne_compressor_cost(gpm; n = n) +
        gas_ne_weight * objective_expression_ne_pipe_cost(gpm; n = n) +
        power_ne_weight * objective_expression_ne_line_cost(gpm; n = n))
end


"""
Maximizes the normalized sum of nongeneration gas load delivered in the joint network, i.e.,
```math
\\max \\eta_{G}(d) := \\left(\\sum_{i \\in \\mathcal{D}^{\\prime}} \\beta_{i} d_{i}\\right)
\\left(\\sum_{i \\in \\mathcal{D}^{\\prime}} \\beta_{i} \\overline{d}_{i}\\right)^{-1},
```
where ``\\mathcal{D}^{\\prime}`` is the set the delivery points in the gas network with
dispatchable demand that are _not_ connected to interdependent generators in the power network,
``\\beta_{i} \\in \\mathbb{R}_{+}`` (equal to the `priority` property of the `delivery`)
is a predefined restoration priority for delivery
``i \\in \\mathcal{D}^{\\prime}``, ``d_{i}`` is the mass flow of gas delivered at
``i \\in \\mathcal{D}^{\\prime}``, and ``\\overline{d}_{i}`` is the maximum deliverable gas
load at ``i \\in \\mathcal{D}^{\\prime}``.
"""
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


"""
Maximizes the normalized sum of active power load delivered in the joint network, i.e.,
```math
\\max \\eta_{P}(z^{d}) := \\left(\\sum_{i \\in \\mathcal{L}} \\beta_{i} z_{i}^{d} \\Re({S}_{i}^{d})\\right)
\\left(\\sum_{i \\in \\mathcal{L}} \\beta_{i} \\Re({S}_{i}^{d})\\right)^{-1}.
```
Here, ``\\mathcal{L}`` is the set of loads in the power network,
``\\beta_{i} \\in \\mathbb{R}_{+}`` (equal to the `weight` property of the `load`)
is the load restoration priority for load
``i \\in \\mathcal{L}``, and ``z_{i} \\in [0, 1]`` is a variable that scales the maximum
amount of active power load, ``\\Re({S}_{i}^{d})``, at load ``i \\in \\mathcal{L}``.
"""
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


"""
Maximizes the weighted normalized sums of nongeneration gas load and active power load
delivered in the joint network, i.e.,
```math
    \\max \\lambda_{G} \\eta_{G}(d) + \\lambda_{P} \\eta_{P}(z^{d}),
```
where it is recommended that ``0 < \\lambda_{G} < 1``, that `gm_load_priority` in the
network data specification be set to the value of ``\\lambda_{G}`` desired, and that
`pm_load_priority` similarly be set to the value ``1 - \\lambda_{G} = \\lambda_{P}``.
This type of parameterization allows for a straightforward analysis of gas-power
tradeoffs, as the objective is naturally scaled between zero and one.
"""
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
