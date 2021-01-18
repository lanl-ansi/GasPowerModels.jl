"""
    parse_link_file(path)

Parses a linking file from the file path `path`, depending on the file extension, and
returns a GasPowerModels data structure that links gas and power networks (a dictionary).
"""
function parse_link_file(path::String)
    if endswith(path, ".json")
        data = parse_json(path)
    else
        error("\"$(path)\" is not a valid file type.")
    end

    if !haskey(data, "multiinfrastructure")
        data["multiinfrastructure"] = true
    end

    return data
end


function parse_gas_file(file_path::String; skip_correct::Bool = true)
    data = _GM.parse_file(file_path; skip_correct = skip_correct)
    return _IM.ismultiinfrastructure(data) ? data : Dict("multiinfrastructure" => true, "it" => Dict(_GM.gm_it_name => data))
end


function parse_power_file(file_path::String; skip_correct::Bool = true)
    data = _PM.parse_file(file_path; validate = !skip_correct)
    return _IM.ismultiinfrastructure(data) ? data : Dict("multiinfrastructure" => true, "it" => Dict(_PM.pm_it_name => data))
end


function parse_files(gas_path::String, power_path::String, link_path::String)
    joint_network_data = parse_link_file(link_path)
    _IM.update_data!(joint_network_data, parse_gas_file(gas_path))
    _IM.update_data!(joint_network_data, parse_power_file(power_path))

    # Store whether or not each network uses per-unit data.
    g_per_unit = get(joint_network_data["it"][_GM.gm_it_name], "is_per_unit", 0) != 0
    p_per_unit = get(joint_network_data["it"][_PM.pm_it_name], "per_unit", false)

    # Correct the network data.
    correct_network_data!(joint_network_data)

    # Ensure all datasets use the same units for power.
    resolve_units!(joint_network_data, g_per_unit, p_per_unit)

    # Return the network dictionary.
    return joint_network_data
end
