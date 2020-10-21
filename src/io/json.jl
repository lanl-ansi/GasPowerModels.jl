"""
    parse_json(path)

Parses a JavaScript Object Notation (JSON) file from the file path `path` and returns a
GasPowerModels data structure that links gas and power networks (a dictionary of data).
"""
function parse_json(path::String)
    return JSON.parsefile(path)
end
