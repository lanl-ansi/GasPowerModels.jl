" Assign generator numbers to the junctions for easy access "
function add_junction_generators(pm::GenericPowerModel, gm::GenericGasModel)
    for k in keys(gm.ref[:nw])
        # create a gens field
        for (j, consumer) in GasModels.ref(gm, k, :consumer)
            consumer["gens"] = []  
        end   
        
        # assumes that network numbers are linked between power and gas...
        for (i, gen) in PowerModels.ref(pm, k, :gen)
            if haskey(gen, "consumer")
                consumer = gen["consumer"]
                push!(GasModels.ref(gm, k, :consumer, consumer)["gens"], i)                      
            end  
        end        
    end
end
