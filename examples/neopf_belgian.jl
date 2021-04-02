
#Check the qp gas and power flow model, this is contrived to make sure something is built on both sides

@testset "test misocp belgian" begin

    @testset "Case 14, Belgian NE" begin
        result = GasPowerModels.run_ne("../examples/data/matgas/belgian_ne.m", "../examples/data/matpower/case14-ne.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 0.0; atol = 1e6)
        GC.gc()
    end

    @testset "Case 14, Belgian 100% Stress NE" begin
        result = GasPowerModels.run_ne("../examples/data/matgas/belgian_ne-100.m", "../examples/data/matpower/case14-ne-100.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 1.648420334e9; atol = 1e6)
        GC.gc()
    end

    @testset "Case 14, Belgian NE OPF" begin
        result = GasPowerModels.run_ne_opf("../examples/data/matgas/belgian_ne.m", "../examples/data/matpower/case14-ne.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 2.38; atol = 1e-2)
        GC.gc()
    end

    @testset "Case 14, Belgian 100% Stress NE OPF" begin
        result = GasPowerModels.run_ne_opf("../examples/data/matgas/belgian_ne-100.m", "../examples/data/matpower/case14-ne-100.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 1.64844e9; atol = 1e6)
        GC.gc()
    end

end

@testset "test minlp belgian" begin

    @testset "Case 14, Belgian NE" begin
        result = GasPowerModels.run_ne("../examples/data/matgas/belgian_ne.m", "../examples/data/matpower/case14-ne.m", DWPGasModel, SOCWRPowerModel, minlp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 0.0; atol = 1e6)
        GC.gc()
    end
end
