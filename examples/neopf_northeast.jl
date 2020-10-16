
#Check the qp gas and power flow model, this is contrived to make sure something is built on both sides

@testset "test misocp ne" begin

    @testset "Case 36-1.0, Northeast-1.0 NE" begin
        result = GasPowerModels.run_ne("../examples/data/matgas/northeast-ne-1.0.m", "../examples/data/matpower/case36-ne-1.0.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 0.0; atol = 1e-6)
        GC.gc()
    end

#    @testset "Case 36-1.0, Northeast-1.0 NE OPF" begin
#        result = GasPowerModels.run_ne_opf("../examples/data/matgas/northeast-ne-1.0.m", "../examples/data/matpower/case36-ne-1.0.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
#        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
#        @test isapprox(result["objective"], 4.0269404390948544e9; atol = 1e6)
#        GC.gc()
#    end

    @testset "Case 36-1.1, Northeast-1.0 NE" begin
        result = GasPowerModels.run_ne("../examples/data/matgas/northeast-ne-1.0.m", "../examples/data/matpower/case36-ne-1.1.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 0.0; atol = 1e6)
        GC.gc()
    end

    @testset "Case 36-1.1, Northeast-1.0 NE OPF" begin
        result = GasPowerModels.run_ne_opf("../examples/data/matgas/northeast-ne-1.0.m", "../examples/data/matpower/case36-ne-1.1.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 4.926397139595786e9; atol = 1e6)
        GC.gc()
    end

    @testset "Case 36-1.0, Northeast-2.25 NE" begin
        result = GasPowerModels.run_ne("../examples/data/matgas/northeast-ne-2.25.m", "../examples/data/matpower/case36-ne-1.0.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 0.0; atol = 1e-6)
        GC.gc()
    end

#    @testset "Case 36-1.0, Northeast-2.25 NE OPF" begin
#        result = GasPowerModels.run_ne_opf("../examples/data/matgas/northeast-ne-2.25.m", "../examples/data/matpower/case36-ne-1.0.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
#        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
#        @test isapprox(result["objective"], 4.1859768708376384e9; atol = 1e6)
#        GC.gc()
#    end

    @testset "Case 36-1.1, Northeast-2.25 NE" begin
        result = GasPowerModels.run_ne("../examples/data/matgas/northeast-ne-2.25.m", "../examples/data/matpower/case36-ne-1.1.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 0.0; atol = 1e-6)
        GC.gc()
    end

#    @testset "Case 36-1.1, Northeast-2.25 NE OPF" begin
#        result = GasPowerModels.run_ne_opf("../examples/data/matgas/northeast-ne-2.25.m", "../examples/data/matpower/case36-ne-1.1.m", CRDWPGasModel, SOCWRPowerModel, misocp_solver)
#        @test result["termination_status"] == LOCALLY_SOLVED || result["termination_status"] == OPTIMAL
#        @test isapprox(result["objective"], 5.127290418071447e9; atol = 1e6)
#        GC.gc()
#    end


end
