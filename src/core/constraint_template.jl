# Constraint Template Definitions
#
# Constraint templates help simplify data wrangling across multiple formulations by
# providing an abstraction layer between network data and network constraint definitions.
# Each constraint template's job is to extract the required parameters from a given network
# data structure and pass the data as named arguments to formulation-specific constraints.
#
# Constraint templates should always be defined over "AbstractGasPowerModel" and should
# never refer to model variables.


"Constraint for coupling the production of power at natural gas generators with the gas
consumption required to produce this power. The full nonconvex constraint is stated as

```math
fl = e * \\rho (h_2 * pg^2 + h_1 * pg + h_0),
```

where ``h`` is a quadratic function used to convert MW (``pg``) into Joules consumed per
second (J/s). ``h`` is in units of (J/MW^2, J/MW, J). This is then converted to mass
flow, ``fl``, (kg/s) of gas consumed to produce this energy. Here, ``e`` is an energy
factor (m^3/J) and ``\\rho`` is standard density (kg/m^3). This constraint can be relaxed
to a convex quadratic of the form

```math
fl \\ge e * \\rho (h_2 * pg^2 + h_1 * pg + h_0).
```"
function constraint_heat_rate(gpm::AbstractGasPowerModel, delivery_id::Int; nw::Int = nw_id_default)
    delivery_gens = _IM.ref(gpm, :dep, nw, :delivery_gen)
    dep_ids = findall(x -> x["delivery"]["id"] == delivery_id, delivery_gens)
    gen_ids = [delivery_gens[i]["gen"]["id"] for i in dep_ids]
    heat_rate_curves = [delivery_gens[i]["heat_rate_curve_coefficients"] for i in dep_ids]
    dispatchable = _IM.ref(gpm, _GM.gm_it_sym, nw, :delivery, delivery_id)["is_dispatchable"]

    # Convert from J/s in per unit to cubic meters per second at standard density in per
    # unit to kilogram per second in per unit.
    if haskey(_IM.ref(gpm, _GM.gm_it_sym, nw), :standard_density)
        standard_density = _IM.ref(gpm, _GM.gm_it_sym, nw, :standard_density)
    else
        standard_density = _GM._estimate_standard_density(gpm.data["it"]["gm"])
    end

    constant = _IM.ref(gpm, _GM.gm_it_sym, nw, :energy_factor) * standard_density

    # Add the heat rate constraint dictionary.
    if !haskey(_IM.con(gpm, :dep, nw), :heat_rate)
        _IM.con(gpm, :dep, nw)[:heat_rate] = Dict{Int, JuMP.ConstraintRef}()
    end

    # Add the heat rate constraint.
    if isa(gpm, RelaxedGasPowerModel)
        constraint_heat_rate_relaxed(
            gpm, nw, delivery_id, gen_ids, heat_rate_curves, constant, dispatchable)
    else
        constraint_heat_rate_exact(
            gpm, nw, delivery_id, gen_ids, heat_rate_curves, constant, dispatchable)
    end
end


"Constraint for coupling the production of power at dispatchable natural gas generators
with the gas consumption required to produce this power. The full nonconvex constraint is
stated as

```math
fl = e * \\rho (h_2 * pg^2 + h_1 * pg + h_0 * z),
```

where ``h`` is a quadratic function used to convert MW (``pg``) into Joules consumed per
second (J/s). ``h`` is in units of (J/MW^2, J/MW, J). This is then converted to mass
flow, ``fl``, (kg/s) of gas consumed to produce this energy. Here, ``e`` is an energy
factor (m^3/J) and ``\\rho`` is standard density (kg/m^3). ``z`` is a discrete variable
indicating the status of the generator. This constraint can be relaxed to a convex
quadratic of the form

```math
fl \\ge e * \\rho (h_2 * pg^2 + h_1 * pg + h_0 * z).
```"
function constraint_heat_rate_on_off(gpm::AbstractGasPowerModel, delivery_id::Int; nw::Int = nw_id_default)
    delivery_gens = _IM.ref(gpm, :dep, nw, :delivery_gen)
    dep_ids = findall(x -> x["delivery"]["id"] == delivery_id, delivery_gens)
    gen_ids = [delivery_gens[i]["gen"]["id"] for i in dep_ids]
    heat_rate_curves = [delivery_gens[i]["heat_rate_curve_coefficients"] for i in dep_ids]
    dispatchable = _IM.ref(gpm, _GM.gm_it_sym, nw, :delivery, delivery_id)["is_dispatchable"]

    # Convert from J/s in per unit to cubic meters per second at standard density in per
    # unit to kilogram per second in per unit.
    if haskey(_IM.ref(gpm, _GM.gm_it_sym, nw), :standard_density)
        standard_density = _IM.ref(gpm, _GM.gm_it_sym, nw, :standard_density)
    else
        standard_density = _GM._estimate_standard_density(gpm.data["it"]["gm"])
    end

    constant = _IM.ref(gpm, _GM.gm_it_sym, nw, :energy_factor) * standard_density

    # Add the heat rate constraint dictionary.
    if !haskey(_IM.con(gpm, :dep, nw), :heat_rate)
        _IM.con(gpm, :dep, nw)[:heat_rate] = Dict{Int, JuMP.ConstraintRef}()
    end

    # Add the heat rate constraint.
    if isa(gpm, RelaxedGasPowerModel)
        constraint_heat_rate_relaxed_on_off(
            gpm, nw, delivery_id, gen_ids, heat_rate_curves, constant, dispatchable)
    else
        constraint_heat_rate_exact_on_off(
            gpm, nw, delivery_id, gen_ids, heat_rate_curves, constant, dispatchable)
    end
