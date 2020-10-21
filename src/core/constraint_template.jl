#
# Constraint Template Definitions
#
# Constraint templates help simplify data wrangling across multiple
# formulations by providing an abstraction layer between the network data
# and network constraint definitions. The constraint template's job is to
# extract the required parameters from a given network data structure and
# pass the data as named arguments to the Gas Flow or Power Flow formulations.
#
# Constraint templates should always be defined over "AbstractGasModel" and
# "AbstractPowerModel" and should never refer to model variables.

"Constraint for coupling the production of power at natural gas generators with the gas consumption required to produce this power.
The full non convex constraint is stated as ``fl = e * \\rho (h_2 * pg^2 + h_1 * pg + h_0)``
where ``h`` is a quadratic function used to convert MW (``pg``) into Joules consumed per second (J/s). ``h`` is in units of (J/MW^2, J/MW, J).
This is then converted to mass flow, ``fl``, (kg/s) of gas consumed to produce this energy.
Here, ``e`` is an energy factor (m^3/J) and ``\\rho`` is standard density (kg/m^3). This constraint can be relaxed to
a convex quadractic of the form ``fl \\ge e * \\rho (h_2 * pg^2 + h_1 * pg + h_0)``"
function constraint_heat_rate_curve(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel, j::Int; nw::Int=gm.cnw)
    delivery = _GM.ref(gm, nw, :delivery, j)
    generators = collect(delivery["gens"])
    standard_density = gm.data["standard_density"]
    heat_rates = Dict{Int, Any}()

    for i in generators
        heat_rates[i] = [_PM.ref(pm, nw, :gen, i)["heat_rate_quad_coeff"],
                         _PM.ref(pm, nw, :gen, i)["heat_rate_linear_coeff"],
                         _PM.ref(pm, nw, :gen, i)["heat_rate_constant_coeff"]]
    end

    # convert from J/s in per unit to cubic meters per second at standard density in per
    # unit to kg per second in per unit.
    constant = gm.data["energy_factor"] * standard_density

    dispatchable = delivery["is_dispatchable"]
    constraint_heat_rate_curve(pm, gm, nw, j, generators, heat_rates, constant, dispatchable)
end


"Auxiliary constraint that computes the total consumed gas in a zones. This constraint takes the form of
``fl_{z} = \\sum_{k \\in z} fl_k `` where ``fl_{z}`` is the total consumed gas in zone ``z`` and ``fl_k``
is gas consumed at delivery point ``k`` in the zone. "
function constraint_zone_demand(gm::_GM.AbstractGasModel, i::Int; nw::Int=gm.cnw)
    junctions = _GM.ref(gm, nw, :junction)
    junction_ids = keys(filter(x -> x.second["price_zone"] == i, junctions))
    deliveries = _GM.ref(gm, nw, :dispatchable_deliveries_in_junction)
    delivery_ids = Array{Int64,1}(vcat([deliveries[k] for k in junction_ids]...))
    constraint_zone_demand(gm, nw, i, delivery_ids)
end

"Constraint that is used to compute cost for gas in a zone.  Since the cost of gas typically appears in the objective function or is bounded,
 these constraints do not compute the price directly, rather they place a lower bound on the price of gas.  There are two constraints stated here.
 The first constraint is ``cost_{z} \\ge 86400.0^2 * q_z[1] * (fl_z * \frac{1.0}{\\rho})^2 + 86400.0 * q_z[2] * fl_z * \frac{1.0}{\\rho} + q_z[3].
 The second constraint is ``86400.0 * m_z * fl_z * \frac{1.0}{\\rho} ``
 where ``cost_{z}`` is the daily (24 hour) cost of gas in zone ``z``. 86400 is the number of seconds in a day. ``q`` is the quadractic cost of gas as function of
 gas consumed in the gas, ``fl_z.``  ``\\rho`` is standard density. ``m`` is the minmum cost of gas in terms kg/s."
function constraint_zone_demand_price(gm::_GM.AbstractGasModel, i::Int; nw::Int=gm.cnw)
    price_zone = _GM.ref(gm, nw, :price_zone, i)
    min_cost, cost_q = price_zone["min_cost"], price_zone["cost_q"]
    standard_density = gm.data["standard_density"]
    constraint_zone_demand_price(gm, nw, i, min_cost, cost_q, standard_density)
end

"Constraint that is used to compute the cost for pressure in a zone. Since the cost of pressure typically appears in the objective function
or is bounded, the constraints do not compute the price directly, rather they play a lower bound on the price of pressure, which is implictly tight
when this term only appears in the objective funtion.
``pc_z \\ge p_z[1] * \\pi_z^2 + cp_z[2] * \\pi_z + cp_z[3]
where ``pc_z`` is the pressure price in zone ``z`` and ``p_z`` is a quadractic function of the maximum pressure in ``z``.
"
function constraint_pressure_price(gm::_GM.AbstractGasModel, i::Int; nw::Int=gm.cnw)
    price_zone = _GM.ref(gm, nw, :price_zone, i)
    constraint_pressure_price(gm, nw, i, price_zone["cost_p"])
end

"Constraint this used to compute the maximum pressure in a price zone. Since the maximum pressure typically appears in a minimization
objective function, the max is modeled as a lower bound of the form
``\\pi_z \\ge \\pi_i \\forall i \\in z`` "
function constraint_zone_pressure(gm::_GM.AbstractGasModel, i::Int; nw::Int=gm.cnw)
    junctions = filter(x -> x.second["price_zone"] == i, _GM.ref(gm, nw, :junction))
    constraint_zone_pressure(gm, nw, i, keys(junctions))
end
