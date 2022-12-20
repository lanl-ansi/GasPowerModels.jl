@testset "Gas-Power Network Expansion Problems" begin
    @testset "Quadratic Programming (QP) Formulation" begin
        # Set up problem metadata.
        g_file = "../test/data/matgas/GasLib-11-NE.m"
        p_file = "../test/data/matpower/case5-NE.m"
        link_file = "../test/data/json/GasLib-11-case5.json"
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}

        # Solve the joint gas-power network expansion planning problem.
        result = run_ne(g_file, p_file, link_file, gpm_type, minlp_solver;
            solution_processors = [_GM.sol_psqr_to_p!, _PM.sol_data_model!],
            relax_integrality = true)

        # Ensure the problem has been solved to local optimality.
        @test result["termination_status"] == LOCALLY_SOLVED
        @test result["solution"]["it"][_GM.gm_it_name]["ne_pipe"]["4"]["z"] > 0.0
        @test all([x["p"] >= 0.0 for (i, x) in result["solution"]["it"][_GM.gm_it_name]["junction"]])
        @test all([x["vm"] >= 0.0 for (i, x) in result["solution"]["it"][_PM.pm_it_name]["bus"]])
    end

    @testset "Nonlinear Programming (NLP) Formulation" begin
        # Set up problem metadata.
        g_file = "../test/data/matgas/GasLib-11-NE.m"
        p_file = "../test/data/matpower/case5-NE.m"
        link_file = "../test/data/json/GasLib-11-case5.json"
        gpm_type = GasPowerModel{DWPGasModel, SOCWRPowerModel}

        # Solve the joint gas-power network expansion planning problem.
        result = run_ne(g_file, p_file, link_file, gpm_type, minlp_solver;
            solution_processors = [_GM.sol_psqr_to_p!, _PM.sol_data_model!],
            relax_integrality = true)

        # Ensure the problem has been solved to local optimality.
        @test result["termination_status"] == LOCALLY_SOLVED
        @test result["solution"]["it"][_GM.gm_it_name]["ne_pipe"]["4"]["z"] > 0.0
        @test all([x["p"] >= 0.0 for (i, x) in result["solution"]["it"][_GM.gm_it_name]["junction"]])
        @test all([x["vm"] >= 0.0 for (i, x) in result["solution"]["it"][_PM.pm_it_name]["bus"]])
    end

    @testset "run_ne (from file paths)" begin
        # Set up problem metadata.
        g_file = "../test/data/matgas/GasLib-11-NE.m"
        p_file = "../test/data/matpower/case5-NE.m"
        link_file = "../test/data/json/GasLib-11-case5.json"
        data = parse_files(g_file, p_file, link_file)
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}

        # Solve the joint gas-power network expansion planning problem.
        result = run_ne(data, gpm_type, minlp_solver; solution_processors =
            [_GM.sol_psqr_to_p!, _PM.sol_data_model!],
            relax_integrality = true)

        # Ensure the problem has been solved to local optimality.
        @test result["termination_status"] == LOCALLY_SOLVED
        @test result["solution"]["it"][_GM.gm_it_name]["ne_pipe"]["4"]["z"] > 0.0
        @test all([x["p"] >= 0.0 for (i, x) in result["solution"]["it"][_GM.gm_it_name]["junction"]])
        @test all([x["vm"] >= 0.0 for (i, x) in result["solution"]["it"][_PM.pm_it_name]["bus"]])
    end
end

