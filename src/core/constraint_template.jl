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

" Assumption is mmBTU/h
 To get a daily rate multiply by 24
 To get back in real units, multiply by mvaBase
 To get CFD, divide by 1026 (1026 BTUs is a cubic feet) 
 This is the convex relaxation of equation 21 in the HICCS paper"
function constraint_heat_rate_curve{P, G <: GasModels.AbstractMISOCPForms}(pm::GenericPowerModel{P}, gm::GenericGasModel{G}, n, j)
    consumer = gm.ref[:nw][n][:consumer][j]
    generators = consumer["gens"] 
    # convert from mmBTU/h in per unit to cubic meters per second
    constant = ((24.0  / 1026.0) / gm.data["baseQ"]) * 0.32774128  #1.0
    heat_rates = Dict{Int, Any}()   
    for i in generators
        heat_rates[i] = [pm.ref[:nw][n][:gen][i]["heat_rate_quad_coeff"], pm.ref[:nw][n][:gen][i]["heat_rate_linear_coeff"], pm.ref[:nw][n][:gen][i]["heat_rate_constant_coeff"]  ]    
    end
    flmin = GasModels.calc_flmin(gm.data, consumer)
    flmax = GasModels.calc_flmax(gm.data, consumer)
    
    constraint_heat_rate_curve(pm, gm, n, j, generators, heat_rates, constant, flmin, flmax)
end
constraint_heat_rate_curve(pm::GenericPowerModel, gm::GenericGasModel, k::Int) = constraint_heat_rate_curve(pm, gm, gm.cnw, k)

" constraints associated with bounding the demand zone prices 
 This is equation 23 in the HICCS paper "
function constraint_zone_demand{G}(gm::GenericGasModel{G}, n::Int, i)
    load_set = filter(j -> gm.ref[:nw][n][:consumer][j]["qlmin"] != 0 || gm.ref[:nw][n][:consumer][j]["qlmax"] != 0, collect(keys(gm.ref[:nw][n][:consumer])))    
    price_zone = gm.ref[:nw][n][:price_zone][i]
    loads = intersect(price_zone["junctions"],load_set)
    
    constraint_zone_demand(gm, n, i, loads)  
end
constraint_zone_demand(gm::GenericGasModel, i::Int) = constraint_zone_demand(gm, gm.cnw, i)

" constraints associated with bounding the demand zone prices 
 This is equation 22 in the HICCS paper"
function constraint_zone_demand_price{G}(gm::GenericGasModel{G}, n::Int, i)
    price_zone = gm.ref[:nw][n][:price_zone][i]
    min_cost = price_zone["min_cost"]
    cost_q = price_zone["cost_q"]  
    
    constraint_zone_demand_price(gm, n, i, min_cost, cost_q)          
end
constraint_zone_demand_price(gm::GenericGasModel, i::Int) = constraint_zone_demand_price(gm, gm.cnw, i)

" constraints associated with pressure prices 
 This is equation 25 in the HICCS paper"
function constraint_pressure_price{G}(gm::GenericGasModel{G}, n::Int, i)
    price_zone = gm.ref[:nw][n][:price_zone][i]
    cost_p     = price_zone["cost_p"]
    
    constraint_pressure_price(gm, n, i, cost_p)  
end
constraint_pressure_price(gm::GenericGasModel, i::Int) = constraint_pressure_price(gm, gm.cnw, i)
