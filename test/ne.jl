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

# Check the qp gas and power flow model. This is contrived to make sure
# something is built on both sides.
@testset "test qp ne" begin
    @testset "IEEE 14 Belgian NE case" begin
        normalization = 1e-8
        gas_ne_weight, power_ne_weight = [1.0, 1.0]
        gfile, pfile = ["../test/data/matgas/belgian_ne.m", "../test/data/case14-ne.m"]
        gtype, ptype = [_GM.MISOCPGasModel, _PM.SOCWRPowerModel]

        result = solve_ne(gfile, pfile, gtype, ptype, juniper,
            gas_ne_weight=gas_ne_weight, power_ne_weight=power_ne_weight,
            obj_normalization=normalization, psp=[_PM.sol_data_model!])

        @test result["termination_status"] == _MOI.LOCALLY_SOLVED
        @test isapprox(result["objective"], 0.07226588*normalization, atol=1.0)
        check_voltage_status_ne(result["solution"])
        check_pressure_status_ne(result["solution"])
    end
end
