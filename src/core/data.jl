"Resolve the units for energy used throughout the disparate datasets."
function resolve_units!(data::Dict{String, Any}, gas_is_per_unit::Bool)
    delivery_gens = data["component_link"]["delivery_gen"]
    g_data, p_data = data["it"]["ng"], data["it"]["ep"]

    for link in filter(x -> haskey(x, "heat_rate_curve_coefficients"), delivery_gens)
        c = link["heat_rate_curve_coefficients"]
        c[1], c[2] = c[1] * p_data["baseMVA"]^2, c[2] * p_data["baseMVA"]
        link["heat_rate_curve_coefficients"] = c
    end

    # Convert the heat rate curve from real power units to per unit power units.
    for (i, gen) in p_data["gen"]
        gen["heat_rate_quad_coeff"] = gen["heat_rate_quad_coeff"] * p_data["baseMVA"]^2
        gen["heat_rate_linear_coeff"] = gen["heat_rate_linear_coeff"] * p_data["baseMVA"]
    end

    # Scale the energy factor in gas data by base flow.
    g_data["energy_factor"] *= gas_is_per_unit ? 1.0 : inv(g_data["base_flow"])
end

function correct_network_data!(data::Dict{String, Any})
    # Run the data correction routines for each infrastructure.
    _GM.correct_network_data!(data)
    _PM.correct_network_data!(data)
end
