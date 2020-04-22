# Define QP implementations of GasPowerModels.

function constraint_heat_rate_curve(pm::_PM.AbstractPowerModel, gm::_GM.AbstractMISOCPModel, n::Int, j, generators, heat_rates, constant, dispatchable)
    fl = dispatchable == 1 ? gm.var[:nw][n][:fl][j] : 0
    pg = _PM.var(pm, :pg, nw=n)

#    if !haskey(gm.con[:nw][n], :heat_rate_curve)
#        gm.con[:nw][n][:heat_rate_curve] = Dict{Int,ConstraintRef}()
#    end

    if length(generators) == 0
        if dispatchable == 1
            c = JuMP.@constraint(pm.model, fl == 0.0)
            _GM._add_constraint!(gm, n, :heat_rate_curve, j, c)
#        gm.con[:nw][n][:heat_rate_curve][j] = @constraint(gm.model, fl == 0.0)
        end
        return
    end

    is_linear = true;

    for i in generators
        if heat_rates[i][1] != 0
            is_linear = false
        end
    end

    if is_linear
        sum_1 = sum(heat_rates[i][2]*pg[i] for i in generators)
        sum_2 = sum(heat_rates[i][3] for i in generators)
        c = JuMP.@constraint(gm.model, fl == constant * (sum_1 + sum_2))
        _GM._add_constraint!(gm, n, :heat_rate_curve, j, c)
#        gm.con[:nw][n][:heat_rate_curve][j] = @constraint(gm.model, fl == constant * (sum(heat_rates[i][2]*pg[i] for i in generators) + sum(heat_rates[i][3] for i in generators)))
    else
        sum_1 = sum(heat_rates[i][1] == 0.0 ? 0.0 : heat_rates[i][1]*pg[i]^2 for i in generators)
        sum_2 = sum(heat_rates[i][2]*pg[i] for i in generators)
        sum_3 = sum(heat_rates[i][3] for i in generators)
        c = JuMP.@constraint(gm.model, fl >= constant * (sum_1 + sum_2 + sum_3))
        _GM._add_constraint!(gm, n, :heat_rate_curve, j, c)
#        gm.con[:nw][n][:heat_rate_curve][j] = @constraint(gm.model, fl >= constant * (sum(heat_rates[i][1] == 0.0 ? 0 : heat_rates[i][1]*pg[i]^2 for i in generators) + sum(heat_rates[i][2]*pg[i] for i in generators) + sum(heat_rates[i][3] for i in generators)))
    end
end
