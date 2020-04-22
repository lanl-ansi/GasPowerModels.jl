# Define NLP implementations of GasPowerModels.

function constraint_heat_rate_curve(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel, n::Int, j, generators, heat_rates, constant, dispatchable)
    fl = dispatchable == 1 ? gm.var[:nw][n][:fl][j] : 0

    pg = _PM.var(pm, :pg, nw=n)

    if length(generators) == 0
        if dispatchable == 1
            _GM.add_constraint(gm,n,:heat_rate_curve,j, JuMP.@constraint(pm.model, fl == 0.0))
        end

        return
    end

    sum_1 = sum(heat_rates[i][1] == 0.0 ? 0 : heat_rates[i][1]*pg[i]^2 for i in generators)
    sum_2 = sum(heat_rates[i][2]*pg[i] for i in generators)
    sum_3 = sum(heat_rates[i][3] for i in generators)

    c = JuMP.@constraint(gm.model, fl == constant * (sum_1 + sum_2 + sum_3))
    _GM.add_constraint(gm, n, :heat_rate_curve, j, c)
end
