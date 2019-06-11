################################################################################
# This file is to defines commonly used constraints for gas grid models
################################################################################

" function for congestion costs based on demand "
# This is equation 27 in the HICCS paper
function objective_min_ne_opf_cost(pm::GenericPowerModel,gm::GenericGasModel, n::Int=gm.cnw; normalization = 1.0, gas_ne_weight = 1.0, power_ne_weight = 1.0, power_opf_weight = 1.0, gas_price_weight = 1.0)
    zp = GasModels.var(gm,n,:zp)
    zc = GasModels.var(gm,n,:zc)

    line_ne = var(pm, :branch_ne, nw=n)
    branches = ref(pm, :ne_branch, nw=n)

    pg = var(pm, :pg, nw=n)

    # constraint for normalized zone-based demand pricing
    variable_zone_demand(gm)
    variable_zone_demand_price(gm)
    variable_zone_pressure(gm)
    variable_pressure_price(gm)

    zone_cost = GasModels.var(gm,n,:zone_cost)
    p_cost = GasModels.var(gm,n,:p_cost)

    for (i, price_zone) in GasModels.ref(gm,n,:price_zone)
        constraint_zone_demand(gm, i)
        constraint_zone_demand_price(gm, i)
        constraint_zone_pressure(gm, i)
        constraint_pressure_price(gm, i)
    end

    gen_cost = Dict()
    for (i,gen) in PowerModels.ref(pm, :gen, nw=n)
        pg = sum( var(pm, n, c, :pg, i) for c in conductor_ids(pm, n) )

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


    obj = @objective(gm.model, Min,
      gas_ne_weight * normalization    * sum(pipe["construction_cost"] * zp[i] for (i,pipe) in GasModels.ref(gm,n,:ne_pipe)) +
      gas_ne_weight * normalization    * sum(compressor["construction_cost"] * zc[i] for (i,compressor) in GasModels.ref(gm,n,:ne_compressor)) +
      power_ne_weight * normalization  * sum(branches[i]["construction_cost"]*line_ne[i] for (i,branch) in branches) +
      power_opf_weight * normalization * sum(gen_cost[(n,i)] for (i,gen) in PowerModels.ref(pm, :gen, nw=n)) +
      gas_price_weight * normalization * sum(zone_cost[i] for (i,zone) in GasModels.ref(gm,n,:price_zone)) +
      gas_price_weight * normalization * sum(zone["constant_p"] * p_cost[i] for (i,zone) in GasModels.ref(gm,n,:price_zone))
    )
end

" function for expansion costs only "
# This is the objective function for the expansion only results in the HICCS paper
function objective_min_ne_cost(pm::GenericPowerModel,gm::GenericGasModel,n::Int=gm.cnw; gas_ne_weight = 1.0, power_ne_weight = 1.0, normalization = 1.0)
    zp = GasModels.var(gm,n,:zp)
    zc = GasModels.var(gm,n,:zc)

    line_ne = var(pm, :branch_ne, nw=n)
    branches = ref(pm, :ne_branch, nw=n)

    obj = @objective(gm.model, Min,
      gas_ne_weight      * normalization * sum(pipe["construction_cost"] * zp[i] for (i,pipe) in GasModels.ref(gm,n,:ne_pipe))
      + gas_ne_weight    * normalization * sum(compressor["construction_cost"] * zc[i] for (i,compressor) in GasModels.ref(gm,n,:ne_compressor))
      + power_ne_weight  * normalization * sum(branches[i]["construction_cost"]*line_ne[i] for (i,branch) in branches)
    )
end
