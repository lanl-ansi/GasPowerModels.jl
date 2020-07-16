#
# Constraint Template Definitions
#
# Constraint templates help simplify data wrangling across multiple
# formulations by providing an abstraction layer between the network data
# and network constraint definitions. The constraint template's job is to
# extract the required parameters from a given network data structure and
# pass the data as named arguments to the Gas Flow or Power Flow formulations.
#
# Constraint templates should always be defined over "GenericFooModel"
# and should never refer to model variables

"Assumption is J/s."
function constraint_heat_rate_curve(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel, n, j)
    delivery = _GM.ref(gm, n, :delivery, j)
    generators = delivery["gens"]
    standard_density = gm.data["standard_density"]

    # convert from J/s in per unit to cubic meters per second at standard density in per unit to kg per second in per unit.
    constant = gm.data["energy_factor"] * standard_density
    heat_rates = Dict{Int, Any}()

    for i in generators
        heat_rates[i] = [_PM.ref(pm, n, :gen, i)["heat_rate_quad_coeff"],
                         _PM.ref(pm, n, :gen, i)["heat_rate_linear_coeff"],
                         _PM.ref(pm, n, :gen, i)["heat_rate_constant_coeff"]]
    end

    dispatchable = delivery["is_dispatchable"]
    constraint_heat_rate_curve(pm, gm, n, j, generators, heat_rates, constant, dispatchable)
end

function constraint_heat_rate_curve(pm::_PM.AbstractPowerModel, gm::_GM.AbstractGasModel, k::Int)
    constraint_heat_rate_curve(pm, gm, gm.cnw, k)
end

" constraints associated with bounding the demand zone prices
 This is equation 23 in the HICCS paper "
function constraint_zone_demand(gm::_GM.AbstractGasModel, n::Int, i::Int)
    loads = Set()
    junctions = filter(x -> x.second["price_zone"] != 0, _GM.ref(gm, n, :junction))

    for (i, price_zone) in _GM.ref(gm, n, :price_zone)
        junc_ids = keys(filter(x -> x.second["price_zone"] == i, junctions))
        load_i = [_GM.ref(gm, n, :dispatchable_deliveries_in_junction, i) for i in junc_ids]
        loads = union(loads, load_i...)
    end

    constraint_zone_demand(gm, n, i, loads)


   #price_zone = _GM.ref(gm, n, :price_zone, i)
   #loads = Set()

   #for i in price_zone["junctions"]
   #    loads = union(loads,_GM.ref(gm,n,:junction_dispatchable_deliveries,i))
   #end

end

constraint_zone_demand(gm::_GM.AbstractGasModel, i::Int) = constraint_zone_demand(gm, gm.cnw, i)

" constraints associated with bounding the demand zone prices
 This is equation 22 in the HICCS paper"
function constraint_zone_demand_price(gm::_GM.AbstractGasModel, n::Int, i)
    price_zone = _GM.ref(gm,n,:price_zone,i)
    min_cost = price_zone["min_cost"]
    cost_q = price_zone["cost_q"]
    standard_density = gm.data["standard_density"]

    constraint_zone_demand_price(gm, n, i, min_cost, cost_q, standard_density)
end
constraint_zone_demand_price(gm::_GM.AbstractGasModel, i::Int) = constraint_zone_demand_price(gm, gm.cnw, i)

" constraints associated with pressure prices
 This is equation 25 in the HICCS paper"
function constraint_pressure_price(gm::_GM.AbstractGasModel, n::Int, i)
    price_zone = _GM.ref(gm,n,:price_zone,i)
    cost_p = price_zone["cost_p"]

    constraint_pressure_price(gm, n, i, cost_p)
end

function constraint_pressure_price(gm::_GM.AbstractGasModel, i::Int)
    constraint_pressure_price(gm, gm.cnw, i)
end
