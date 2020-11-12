@testset "src/core/base.jl" begin
    g_file = "../test/data/matgas/GasLib-11-GPF.m"
    p_file = "../test/data/matpower/case5-GPF.m"
    link_file = "../test/data/json/GasLib-11-case5.json"
    g_type, p_type = CRDWPGasModel, SOCWRPowerModel

    @testset "instantiate_model (with file inputs)" begin
        gm, pm = instantiate_model(g_file, p_file, link_file, g_type, p_type, build_gpf)
        @test gm.model == pm.model
    end

    @testset "instantiate_model (with network inputs)" begin
        # Parse the three data files into one data dictionary.
        data = parse_files(g_file, p_file, link_file)

        # Store whether or not each network uses per-unit data.
        g_per_unit = get(data["it"]["ng"], "is_per_unit", 0) != 0
        p_per_unit = get(data["it"]["ep"], "per_unit", false)

        # Correct the network data.
        correct_network_data!(data)

        # Ensure all datasets use the same units for power.
        resolve_units!(data, g_per_unit)

        # Instantiate the model.
        gm, pm = instantiate_model(data, g_type, p_type, build_gpf)
        @test gm.model == pm.model
    end

    @testset "run_model (with file inputs)" begin
        result = run_model(g_file, p_file, link_file, g_type, p_type, juniper, build_gpf)
        @test result["termination_status"] == LOCALLY_SOLVED
    end

    @testset "run_model (with network inputs)" begin
        # Parse the three data files into one data dictionary.
        data = parse_files(g_file, p_file, link_file)

        # Store whether or not each network uses per-unit data.
        g_per_unit = get(data["it"]["ng"], "is_per_unit", 0) != 0
        p_per_unit = get(data["it"]["ep"], "per_unit", false)

        # Correct the network data.
        correct_network_data!(data)

        # Ensure all datasets use the same units for power.
        resolve_units!(data, g_per_unit)

        result = run_model(data, g_type, p_type, juniper, build_gpf)
        @test result["termination_status"] == LOCALLY_SOLVED
    end
end
