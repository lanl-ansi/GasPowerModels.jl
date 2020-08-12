@testset "src/core/base.jl" begin
    g_file = "../test/data/matgas/GasLib-11-GPF.m"
    p_file = "../test/data/matpower/case5-GPF.m"
    g_type, p_type = MISOCPGasModel, SOCWRPowerModel

    @testset "instantiate_model (with file inputs)" begin
        gm, pm = instantiate_model(g_file, p_file, g_type, p_type, build_gpf)
        @test gm.model == pm.model
    end

    @testset "instantiate_model (with network inputs)" begin
        g_data, p_data = _GM.parse_file(g_file), _PM.parse_file(p_file)
        gm, pm = instantiate_model(g_data, p_data, g_type, p_type, build_gpf)
        @test gm.model == pm.model
    end

    @testset "run_model (with file inputs)" begin
        result = run_model(g_file, p_file, g_type, p_type, juniper, build_gpf)
        @test result["termination_status"] == LOCALLY_SOLVED
    end

    @testset "run_model (with network inputs)" begin
        g_data, p_data = _GM.parse_file(g_file), _PM.parse_file(p_file)
        resolve_units!(g_data, p_data)
        result = run_model(g_data, p_data, g_type, p_type, juniper, build_gpf)
        @test result["termination_status"] == LOCALLY_SOLVED
    end
end
