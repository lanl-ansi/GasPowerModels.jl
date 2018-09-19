
#Check the qp gas and power flow model, this is contrived to make sure something is built on both sides

@testset "test neopf" begin

    @testset "Pressure Penalty" begin
        result = GasGridModels.run_ne_opf("../test/data/no_cost.m", "../test/data/no_demand_cost.json", SOCWRPowerModel, MISOCPGasModel, misocp_solver; power_opf_weight=1.0, gas_price_weight=1.0)        
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        @test isapprox(result["objective"],  484127; atol = 1.0)
    end
   
    @testset "Demand Penalty" begin
        result = GasGridModels.run_ne_opf("../test/data/no_cost.m", "../test/data/no_pressure_cost.json", SOCWRPowerModel, MISOCPGasModel, misocp_solver; power_opf_weight=1.0, gas_price_weight=1.0)            
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        @test isapprox(result["objective"],  248574; atol = 1.0)
          
        println("1: ", result["solution"]["price_zone"]["1"]["lq"])  
        println("2: ", result["solution"]["price_zone"]["2"]["lq"])  
    end

 end

