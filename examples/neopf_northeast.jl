#Check the qp gas and power flow model, this is contrived to make sure something is built on both sides

@testset "test misocp ne" begin
    @testset "Case 36-1.0, Northeast-1.0 NE" begin
        gas_path = "../examples/data/matgas/northeast-ne-1.0.m"
        power_path = "../examples/data/matpower/case36-ne-1.0.m"
        link_path = "../examples/data/json/northeast-case36.json"
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        result = run_ne(gas_path, power_path, link_path, gpm_type, misocp_solver)

        @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
        @test isapprox(result["objective"], 0.0; atol = 1.0e-6)
    end

    # @testset "Case 36-1.0, Northeast-1.0 NE OPF" begin
    #     gas_path = "../examples/data/matgas/northeast-ne-1.0.m"
    #     power_path = "../examples/data/matpower/case36-ne-1.0.m"
    #     link_path = "../examples/data/json/northeast-case36.json"
    #     gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
    #     result = run_ne_opf(gas_path, power_path, link_path, gpm_type, misocp_solver)

    #     @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
    #     @test isapprox(result["objective"] / 3600.0, 4.0269404390948544e9; atol = 1.0e6)
    # end

    @testset "Case 36-1.1, Northeast-1.0 NE" begin
        gas_path = "../examples/data/matgas/northeast-ne-1.0.m"
        power_path = "../examples/data/matpower/case36-ne-1.1.m"
        link_path = "../examples/data/json/northeast-case36.json"
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        result = run_ne(gas_path, power_path, link_path, gpm_type, misocp_solver)
       
        @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
        @test isapprox(result["objective"], 0.0; atol = 1.0e8)
    end

    @testset "Case 36-1.1, Northeast-1.0 NE OPF" begin
        gas_path = "../examples/data/matgas/northeast-ne-1.0.m"
        power_path = "../examples/data/matpower/case36-ne-1.1.m"
        link_path = "../examples/data/json/northeast-case36.json"
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        result = run_ne_opf(gas_path, power_path, link_path, gpm_type, misocp_solver)
       
        @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
        @test isapprox(result["objective"], 4.926397139595786e9; atol = 1.0e6)
    end

    @testset "Case 36-1.0, Northeast-2.25 NE" begin
        gas_path = "../examples/data/matgas/northeast-ne-2.25.m"
        power_path = "../examples/data/matpower/case36-ne-1.0.m"
        link_path = "../examples/data/json/northeast-case36.json"
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        result = run_ne(gas_path, power_path, link_path, gpm_type, misocp_solver)
       
        @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
        @test isapprox(result["objective"], 0.0; atol = 1.0e-6)
    end

    # @testset "Case 36-1.0, Northeast-2.25 NE OPF" begin
    #     gas_path = "../examples/data/matgas/northeast-ne-2.25.m"
    #     power_path = "../examples/data/matpower/case36-ne-1.0.m"
    #     link_path = "../examples/data/json/northeast-case36.json"
    #     gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
    #     result = run_ne_opf(gas_path, power_path, link_path, gpm_type, misocp_solver)

    #     @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
    #     @test isapprox(result["objective"], 4.1859768708376384e9; atol = 1.0e6)
    # end

    @testset "Case 36-1.1, Northeast-2.25 NE" begin
        gas_path = "../examples/data/matgas/northeast-ne-2.25.m"
        power_path = "../examples/data/matpower/case36-ne-1.1.m"
        link_path = "../examples/data/json/northeast-case36.json"
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        result = run_ne(gas_path, power_path, link_path, gpm_type, misocp_solver)
       
        @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
        @test isapprox(result["objective"], 0.0; atol = 1.0e-6)
    end

    # @testset "Case 36-1.1, Northeast-2.25 NE OPF" begin
    #     gas_path = "../examples/data/matgas/northeast-ne-2.25.m"
    #     power_path = "../examples/data/matpower/case36-ne-1.1.m"
    #     link_path = "../examples/data/json/northeast-case36.json"
    #     gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
    #     result = run_ne_opf(gas_path, power_path, link_path, gpm_type, misocp_solver)

    #     @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
    #     @test isapprox(result["objective"], 5.127290418071447e9; atol = 1.0e6)
    # end
end
