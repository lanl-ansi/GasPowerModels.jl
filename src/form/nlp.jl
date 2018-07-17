# Define NLP implementations of Gas Grid Models 

function constraint_heat_rate_curve{P,G <:GasModels.AbstractMINLPForms}(pm::GenericPowerModel{P}, gm::GenericGasModel{G}, n::Int, j, generators, heat_rates, constant, qlmin, qlmax)
    ql = consumer["qlmin"] != 0 || consumer["qlmax"] != 0 ? gm.var[:nw][n][:ql][j] : 0
    pg = var(pm, :pg, nw=n)

    if !haskey(gm.con[:nw][n], :heat_rate_curve)
        gm.con[:nw][n][:heat_rate_curve] = Dict{Int,ConstraintRef}()
    end

    if length(generators) == 0
        if ql != 0
            gm.con[:nw][n][:heat_rate_curve][j] = @constraint(pm.model, ql == 0.0)
        end
        return
    end

    gm.con[:nw][n][:heat_rate_curve][j] = @constraint(gm.model, ql == constant * sum( heat_rates[i][1] == 0.0 ? 0 : heat_rates[i][1]*pg[i]^2 for i in generators) + sum( heat_rates[i][2]*pg[i] for i in generators) + sum( heat_rates[i][3] for i in generators))
end


