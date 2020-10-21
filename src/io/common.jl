"""
    parse_file(path)

Parses a linking file from the file path `path`, depending on the file extension, and
returns a GasPowerModels data structure that links gas and power networks (a dictionary).
"""
function parse_file(path::String)
    if endswith(path, ".json")
        data = parse_json(path)
    else
        error("\"$(path)\" is not a valid file type.")
    end

    return data
end
