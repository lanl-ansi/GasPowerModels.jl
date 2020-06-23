@testset "Test QP Optimal Gas-Power Flow" begin
    @testset "IEEE 14 (Power) and Belgian (Gas)" begin
        g_file, p_file = "../test/data/matgas/belgian.m", "../test/data/case14.m"
        g_type, p_type = MISOCPGasModel, SOCWRPowerModel
        result = run_ogpf(g_file, p_file, g_type, p_type, juniper,
            gm_solution_processors=[_GM.sol_psqr_to_p!],
            pm_solution_processors=[_PM.sol_data_model!])

        @test result["termination_status"] == LOCALLY_SOLVED
    end      
end
