# Define QP implementation of Gas Grid Models

export 
    QPGasGridModel, StandardQPForm

@compat abstract type AbstractQPForm <: AbstractGasGridFormulation end
@compat abstract type StandardQPForm <: AbstractQPForm  end
const QPGasGridModel = GenericGasGridModel{StandardQPForm}

" Constructor "
QPGasGridModel(data::Dict{String,Any}; kwargs...) = GenericGasGridModel(data, StandardQPForm; kwargs...)  

###################### Variables ####################################


###################### Constraints ####################################

" Assumption is mmBTU/h
 To get a daily rate multiply by 24
 To get back in real units, multiply by mvaBase
 To get CFD, divide by 1026 (1026 BTUs is a cubic feet) 
 This is the convex relaxation of equation 21 in the HICCS paper"
function constraint_heat_rate_curve{T <: AbstractQPForm, P, G}(ggm::GenericGasGridModel{T}, pm::GenericPowerModel{P}, gm::GenericGasModel{G}, j_idx)
    junction = gm.ref[:nw][gm.cnw][:junction][j_idx]
            
    ql = 0
    
    ### This is a hack.  This assumes that load id and junction id are the same.
    #### FIX FIX FIX
    if haskey(gm.ref[:nw][gm.cnw][:consumer], j_idx)    
        consumer = gm.ref[:nw][gm.cnw][:consumer][j_idx]    
        if consumer["qlmin"] != consumer["qlmax"]   
            ql = gm.var[:nw][gm.cnw][:ql][j_idx] 
        end
    end
    
    pg = pm.var[:nw][pm.cnw][:pg] #pg = pm.var[:pg] 
    generators = haskey(ggm.ref[:junction_generators], j_idx) ? ggm.ref[:junction_generators][j_idx] : []
    
    # convert from mmBTU/h in per unit to million CFD
    constant = ((24.0 * pm.data["baseMVA"]) / 1026.0) 
      
    if length(generators) == 0
        c = @constraint(ggm.model, ql == 0.0)
        return Set([c])
    end     

    is_linear = true;
    for i in generators
        if ggm.ref[:gen][i]["heat_rate"][1] != 0
            is_linear = false
        end
    end
    
    if !haskey(ggm.constraint, :heat_rate_curve)
        ggm.constraint[:heat_rate_curve] = Dict{Int,ConstraintRef}()
    end    
    
    c = nothing    
    if is_linear
        c = @constraint(ggm.model, ql == constant * sum( ggm.ref[:gen][i]["heat_rate"][2]*pg[i] for i in generators) + sum( ggm.ref[:gen][i]["heat_rate"][3] for i in generators))          
    else    
        c = @constraint(ggm.model, ql >= constant * sum( ggm.ref[:gen][i]["heat_rate"][1] == 0.0 ? 0 : ggm.ref[:gen][i]["heat_rate"][1]*pg[i]^2 for i in generators) + sum( ggm.ref[:gen][i]["heat_rate"][2]*pg[i] for i in generators) + sum( ggm.ref[:gen][i]["heat_rate"][3] for i in generators))      
    end
     
    ggm.constraint[:heat_rate_curve][j_idx] = c
 end
