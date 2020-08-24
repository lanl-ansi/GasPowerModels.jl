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
# "AbstractWaterModel" and should never refer to model variables.

function constraint_heat_rate_curve(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel, n::Int, j::Int)
    delivery = _GM.ref(gm, n, :delivery, j)
    generators = collect(delivery["gens"])
    standard_density = gm.data["standard_density"]
    heat_rates = Dict{Int, Any}()

    for i in generators
        heat_rates[i] = [_PM.ref(pm, n, :gen, i)["heat_rate_quad_coeff"],
                         _PM.ref(pm, n, :gen, i)["heat_rate_linear_coeff"],
                         _PM.ref(pm, n, :gen, i)["heat_rate_constant_coeff"]]
    end

    # convert from J/s in per unit to cubic meters per second at standard density in per
    # unit to kg per second in per unit.
    constant = gm.data["energy_factor"] * standard_density

    dispatchable = delivery["is_dispatchable"]
    constraint_heat_rate_curve(pm, gm, n, j, generators, heat_rates, constant, dispatchable)
end

function constraint_heat_rate_curve(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel, k::Int)
    constraint_heat_rate_curve(pm, gm, gm.cnw, k)
end

"Constraint that bounds demand zone price using delivery flows within the zone."
function constraint_zone_demand(gm::_GM.AbstractGasModel, i::Int; nw::Int=gm.cnw)
    junctions = _GM.ref(gm, nw, :junction)
    junction_ids = keys(filter(x -> x.second["price_zone"] == i, junctions))
    deliveries = _GM.ref(gm, nw, :dispatchable_deliveries_in_junction)
    delivery_ids = Array{Int64,1}(vcat([deliveries[k] for k in junction_ids]...))
    constraint_zone_demand(gm, nw, i, delivery_ids)
end

" constraints associated with bounding the demand zone prices
 This is equation 22 in the HICCS paper"
function constraint_zone_demand_price(gm::_GM.AbstractGasModel, i::Int; nw::Int=gm.cnw)
    price_zone = _GM.ref(gm, nw, :price_zone, i)
    min_cost, cost_q = price_zone["min_cost"], price_zone["cost_q"]
    standard_density = gm.data["standard_density"]
    constraint_zone_demand_price(gm, nw, i, min_cost, cost_q, standard_density)
end

"Constraint that relates the pressure price to the price zone."
function constraint_pressure_price(gm::_GM.AbstractGasModel, i::Int; nw::Int=gm.cnw)
    price_zone = _GM.ref(gm, nw, :price_zone, i)
    constraint_pressure_price(gm, nw, i, price_zone["cost_p"])
end
