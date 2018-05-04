# Define QP implementation of Gas Grid Models

###################### Variables ####################################


###################### Constraints ####################################

" Assumption is mmBTU/h
 To get a daily rate multiply by 24
 To get back in real units, multiply by mvaBase
 To get CFD, divide by 1026 (1026 BTUs is a cubic feet) 
 This is the convex relaxation of equation 21 in the HICCS paper"
function constraint_heat_rate_curve{P, G <: GasModels.AbstractMISOCPForms}(pm::GenericPowerModel{P}, gm::GenericGasModel{G}, j, n::Int=gm.cnw)
    consumer = gm.ref[:nw][n][:consumer][j]
            
    ql = consumer["qlmin"] != consumer["qlmax"] ? gm.var[:nw][n][:ql][j] : 0    
    pg = pm.var[:nw][n][:pg] 
    generators = consumer["gens"] 
    
    # convert from mmBTU/h in per unit to million CFD
    constant = ((24.0 * pm.data["baseMVA"]) / 1026.0) 
    
    if !haskey(gm.con[:nw][n], :heat_rate_curve)
        gm.con[:nw][n][:heat_rate_curve] = Dict{Int,ConstraintRef}()
    end     
              
    if length(generators) == 0
        c = @constraint(gm.model, ql == 0.0)
        gm.con[:nw][n][:heat_rate_curve][j] = c
        return
    end     

    is_linear = true;
    for i in generators
        if pm.ref[:nw][n][:gen][i]["heat_rate"][1] != 0
            is_linear = false
        end
    end
        
    c = nothing    
    if is_linear
        c = @constraint(gm.model, ql == constant * sum( pm.ref[:nw][n][:gen][i]["heat_rate"][2]*pg[i] for i in generators) + sum( pm.ref[:nw][n][:gen][i]["heat_rate"][3] for i in generators))          
    else    
        c = @constraint(gm.model, ql >= constant * sum( pm.ref[:nw][n][:gen][i]["heat_rate"][1] == 0.0 ? 0 : pm.ref[:nw][n][:gen][i]["heat_rate"][1]*pg[i]^2 for i in generators) + sum( pm.ref[:nw][n][:gen][i]["heat_rate"][2]*pg[i] for i in generators) + sum( pm.ref[:nw][n][:gen][i]["heat_rate"][3] for i in generators))      
    end
     
    gm.con[:nw][n][:heat_rate_curve][j] = c
 end
