# Define QP implementation of Gas Grid Models

###################### Variables ####################################


###################### Constraints ####################################

function constraint_heat_rate_curve(pm::GenericPowerModel, gm::GenericGasModel{G}, n::Int, j, generators, heat_rates, constant, flmin, flmax) where G <: GasModels.AbstractMISOCPForm
    fl = flmin != 0 || flmax != 0 ? gm.var[:nw][n][:fl][j] : 0
    pg = var(pm, :pg, nw=n)

    if !haskey(gm.con[:nw][n], :heat_rate_curve)
        gm.con[:nw][n][:heat_rate_curve] = Dict{Int,ConstraintRef}()
    end

    if length(generators) == 0
        if fl != 0
            gm.con[:nw][n][:heat_rate_curve][j] = @constraint(gm.model, fl == 0.0)
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
        gm.con[:nw][n][:heat_rate_curve][j] = @constraint(gm.model, fl == constant * (sum( heat_rates[i][2]*pg[i] for i in generators) + sum( heat_rates[i][3] for i in generators)))
    else
        gm.con[:nw][n][:heat_rate_curve][j] = @constraint(gm.model, fl >= constant * (sum( heat_rates[i][1] == 0.0 ? 0 : heat_rates[i][1]*pg[i]^2 for i in generators) + sum( heat_rates[i][2]*pg[i] for i in generators) + sum( heat_rates[i][3] for i in generators)))
    end
end
