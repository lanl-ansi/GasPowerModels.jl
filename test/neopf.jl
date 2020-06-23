@testset "test neopf" begin
    @testset "IEEE 14 and Belgian Network (Pressure Penalty)" begin
        g_file, p_file = "../test/data/matgas/belgian-ne.m", "../test/data/case14-ne.m"
        g_type, p_type = MISOCPGasModel, SOCWRPowerModel

        result = run_neopf(g_file, p_file, g_type, p_type, juniper,
            gm_solution_processors=[_GM.sol_psqr_to_p!],
            pm_solution_processors=[_PM.sol_data_model!])

        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["solution"]["ne_pipe"]["16"]["z"], 1.0, atol=1.0e-4)
    end

    @testset "IEEE 14 and Belgian Network (Demand Penalty)" begin
        g_file, p_file = "../test/data/matgas/belgian-ne.m", "../test/data/case14-ne.m"
        g_type, p_type = MISOCPGasModel, SOCWRPowerModel

        result = run_neopf(g_file, p_file, g_type, p_type, juniper,
            gm_solution_processors=[_GM.sol_psqr_to_p!],
            pm_solution_processors=[_PM.sol_data_model!])

        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["solution"]["ne_pipe"]["16"]["z"], 1.0, atol=1.0e-4)
    end
 end
