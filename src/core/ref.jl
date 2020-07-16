"Add price zone information to GasModels data reference dictionary."
function ref_add_price_zones!(ref::Dict{Symbol,<:Any}, data::Dict{String,<:Any})
    nws_data = _IM.ismultinetwork(data) ? data["nw"] : Dict("0" => data)
    q_base, p_base = ref[:base_flow], ref[:base_pressure]

    for (n, nw_data) in nws_data
        for (i, x) in nw_data["price_zone"]
            entry = Dict{String,Any}()
            # TODO: Use the correct column names, here.
            entry["cost_p"] = [x["col_5"]*p_base^4, x["col_6"]*p_base^2, x["col_7"]]
            entry["cost_q"] = [x["col_2"]*q_base^2, x["col_3"]*q_base, x["col_4"]]
            entry["min_cost"], entry["constant_p"] = x["col_8"] * q_base, x["col_9"]
            ref[:nw][parse(Int, n)][:price_zone][x["col_1"]] = entry
        end
    end
end

"Assign generator indices to delivery entries for easy access."
function _assign_delivery_generators!(gm::_GM.AbstractGasModel, pm::_PM.AbstractPowerModel)
    for (nw, network) in _GM.nws(pm)
        # Get the subset of "gen" items containing the "delivery" key.
        gens = filter(x -> haskey(x.second, "delivery"), _PM.ref(pm, nw, :gen))

        # Create a "gens" field for deliveries to store coupled generator indices.
        for (j, delivery) in _GM.ref(gm, nw, :delivery)
            gen_ids = keys(filter(x -> x.second["delivery"] == j, gens))
            delivery["gens"] = length(gen_ids) > 0 ? gen_ids : []
        end
    end
end
