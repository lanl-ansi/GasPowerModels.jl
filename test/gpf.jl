function check_voltage_status(sol)
    for (idx, val) in sol["bus"]
        @test val["vm"] >= 0.0 # Power flow only says magnitude is bigger than zero.
    end
end

function check_pressure_status(sol)
    for (idx, val) in sol["junction"]
        @test val["p"] >= 0.0
    end
end

# Check the qp gas-power flow model.
@testset "test qp gf pf" begin
    @testset "IEEE 14-Belgian case" begin
        gfile, pfile = ["../test/data/matgas/belgian.m", "../test/data/case14.m"]
        gtype, ptype = [_GM.MISOCPGasModel, _PM.SOCWRPowerModel]
        result = solve_gpf(gfile, pfile, gtype, ptype, juniper, psp=[_PM.sol_data_model!])

        @test result["termination_status"] == _MOI.LOCALLY_SOLVED
        @test isapprox(result["objective"], 0.0, atol=1e-6)
        check_voltage_status(result["solution"])
        check_pressure_status(result["solution"])                    
    end      
end
