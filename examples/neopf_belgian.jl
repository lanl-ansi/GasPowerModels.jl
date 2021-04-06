
#Check the qp gas and power flow model, this is contrived to make sure something is built on both sides

@testset "test misocp belgian" begin
    @testset "Case 14, Belgian NE" begin
        gas_path = "../examples/data/matgas/belgian_ne.m"
        power_path = "../examples/data/matpower/case14-ne.m"
        link_path = "../examples/data/json/belgian-case14-ne.json"
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        result = run_ne(gas_path, power_path, link_path, gpm_type, misocp_solver)

        @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
        @test isapprox(result["objective"], 0.0; atol = 1.0e6)
    end

    @testset "Case 14, Belgian 100% Stress NE" begin
        gas_path = "../examples/data/matgas/belgian_ne-100.m"
        power_path = "../examples/data/matpower/case14-ne-100.m"
        link_path = "../examples/data/json/belgian-case14-ne.json"
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        result = run_ne(gas_path, power_path, link_path, gpm_type, misocp_solver)

        @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
        @test isapprox(result["objective"], 1.648420334e9; atol = 1.0e6)
    end

    @testset "Case 14, Belgian NE OPF" begin
        gas_path = "../examples/data/matgas/belgian_ne.m"
        power_path = "../examples/data/matpower/case14-ne.m"
        link_path = "../examples/data/json/belgian-case14-ne.json"
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        result = run_ne_opf(gas_path, power_path, link_path, gpm_type, misocp_solver)

        @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
        @test isapprox(result["objective"] / 3600.0, 2.38; atol = 1.0e-2)
    end

    @testset "Case 14, Belgian 100% Stress NE OPF" begin
        gas_path = "../examples/data/matgas/belgian_ne-100.m"
        power_path = "../examples/data/matpower/case14-ne-100.m"
        link_path = "../examples/data/json/belgian-case14-ne.json"
        gpm_type = GasPowerModel{CRDWPGasModel, SOCWRPowerModel}
        result = run_ne_opf(gas_path, power_path, link_path, gpm_type, misocp_solver)

        @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
        @test isapprox(result["objective"], 1.64844e9; atol = 1.0e6)
    end
end

@testset "test minlp belgian" begin
    @testset "Case 14, Belgian NE" begin
        gas_path = "../examples/data/matgas/belgian_ne.m"
        power_path = "../examples/data/matpower/case14-ne.m"
        link_path = "../examples/data/json/belgian-case14-ne.json"
        gpm_type = GasPowerModel{DWPGasModel, SOCWRPowerModel}
        result = run_ne(gas_path, power_path, link_path, gpm_type, minlp_solver)

        @test result["termination_status"] in [LOCALLY_SOLVED, OPTIMAL]
        @test isapprox(result["objective"], 0.0; atol = 1.0e6)
     end
end
