@testset "src/core/base.jl" begin
    g_file = "../test/data/matgas/GasLib-11-GPF.m"
    p_file = "../test/data/matpower/case5-GPF.m"
    link_file = "../test/data/json/GasLib-11-case5.json"

    @testset "instantiate_model (with file inputs)" begin
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        gpm = instantiate_model(g_file, p_file, link_file, gpm_type, build_gpf)
        @test typeof(gpm.model) == JuMP.Model
    end

    @testset "instantiate_model (with network inputs)" begin
        data = parse_files(g_file, p_file, link_file)
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        gpm = instantiate_model(data, gpm_type, build_gpf)
        @test typeof(gpm.model) == JuMP.Model
    end

    @testset "run_model (with file inputs)" begin
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        result = run_model(g_file, p_file, link_file, gpm_type,
            minlp_solver, build_gpf; relax_integrality = true)
        @test result["termination_status"] == LOCALLY_SOLVED
    end

    @testset "run_model (with network inputs)" begin
        data = parse_files(g_file, p_file, link_file)
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        result = run_model(data, gpm_type, minlp_solver, build_gpf; relax_integrality = true)
        @test result["termination_status"] == LOCALLY_SOLVED
    end
end
