#
# Constraint Template Definitions
#
# Constraint templates help simplify data wrangling across multiple
# formulations by providing an abstraction layer between the network data
# and network constraint definitions.  The constraint template's job is to
# extract the required parameters from a given network data structure and
# pass the data as named arguments to the Gas Flow or Power Flow formulations.
#
# Constraint templates should always be defined over "GenericFooModel"
# and should never refer to model variables

" Assumption is J/s"
function constraint_heat_rate_curve(pm::GenericPowerModel, gm::GenericGasModel{G}, n, j) where G <:GasModels.AbstractGasFormulation
    consumer = GasModels.ref(gm,n,:consumer,j)
    generators = consumer["gens"]
    standard_density = gm.data["standard_density"]

    # convert from J/s in per unit to cubic meters per second at standard density in per unit to kg per second in per unit.
    constant = gm.data["energy_factor"] * standard_density

    heat_rates = Dict{Int, Any}()
    for i in generators
        heat_rates[i] = [PowerModels.ref(pm,n,:gen,i)["heat_rate_quad_coeff"], PowerModels.ref(pm,n,:gen,i)["heat_rate_linear_coeff"], PowerModels.ref(pm,n,:gen,i)["heat_rate_constant_coeff"]]
    end
    dispatchable = consumer["dispatchable"]
    constraint_heat_rate_curve(pm, gm, n, j, generators, heat_rates, constant, dispatchable)
end
constraint_heat_rate_curve(pm::GenericPowerModel, gm::GenericGasModel, k::Int) = constraint_heat_rate_curve(pm, gm, gm.cnw, k)

" constraints associated with bounding the demand zone prices
 This is equation 23 in the HICCS paper "
function constraint_zone_demand(gm::GenericGasModel, n::Int, i)
   price_zone = GasModels.ref(gm,n,:price_zone,i)
   loads = Set()
   for i in price_zone["junctions"]
       loads = union(loads,GasModels.ref(gm,n,:junction_dispatchable_consumers,i))
   end

   constraint_zone_demand(gm, n, i, loads)
end
constraint_zone_demand(gm::GenericGasModel, i::Int) = constraint_zone_demand(gm, gm.cnw, i)

" constraints associated with bounding the demand zone prices
 This is equation 22 in the HICCS paper"
function constraint_zone_demand_price(gm::GenericGasModel, n::Int, i)
    price_zone = GasModels.ref(gm,n,:price_zone,i)
    min_cost = price_zone["min_cost"]
    cost_q = price_zone["cost_q"]
    standard_density = gm.data["standard_density"]

    constraint_zone_demand_price(gm, n, i, min_cost, cost_q, standard_density)
end
constraint_zone_demand_price(gm::GenericGasModel, i::Int) = constraint_zone_demand_price(gm, gm.cnw, i)

" constraints associated with pressure prices
 This is equation 25 in the HICCS paper"
function constraint_pressure_price(gm::GenericGasModel, n::Int, i)
    price_zone = GasModels.ref(gm,n,:price_zone,i)
    cost_p     = price_zone["cost_p"]

    constraint_pressure_price(gm, n, i, cost_p)
end
constraint_pressure_price(gm::GenericGasModel, i::Int) = constraint_pressure_price(gm, gm.cnw, i)
