"Resolve the units for energy used throughout power datasets that connect to gas modeling"
function resolve_pm_units!(p_data::Dict{String,Any})
    # Convert the heat rate curve from real power units to per unit power units.
    for (i, gen) in p_data["gen"]
        gen["heat_rate_quad_coeff"] = gen["heat_rate_quad_coeff"] * p_data["baseMVA"]^2
        gen["heat_rate_linear_coeff"] = gen["heat_rate_linear_coeff"] * p_data["baseMVA"]
    end
end


"Resolve the units for energy used throughout the gas datasets that connect to power modeling"
function resolve_gm_units!(g_data::Dict{String,Any})
    # Scale the energy factor in gas data by base flow.
    g_data["energy_factor"] *= inv(g_data["base_flow"])

    if haskey(g_data, "price_zone")
        for (i, zone) in g_data["price_zone"]
            zone["cost_q_1"] = zone["cost_q_1"] * _GM.get_base_flow(g_data)^2
            zone["cost_q_2"] = zone["cost_q_2"] * _GM.get_base_flow(g_data)
            zone["min_cost"] = zone["min_cost"] * _GM.get_base_flow(g_data)
            zone["cost_p_1"] = zone["cost_p_1"] * _GM.get_base_pressure(g_data)^4 # pressure is modeled in the space of pressure squared
            zone["cost_p_2"] = zone["cost_p_2"] * _GM.get_base_pressure(g_data)^2 # pressure is modeled in the space of pressure squared
        end
    end
end
