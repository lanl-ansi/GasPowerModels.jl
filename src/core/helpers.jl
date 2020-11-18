function _get_gasmodel_from_gaspowermodel(gpm::AbstractGasPowerModel)
    # Determine the GasModels modeling type.
    gm_type = typeof(gpm).parameters[1]

    # Gas-only variables and constraints.
    return gm_type(gpm.model, gpm.data, gpm.setting, gpm.solution, gpm.ref,
        gpm.var, gpm.con, gpm.sol, gpm.sol_proc, gpm.cnw, gpm.ext)
end


function _get_powermodel_from_gaspowermodel(gpm::AbstractGasPowerModel)
    # Determine the PowerModels modeling type.
    pm_type = typeof(gpm).parameters[2]

    # Power-only variables and constraints.
    return pm_type(gpm.model, gpm.data, gpm.setting, gpm.solution, gpm.ref,
        gpm.var, gpm.con, gpm.sol, gpm.sol_proc, gpm.cnw, gpm.ext)
end
