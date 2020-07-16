""
function resolve_units!(g_data::Dict{String,Any}, p_data::Dict{String,Any})
    g_data["energy_factor"] *= inv(g_data["base_flow"])

    # Convert the heat rate curve from real power units to per unit power units
    # (will result in real gas units).
    for (i, gen) in p_data["gen"]
        gen["heat_rate_quad_coeff"] = gen["heat_rate_quad_coeff"] * p_data["baseMVA"]^2
        gen["heat_rate_linear_coeff"] = gen["heat_rate_linear_coeff"] * p_data["baseMVA"]
    end
end
