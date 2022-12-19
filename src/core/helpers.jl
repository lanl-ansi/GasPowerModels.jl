function _get_gasmodel_from_gaspowermodel(gpm::AbstractGasPowerModel{GMT,PMT}) where {GMT,PMT}
    # Gas-only variables and constraints.
    return GMT(gpm.model, gpm.data, gpm.setting, gpm.solution,
        gpm.ref, gpm.var, gpm.con, gpm.sol, gpm.sol_proc, gpm.ext)
end


function _get_powermodel_from_gaspowermodel(gpm::AbstractGasPowerModel{GMT,PMT}) where {GMT,PMT}
    # Power-only variables and constraints.
    return PMT(gpm.model, gpm.data, gpm.setting, gpm.solution,
        gpm.ref, gpm.var, gpm.con, gpm.sol, gpm.sol_proc, gpm.ext)
end
