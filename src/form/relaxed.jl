function constraint_heat_rate(
    gpm::RelaxedGasPowerModel, n::Int, delivery_gen_index::Int, delivery_index::Int,
    generator_index::Int, heat_rate_curve::Array, constant::Float64, dispatchable::Int)
    # If flow is not dispatchable, gas will not be consumed by the generator.
    fl = dispatchable == 1 ? _IM.var(gpm, _GM.gm_it_sym, n, :fl, delivery_index) : 0.0

    # Get power variables.
    pg = _IM.var(gpm, _PM.pm_it_sym, n, :pg, generator_index)

    if heat_rate_curve[1] != 0.0
        # If any coefficients for the quadratic term are nonzero, add relaxation.
        term_1 = heat_rate_curve[1] * pg^2
        term_2 = heat_rate_curve[2] * pg
        term_3 = heat_rate_curve[3]
        c = JuMP.@constraint(gpm.model, fl >= constant * (term_1 + term_2 + term_3))
        _IM.con(gpm, :dep, n, :heat_rate)[delivery_gen_index] = c
    else
        # If all coefficients for quadratic terms are zero, add linear constraint.
        term_1 = heat_rate_curve[2] * pg
        term_2 = heat_rate_curve[3]
        c = JuMP.@constraint(gpm.model, fl == constant * (term_1 + term_2))
        _IM.con(gpm, :dep, n, :heat_rate)[delivery_gen_index] = c
    end
end
