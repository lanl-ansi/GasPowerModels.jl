function check_voltage_status_ne(sol)
    for (idx,val) in sol["bus"]
        @test val["vm"] >= 0.94 && val["vm"] <= 1.06
    end
end

function check_pressure_status_ne(sol)
    for (idx,val) in sol["junction"]
        @test val["p"] >= 0.0
    end
end


#Check the qp gas and power flow model, this is contrived to make sure something is built on both sides

@testset "test qp ne" begin
    @testset "IEEE 14 Belgian NE case" begin
        normalization = 1e-8
        gas_ne_weight = 1.0
        power_ne_weight = 1.0

        result = GasPowerModels.run_ne("../test/data/case14-ne.m", "../test/data/belgian-ne.json", SOCWRPowerModel, MISOCPGasModel, misocp_solver; gas_ne_weight=gas_ne_weight, power_ne_weight=power_ne_weight, obj_normalization=normalization)
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal

#        @test isapprox(result["objective"], 4.2769964867495346e9 * normalization; atol = 1.0)
        @test isapprox(result["objective"], 0.07226588 * normalization; atol = 1.0)
        check_voltage_status_ne(result["solution"])
        check_pressure_status_ne(result["solution"])
    end
end
