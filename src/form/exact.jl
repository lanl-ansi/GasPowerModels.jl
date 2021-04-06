function constraint_heat_rate_exact(
    gpm::AbstractGasPowerModel, n::Int, delivery_index::Int,
    generator_indices::Array{Int, 1}, heat_rate_curves::Vector{Vector{Any}},
    constant::Float64, dispatchable::Int)
    # If flow is not dispatchable, gas will not be consumed by the generator.
    fl = dispatchable == 1 ? _IM.var(gpm, _GM.gm_it_sym, n, :fl, delivery_index) : 0.0

    if length(generator_indices) == 0 && dispatchable == 1
        # If there are no generators to serve, no gas is required.
        c = JuMP.@constraint(gpm.model, fl == 0.0)
        _IM.con(gpm, :dep, n, :heat_rate)[delivery_index] = c
    elseif length(generator_indices) > 0
        # Get power variables.
        pg = _IM.var(gpm, _PM.pm_it_sym, n, :pg)

        if any(heat_rate_curves[i][1] != 0.0 for i in 1:length(generator_indices))
            # If any coefficients for the quadratic term are nonzero, add relaxation.
            sum_1 = sum(heat_rate_curves[i][1] == 0.0 ? 0.0 :
                heat_rate_curves[i][1] * pg[generator_indices[i]]^2
                for i in 1:length(generator_indices))

            sum_2 = sum(heat_rate_curves[i][2] * pg[generator_indices[i]]
                for i in 1:length(generator_indices))

            sum_3 = sum(heat_rate_curves[i][3] for i in 1:length(generator_indices))

            c = JuMP.@constraint(gpm.model, fl == constant * (sum_1 + sum_2 + sum_3))
            _IM.con(gpm, :dep, n, :heat_rate)[delivery_index] = c
        else
            # If all coefficients for quadratic terms are zero, add linear constraint.
            sum_1 = sum(heat_rate_curves[i][2] * pg[generator_indices[i]]
                for i in 1:length(generator_indices))

            sum_2 = sum(heat_rate_curves[i][3] for i in 1:length(generator_indices))

            c = JuMP.@constraint(gpm.model, fl == constant * (sum_1 + sum_2))
            _IM.con(gpm, :dep, n, :heat_rate)[delivery_index] = c
        end
    end
end


function constraint_heat_rate_exact_on_off(
    gpm::AbstractGasPowerModel, n::Int, delivery_index::Int,
    generator_indices::Array{Int, 1}, heat_rate_curves::Vector{Vector{Any}},
    constant::Float64, dispatchable::Int)
    # If flow is not dispatchable, gas will not be consumed by the generator.
    fl = dispatchable == 1 ? _IM.var(gpm, _GM.gm_it_sym, n, :fl, delivery_index) : 0.0

    if length(generator_indices) == 0 && dispatchable == 1
        # If there are no generators to serve, no gas is required.
        c = JuMP.@constraint(gpm.model, fl == 0.0)
        _IM.con(gpm, :dep, n, :heat_rate)[delivery_index] = c
    elseif length(generator_indices) > 0
        # Get power variables.
        pg = _IM.var(gpm, _PM.pm_it_sym, n, :pg)
        z_gen = _IM.var(gpm, _PM.pm_it_sym, n, :z_gen)

        if any(heat_rate_curves[i][1] != 0.0 for i in 1:length(generator_indices))
            # If any coefficients for the quadratic term are nonzero, add relaxation.
            sum_1 = sum(heat_rate_curves[i][1] == 0.0 ? 0.0 :
                heat_rate_curves[i][1] * pg[generator_indices[i]]^2
                for i in 1:length(generator_indices))

            sum_2 = sum(heat_rate_curves[i][2] * pg[generator_indices[i]]
                for i in 1:length(generator_indices))

            sum_3 = sum(heat_rate_curves[i][3] * z_gen[generator_indices[i]]
                for i in 1:length(generator_indices))

            c = JuMP.@constraint(gpm.model, fl == constant * (sum_1 + sum_2 + sum_3))
            _IM.con(gpm, :dep, n, :heat_rate)[delivery_index] = c
        else
            # If all coefficients for quadratic terms are zero, add linear constraint.
            sum_1 = sum(heat_rate_curves[i][2] * pg[generator_indices[i]]
                for i in 1:length(generator_indices))

            sum_2 = sum(heat_rate_curves[i][3] * z_gen[generator_indices[i]]
                for i in 1:length(generator_indices))

            c = JuMP.@constraint(gpm.model, fl == constant * (sum_1 + sum_2))
            _IM.con(gpm, :dep, n, :heat_rate)[delivery_index] = c
        end
    end
end