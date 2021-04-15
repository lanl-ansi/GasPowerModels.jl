"Add price zone information to GasPowerModels data reference dictionary."
function ref_add_price_zones!(ref::Dict{Symbol, <:Any}, data::Dict{String, <:Any})
    if _IM.ismultinetwork(data["it"][_GM.gm_it_name])
        nws_data = data["it"][_GM.gm_it_name]["nw"]
    else
        nws_data = Dict("0" => data["it"][_GM.gm_it_name])
    end

    for (n, nw_data) in nws_data
        ref[:it][_GM.gm_it_sym][:nw][parse(Int, n)][:price_zone] = Dict{Int, Any}()

        for (i, x) in nw_data["price_zone"]
            entry = Dict{String, Any}()
            entry["cost_p"] = [x["cost_p_1"], x["cost_p_2"], x["cost_p_3"]]
            entry["cost_q"] = [x["cost_q_1"], x["cost_q_2"], x["cost_q_3"]]
            entry["min_cost"], entry["constant_p"] = x["min_cost"], x["constant_p"]
            ref[:it][_GM.gm_it_sym][:nw][parse(Int, n)][:price_zone][x["id"]] = entry
        end
    end
end

"Get unique gas delivery points that have interdependencies with the power system."
function _get_interdependent_deliveries(gpm::AbstractGasPowerModel; nw::Int = nw_id_default)
    delivery_gens = _IM.ref(gpm, :dep, nw, :delivery_gen)
    return unique(x["delivery"]["id"] for (i, x) in delivery_gens)
end