end


"Auxiliary constraint that computes the total consumed gas in a zone. This constraint
takes the form of

```math
fl_{z} = \\sum_{k \\in z} fl_k,
```

where ``fl_{z}`` is the total consumed gas in zone ``z`` and ``fl_k`` is gas consumed at
delivery ``k`` in the zone."
function constraint_zone_demand(gpm::AbstractGasPowerModel, i::Int; nw::Int=nw_id_default)
    if !haskey(_IM.con(gpm, _GM.gm_it_sym, nw), :zone_demand)
        _IM.con(gpm, _GM.gm_it_sym, nw)[:zone_demand] = Dict{Int, JuMP.ConstraintRef}()
    end

    junctions = _IM.ref(gpm, _GM.gm_it_sym, nw, :junction)
    junction_ids = keys(filter(x -> x.second["price_zone"] == i, junctions))
    deliveries = _IM.ref(gpm, _GM.gm_it_sym, nw, :dispatchable_deliveries_in_junction)
    delivery_ids = Array{Int64,1}(vcat([deliveries[k] for k in junction_ids]...))
    constraint_zone_demand(gpm, nw, i, delivery_ids)
end


"Constraint that is used to compute cost for gas in a zone. Since the cost of gas
typically appears in the objective function or is bounded, these constraints do not
compute the price directly. Rather, they place a lower bound on the price of gas. There
are two constraints stated here. The first constraint is

```math
cost_{z} \\ge q_z[1] * (fl_z * \\frac{1.0}{\\rho})^2 + q_z[2] * fl_z * \\frac{1.0}{\\rho} + q_z[3].
```

The second constraint is

```math
m_z * fl_z * \\frac{1.0}{\\rho},
```

where ``cost_{z}`` is the daily (24-hour) cost of gas in zone ``z``. ``q`` is the
quadratic cost of gas as function of gas consumed in the zone, ``fl_z.`` ``\\rho`` is
standard density. ``m`` is the minimum cost of gas in terms kg/s."
function constraint_zone_demand_price(gpm::AbstractGasPowerModel, i::Int; nw::Int = nw_id_default)
    if !haskey(_IM.con(gpm, _GM.gm_it_sym, nw), :zone_demand_price)
        _IM.con(gpm, _GM.gm_it_sym, nw)[:zone_demand_price] = Dict{Int, Array{JuMP.ConstraintRef}}()
    end

    price_zone = _IM.ref(gpm, _GM.gm_it_sym, nw, :price_zone, i)
    min_cost, cost_q = price_zone["min_cost"], price_zone["cost_q"]
    standard_density = gpm.data["it"][_GM.gm_it_name]["standard_density"]
    constraint_zone_demand_price(gpm, nw, i, min_cost, cost_q, standard_density)
end


"Constraint that is used to compute the cost for pressure in a zone. Since the cost of
pressure typically appears in the objective function or is bounded, the constraints do
not compute the price directly. Rather they act as a lower bound on the price of
pressure, which is implictly tight when this term only appears in the objective function:

```math
pc_z \\ge p_z[1] * \\pi_z^2 + cp_z[2] * \\pi_z + cp_z[3],
```

where ``pc_z`` is the maximum pressure price in zone ``z`` and ``p_z`` is a quadratic
function of the maximum pressure in ``z``."
function constraint_pressure_price(gpm::AbstractGasPowerModel, i::Int; nw::Int=nw_id_default)
    if !haskey(_IM.con(gpm, _GM.gm_it_sym, nw), :pressure_price)
        _IM.con(gpm, _GM.gm_it_sym, nw)[:pressure_price] = Dict{Int, JuMP.ConstraintRef}()
    end

    price_zone = _IM.ref(gpm, _GM.gm_it_sym, nw, :price_zone, i)
    constraint_pressure_price(gpm, nw, i, price_zone["cost_p"])
end

"Constraint that is used to compute the maximum pressure in a price zone. Since the
maximum pressure typically appears in a minimization objective function, the max is
modeled as a lower bound of the form

```math
\\pi_z \\ge \\pi_i \\forall i \\in z.
```"
function constraint_zone_pressure(gm::_GM.AbstractGasModel, i::Int; nw::Int=gm.cnw)
    junctions = filter(x -> x.second["price_zone"] == i, _GM.ref(gm, nw, :junction))
    constraint_zone_pressure(gm, nw, i, keys(junctions))
end
