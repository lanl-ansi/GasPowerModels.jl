@testset "src/util/solve_mld.jl" begin
    # Set up problem metadata.
    g_file = "../test/data/matgas/GasLib-11-GPF.m"
    p_file = "../test/data/matpower/case5-GPF.m"
    link_file = "../test/data/json/GasLib-11-case5.json"
    gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}

    @testset "Prioritize Power Delivery First" begin
        # Parse files and create a data dictionary.
        data = parse_files(g_file, p_file, link_file)
        data["it"][_PM.pm_it_name]["gen"]["3"]["gen_status"] = 0
        correct_network_data!(data)

        # Solve the gas-power maximum load delivery problem.
        result = solve_mld(data, gpm_type, build_mld,
            minlp_solver, 0.0; relax_integrality = true)

        # Ensure the problem has been solved to local optimality.
        @test result["termination_status"] == LOCALLY_SOLVED
        @test all([x["p"] >= 0.0 for (i, x) in result["solution"]["it"][_GM.gm_it_name]["junction"]])
        @test all([x["vm"] >= 0.0 for (i, x) in result["solution"]["it"][_PM.pm_it_name]["bus"]])
    end

    @testset "Prioritize Power Delivery First (UC)" begin
        # Parse files and create a data dictionary.
        data = parse_files(g_file, p_file, link_file)
        data["it"][_PM.pm_it_name]["gen"]["3"]["gen_status"] = 0
        correct_network_data!(data)

        # Solve the gas-power maximum load delivery problem.
        result = solve_mld(data, gpm_type, build_mld_uc,
            minlp_solver, 0.0; relax_integrality = true)

        # Ensure the problem has been solved to local optimality.
        @test result["termination_status"] == LOCALLY_SOLVED
        @test all([x["p"] >= 0.0 for (i, x) in result["solution"]["it"][_GM.gm_it_name]["junction"]])
        @test all([x["vm"] >= 0.0 for (i, x) in result["solution"]["it"][_PM.pm_it_name]["bus"]])
    end

    @testset "Prioritize Gas Delivery First" begin
        # Parse files and create a data dictionary.
        data = parse_files(g_file, p_file, link_file)
        data["it"][_PM.pm_it_name]["gen"]["3"]["gen_status"] = 0
        correct_network_data!(data)

        # Solve the gas-power maximum load delivery problem.
        result = solve_mld(data, gpm_type, build_mld,
            minlp_solver, 1.0; relax_integrality = true)

        # Ensure the problem has been solved to local optimality.
        @test result["termination_status"] == LOCALLY_SOLVED
        @test all([x["p"] >= 0.0 for (i, x) in result["solution"]["it"][_GM.gm_it_name]["junction"]])
        @test all([x["vm"] >= 0.0 for (i, x) in result["solution"]["it"][_PM.pm_it_name]["bus"]])
    end

    @testset "Prioritize Gas Delivery First (UC)" begin
        # Parse files and create a data dictionary.
        data = parse_files(g_file, p_file, link_file)
        data["it"][_PM.pm_it_name]["gen"]["3"]["gen_status"] = 0
        correct_network_data!(data)

        # Solve the gas-power maximum load delivery problem.
        result = solve_mld(data, gpm_type, build_mld_uc,
            minlp_solver, 1.0; relax_integrality = true)

        # Ensure the problem has been solved to local optimality.
        @test result["termination_status"] == LOCALLY_SOLVED
        @test all([x["p"] >= 0.0 for (i, x) in result["solution"]["it"][_GM.gm_it_name]["junction"]])
        @test all([x["vm"] >= 0.0 for (i, x) in result["solution"]["it"][_PM.pm_it_name]["bus"]])
    end

    @testset "Weight Delivery of Power and Gas Equally" begin
        # Parse files and create a data dictionary.
        data = parse_files(g_file, p_file, link_file)
        data["it"][_PM.pm_it_name]["gen"]["3"]["gen_status"] = 0
        correct_network_data!(data)

        # Solve the gas-power maximum load delivery problem.
        result = solve_mld(data, gpm_type, build_mld,
            minlp_solver, 0.5; relax_integrality = true)

        # Ensure the problem has been solved to local optimality.
        @test result["termination_status"] == LOCALLY_SOLVED
        @test all([x["p"] >= 0.0 for (i, x) in result["solution"]["it"][_GM.gm_it_name]["junction"]])
        @test all([x["vm"] >= 0.0 for (i, x) in result["solution"]["it"][_PM.pm_it_name]["bus"]])
    end

    @testset "Weight Delivery of Power and Gas Equally (UC)" begin
        # Parse files and create a data dictionary.
        data = parse_files(g_file, p_file, link_file)
        data["it"][_PM.pm_it_name]["gen"]["3"]["gen_status"] = 0
        correct_network_data!(data)

        # Solve the gas-power maximum load delivery problem.
        result = solve_mld(data, gpm_type, build_mld_uc,
            minlp_solver, 0.5; relax_integrality = true)

        # Ensure the problem has been solved to local optimality.
        @test result["termination_status"] == LOCALLY_SOLVED
        @test all([x["p"] >= 0.0 for (i, x) in result["solution"]["it"][_GM.gm_it_name]["junction"]])
        @test all([x["vm"] >= 0.0 for (i, x) in result["solution"]["it"][_PM.pm_it_name]["bus"]])
    end
end