""
function solution_preprocessor(gpm::AbstractGasPowerModel, solution::Dict)
    # Preprocess gas-only solution data.
    _IM.solution_preprocessor(_get_gasmodel_from_gaspowermodel(gpm), solution)

    # Preprocess power-only solution data.
    _IM.solution_preprocessor(_get_powermodel_from_gaspowermodel(gpm), solution)
end
