# GasPowerModels exports everything except internal symbols, which are defined as those
# whose name starts with an underscore. If you don't want all of these symbols in your
# environment, then use `import GasPowerModels` instead of `using GasPowerModels`.

# Do not add GasPowerModels-defined symbols to this exclude list. Instead, rename them with
# an underscore.

const _EXCLUDE_SYMBOLS = [Symbol(@__MODULE__), :eval, :include]

for sym in names(@__MODULE__, all=true)
    sym_string = string(sym)

    if sym in _EXCLUDE_SYMBOLS || startswith(sym_string, "_") || startswith(sym_string, "@_")
        continue
    end

    if !(Base.isidentifier(sym) || (startswith(sym_string, "@") &&
         Base.isidentifier(sym_string[2:end])))
       continue
    end

    @eval export $sym
end

# The following items are also exported for user friendliness when calling `using
# GasPowerModels` so that users do not need to import JuMP to use a solver.
import JuMP: optimizer_with_attributes
export optimizer_with_attributes

import JuMP: TerminationStatusCode
export TerminationStatusCode

import JuMP: ResultStatusCode
export ResultStatusCode

for status_code_enum in [TerminationStatusCode, ResultStatusCode]
    for status_code in instances(status_code_enum)
        @eval import JuMP: $(Symbol(status_code))
        @eval export $(Symbol(status_code))
    end
end

# Export PowerModels modeling types for ease of use.
gas_models = names(_GM)
gas_models = filter(x -> endswith(string(x), "GasModel"), gas_models)
gas_models = filter(x -> !occursin("Abstract", string(x)), gas_models)

for x in gas_models
    @eval import GasPowerModels._GM: $(x)
    @eval export $(x)
end

# Export PowerModels modeling types for ease of use.
power_models = names(_PM)
power_models = filter(x -> endswith(string(x), "PowerModel"), power_models)
power_models = filter(x -> !occursin("Abstract", string(x)), power_models)

for x in power_models
    @eval import GasPowerModels._PM: $(x)
    @eval export $(x)
end

# Export PowerModelsRestoration modeling types for ease of use.
power_models = names(_PMR)
power_models = filter(x -> endswith(string(x), "PowerModel"), power_models)
power_models = filter(x -> !occursin("Abstract", string(x)), power_models)

for x in power_models
    @eval import GasPowerModels._PMR: $(x)
    @eval export $(x)
end

# Export from InfrastructureModels.
export ids, ref, var, con, sol, nw_ids, nws, optimize_model!
