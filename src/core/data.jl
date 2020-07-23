"Resolve the units for energy used throughout the gas and power datasets."
function resolve_units!(g_data::Dict{String,Any}, p_data::Dict{String,Any})
    # Scale the energy factor in gas data by base flow.
    g_data["energy_factor"] *= inv(g_data["base_flow"])

    # Convert the heat rate curve from real power units to per unit power units.
    for (i, gen) in p_data["gen"]
        gen["heat_rate_quad_coeff"] = gen["heat_rate_quad_coeff"] * p_data["baseMVA"]^2
        gen["heat_rate_linear_coeff"] = gen["heat_rate_linear_coeff"] * p_data["baseMVA"]
    end
end
