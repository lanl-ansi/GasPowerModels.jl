"Add price zone information to GasModels data reference dictionary."
function ref_add_price_zones!(ref::Dict{Symbol, <:Any}, data::Dict{String, <:Any})
    nws_data = _IM.ismultinetwork(data["it"]["ng"]) ? data["it"]["ng"]["nw"] : Dict("0" => data["it"]["ng"])
    q_base, p_base = Float64(ref[:it][:ng][:base_flow]), Float64(ref[:it][:ng][:base_pressure])

    for (n, nw_data) in nws_data
        ref[:it][:ng][:nw][parse(Int, n)][:price_zone] = Dict{Int, Any}()

        for (i, x) in nw_data["price_zone"]
            entry = Dict{String, Any}()
            entry["cost_p"] = [x["cost_p_1"]*p_base^4, x["cost_p_2"]*p_base^2, x["cost_p_3"]]
            entry["cost_q"] = [x["cost_q_1"]*q_base^2, x["cost_q_2"]*q_base, x["cost_q_3"]]
            entry["min_cost"], entry["constant_p"] = x["min_cost"] * q_base, x["constant_p"]
            ref[:it][:ng][:nw][parse(Int, n)][:price_zone][x["id"]] = entry
        end
    end
end
