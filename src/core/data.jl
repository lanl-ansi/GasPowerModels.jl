# TODO These values should be stored in ref...
" Assign generator numbers to the junctions for easy access "
function add_junction_generators(pm::GenericPowerModel, gm::GenericGasModel)
    for k in keys(gm.ref[:nw])
        # create a gens field
        for (j, consumer) in GasModels.ref(gm, k, :consumer)
            consumer["gens"] = []
        end

        # assumes that network numbers are linked between power and gas...
        for (i, gen) in PowerModels.ref(pm, k, :gen)
            if haskey(gen, "consumer") && haskey(GasModels.ref(gm, k, :consumer), gen["consumer"])
                consumer = gen["consumer"]
                push!(GasModels.ref(gm, k, :consumer, consumer)["gens"], i)
            end
        end
    end
end

""
function gas_grid_per_unit(gas_data::Dict{String,Any}, power_data::Dict{String,Any})
    q_base = gas_data["baseQ"]
    p_base = gas_data["baseP"]
    mvaBase = power_data["baseMVA"]

    rescale_q      = x -> x/q_base
    rescale_p      = x -> x/p_base

    if haskey(gas_data, "price_zone")
        for (i, zone) in gas_data["price_zone"]
            zone["cost_p"][1] = zone["cost_p"][1] * p_base^4
            zone["cost_p"][2] = zone["cost_p"][2] * p_base^2

            zone["cost_q"][1] = zone["cost_q"][1] * q_base^2
            zone["cost_q"][2] = zone["cost_q"][2] * q_base

            zone["min_cost"] = zone["min_cost"] * q_base

        end
    end

    gas_data["energy_factor"] = gas_data["energy_factor"] / q_base

    # convert the heat rate curve from real power units to per unit power units (will result in
    # real gas units)
    for (i, gen) in power_data["gen"]
        gen["heat_rate_quad_coeff"] = gen["heat_rate_quad_coeff"] * mvaBase^2
        gen["heat_rate_linear_coeff"] = gen["heat_rate_linear_coeff"] * mvaBase
    end
end
