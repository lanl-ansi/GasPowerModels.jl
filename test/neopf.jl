
#Check the qp gas and power flow model, this is contrived to make sure something is built on both sides

@testset "test neopf" begin

    @testset "Pressure Penalty" begin
        result = GasPowerModels.run_ne_opf("../test/data/no_cost.m", "../test/data/no_demand_cost.json", SOCWRPowerModel, MISOCPGasModel, misocp_solver; power_opf_weight=1.0, gas_price_weight=1.0)
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        println(result["objective"])
        # Tested with Gurobi 8.1
        @test isapprox(result["objective"],  484124; atol = 1e0)
    end

    @testset "Demand Penalty" begin
        result = GasPowerModels.run_ne_opf("../test/data/no_cost.m", "../test/data/no_pressure_cost.json", SOCWRPowerModel, MISOCPGasModel, misocp_solver; power_opf_weight=1.0, gas_price_weight=1.0)
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        println(result["objective"])
        # Tested with Gurobi 8.1
        @test isapprox(result["objective"],  250139; atol = 1.0) || isapprox(result["objective"],  248541; atol = 2.0) || isapprox(result["objective"],  248549; atol = 2.0)
    end
 end
