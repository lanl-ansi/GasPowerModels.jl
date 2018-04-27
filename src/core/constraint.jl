################################################################################
# This file defines commonly used and created constraints for gas grid models
################################################################################

" Constraint for posting the heat rate curve 
  Assumption is mmBTU/h
  To get a daily rate multiply by 24
  To get back in real units, multiply by mvaBase
  To get CFD, divide by 1026 (1026 BTUs is a cubic feet)
  This is equation 21 in the HICCS paper"
function constraint_heat_rate_curve{T,P,G}(ggm::GenericGasGridModel{T}, pm::GenericPowerModel{P}, gm::GenericGasModel{G}, j_idx)
    junction = gm.ref[:junction][j_idx]
    ql = 0
    if junction["qlmin"] != junction["qlmax"]  
        ql = gm.var[:ql][j_idx] 
    end
    pg = pm.var[:nw][pm.cnw][:pg] #pg = pm.var[:pg] 
    generators = haskey(ggm.ref[:junction_generators], j_idx) ? ggm.ref[:junction_generators][j_idx] : []
    
    if !haskey(ggm.constraint, :heat_rate_curve)
        ggm.constraint[:heat_rate_curve] = Dict{Int,ConstraintRef}()
    end    
              
    if length(generators) == 0
        c = @constraint(ggm.model, ql == 0.0)
        ggm.constraint[:heat_rate_curve][j_idx] = c
    end     
     
    # convert from mmBTU/h in per unit to million CFD
    constant = ((24.0 * pm.data["baseMVA"]) / 1026.0)                      
    c = @constraint(ggm.model, ql == constant * sum( ggm.ref[:gen][i]["heat_rate"][1] == 0.0 ? 0 : ggm.ref[:gen][i]["heat_rate"][1]*pg[i]^2 for i in generators) + sum( ggm.ref[:gen][i]["heat_rate"][2]*pg[i] for i in generators) + sum( ggm.ref[:gen][i]["heat_rate"][3] for i in generators))

    ggm.constraint[:heat_rate_curve][j_idx] = c
end

