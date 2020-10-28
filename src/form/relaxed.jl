function constraint_heat_rate_curve(pm::RelaxedPowerModels, gm::RelaxaedGasModels, n::Int, j::Int,
    generators::Array, heat_rates::Dict{Int,Any}, constant::Float64, dispatchable::Int)
    # If flow is not dispatchable, gas will not be consumed by the generator.
    fl = dispatchable == 1 ? _GM.var(gm, n, :fl, j) : 0.0
    seconds_per_hour = 3600.0

    if length(generators) == 0 && dispatchable == 1
        # If there are no generators to serve, no gas is required.
        c = JuMP.@constraint(gm.model, fl == 0.0)
        _GM._add_constraint!(gm, n, :heat_rate_curve, j, c)
    elseif length(generators) > 0
        # Get power variables.
        pg = _PM.var(pm, :pg, nw=n)

        if any(heat_rates[i][1] != 0.0 for i in generators)
            # If any coefficients for the quadratic term are nonzero, add relaxation.
            sum_1 = sum(heat_rates[i][1] == 0.0 ? 0.0 : heat_rates[i][1]*pg[i]^2 for i in generators)
            sum_2 = sum(heat_rates[i][2]*pg[i] for i in generators)
            sum_3 = sum(heat_rates[i][3] for i in generators)
            c = JuMP.@constraint(gm.model, fl >= constant * ((sum_1 + sum_2 + sum_3)/seconds_per_hour))
            _GM._add_constraint!(gm, n, :heat_rate_curve, j, c)
        else
            # If all coefficients for quadratic terms are zero, add linear constraint.
            sum_1 = sum(heat_rates[i][2]*pg[i] for i in generators)
            sum_2 = sum(heat_rates[i][3] for i in generators)
            c = JuMP.@constraint(gm.model, fl == constant * ((sum_1 + sum_2)/seconds_per_hour))
            _GM._add_constraint!(gm, n, :heat_rate_curve, j, c)
        end
    end
end
