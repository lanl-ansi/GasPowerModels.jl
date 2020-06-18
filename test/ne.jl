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
    @testset "IEEE 14 and Belgian Network Expansion" begin
        gfile, pfile = "../test/data/matgas/belgian-ne.m", "../test/data/case14-ne.m"
        gtype, ptype = MISOCPGasModel, SOCWRPowerModel

        result = run_ne(gfile, pfile, gtype, ptype, juniper,
            gm_solution_processors=[_GM.sol_psqr_to_p!],
            pm_solution_processors=[_PM.sol_data_model!])

        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["solution"]["ne_pipe"]["16"]["z"], 1.0, atol=1.0e-4)
        check_voltage_status_ne(result["solution"])
        check_pressure_status_ne(result["solution"])
    end
end
