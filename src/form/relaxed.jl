function constraint_heat_rate(
    gpm::RelaxedGasPowerModel, n::Int, j::Int, generators::Array,
    heat_rates::Dict{Int, Array}, constant::Float64, dispatchable::Int)
    # If flow is not dispatchable, gas will not be consumed by the generator.
    fl = dispatchable == 1 ? _IM.var(gpm, :ng, n, :fl, j) : 0.0

    if length(generators) == 0 && dispatchable == 1
        # If there are no generators to serve, no gas is required.
        c = JuMP.@constraint(gpm.model, fl == 0.0)
        gpm.con[:heat_rate_curve][j] = c # TODO: Use a convenience function.
    elseif length(generators) > 0
        # Get power variables.
        pg = _IM.var(gpm, :ep, n, :pg)

        if any(heat_rates[i][1] != 0.0 for i in generators)
            # If any coefficients for the quadratic term are nonzero, add relaxation.
            sum_1 = sum(heat_rates[i][1] == 0.0 ? 0.0 : heat_rates[i][1]*pg[i]^2 for i in generators)
            sum_2 = sum(heat_rates[i][2]*pg[i] for i in generators)
            sum_3 = sum(heat_rates[i][3] for i in generators)
            c = JuMP.@constraint(gpm.model, fl >= constant * (sum_1 + sum_2 + sum_3))
            gpm.con[:heat_rate_curve][j] = c # TODO: Use a convenience function.
        else
            # If all coefficients for quadratic terms are zero, add linear constraint.
            sum_1 = sum(heat_rates[i][2]*pg[i] for i in generators)
            sum_2 = sum(heat_rates[i][3] for i in generators)
            c = JuMP.@constraint(gpm.model, fl == constant * (sum_1 + sum_2))
            gpm.con[:heat_rate_curve][j] = c # TODO: Use a convenience function.
        end
    end
end
