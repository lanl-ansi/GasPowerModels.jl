
#Check the qp gas and power flow model, this is contrived to make sure something is built on both sides

@testset "test qp ne opf" begin

    @testset "36 Bus Ilic 1.1 Northeast 1.0" begin
        data   = GasModels.parse_file("../data/TC_PennToNortheast_wValves_expansion_1.0.json")
        result = GasGridModels.run_ne_opf("../data/36bus_ilic_expansion_1.1.m", "../data/TC_PennToNortheast_wValves_expansion_1.0.json", SOCWRPowerModel, MISOCPGasModel, misocp_solver; power_opf_weight=365, gas_price_weight=365)        
        @test isapprox(result["solution"]["price_zone"]["2"]["max_p"] * data["baseP"]^2, 254096.08138396326; atol = 1e2) 
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        @test isapprox(result["objective"], 4.926397139595786e9; atol = 1e6)
        @test isapprox(result["solution"]["price_zone"]["1"]["lp"], 0.0; atol = 1e-1) 
        @test isapprox(result["solution"]["price_zone"]["2"]["lp"], 807.0748040691982; atol = 1e-1) 

        @test isapprox(result["solution"]["price_zone"]["1"]["lq"] * data["baseQ"], 211.48095814417917; atol = 1e-1) 
        @test isapprox(result["solution"]["price_zone"]["2"]["lq"] * data["baseQ"], 676.7594475341344; atol = 1e-1) 
        @test isapprox(result["solution"]["price_zone"]["1"]["lm"], 782069.9147221734; atol = 1e4) 
        @test isapprox(result["solution"]["price_zone"]["2"]["lm"], 664351.6224873272; atol = 1e4) 
          
                           

         println(result["solution"]["price_zone"]["1"]["lq"] * data["baseQ"])   
         println(result["solution"]["price_zone"]["2"]["lq"] * data["baseQ"])   
         println(result["solution"]["price_zone"]["1"]["lm"])   
         println(result["solution"]["price_zone"]["2"]["lm"])   
                     
                     
          
#        println(result["solution"]["price_zone"]["1"]["max_p"])   
 #       println(result["solution"]["price_zone"]["2"]["max_p"])   

  #      println(result["solution"]["price_zone"]["1"]["max_p"]  * data["baseP"]^2)   
   #     println(result["solution"]["price_zone"]["2"]["max_p"]  * data["baseP"]^2)
    #    println(result["objective"])     

    end
   
    @testset "36 Bus Ilic 1.1 Northeast 2.25" begin
        data   = GasModels.parse_file("../data/TC_PennToNortheast_wValves_expansion_2.25.json")
        result = GasGridModels.run_ne_opf("../data/36bus_ilic_expansion_1.1.m", "../data/TC_PennToNortheast_wValves_expansion_2.25.json", SOCWRPowerModel, MISOCPGasModel, misocp_solver; power_opf_weight=365, gas_price_weight=365)
    
        #@test isapprox(result["solution"]["price_zone"]["2"]["max_p"] * data["baseP"]^2, 262320.6898633216; atol = 1e3) 
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        @test isapprox(result["objective"], 5.127290418071447e9; atol = 1e6) 
        @test isapprox(result["solution"]["price_zone"]["1"]["lp"], 0.0; atol = 1e-1) 
        @test isapprox(result["solution"]["price_zone"]["2"]["lp"], 807.4860344931661; atol = 1e1) 
          
        @test isapprox(result["solution"]["price_zone"]["1"]["lq"] * data["baseQ"], 204.53980121547292; atol = 1e-1) 
        @test isapprox(result["solution"]["price_zone"]["2"]["lq"] * data["baseQ"], 684.2409776660413; atol = 1e-1) 
        @test isapprox(result["solution"]["price_zone"]["1"]["lm"], 1.2252538198528204e6; atol = 1e4) 
        @test isapprox(result["solution"]["price_zone"]["2"]["lm"], 675761.2730792335; atol = 1e4) 
          
          
#         println(result["solution"]["price_zone"]["1"]["lq"])   
 #        println(result["solution"]["price_zone"]["2"]["lq"])   
  #       println(result["solution"]["price_zone"]["1"]["lm"])   
   #      println(result["solution"]["price_zone"]["2"]["lm"])   
          
          
    end

    @testset "36 Bus Ilic 1.0 Northeast 1.0" begin
        data   = GasModels.parse_file("../data/TC_PennToNortheast_wValves_expansion_1.0.json")
        result = GasGridModels.run_ne_opf("../data/36bus_ilic_expansion_1.0.m", "../data/TC_PennToNortheast_wValves_expansion_1.0.json", SOCWRPowerModel, MISOCPGasModel, misocp_solver; power_opf_weight=365, gas_price_weight=365)
                 
        @test isapprox(result["solution"]["price_zone"]["2"]["max_p"] * data["baseP"]^2, 253479.1474286553; atol = 1e2) 
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        @test isapprox(result["objective"], 4.0269404390948544e9; atol = 1e6)
        @test isapprox(result["solution"]["price_zone"]["1"]["lp"], 0.0; atol = 1e-1) 
        @test isapprox(result["solution"]["price_zone"]["2"]["lp"], 807.0439573714327; atol = 1e-1) 
          
         @test isapprox(result["solution"]["price_zone"]["1"]["lq"] * data["baseQ"], 181.45976964759356; atol = 1e-1) 
        @test isapprox(result["solution"]["price_zone"]["2"]["lq"] * data["baseQ"], 599.5498983986922; atol = 1e-1) 
        @test isapprox(result["solution"]["price_zone"]["1"]["lm"], 456216.61610697175; atol = 1e4) 
        @test isapprox(result["solution"]["price_zone"]["2"]["lm"], 587812.3621385244; atol = 1e4)  
          
          
    #             println(result["solution"]["price_zone"]["1"]["lq"])   
    #     println(result["solution"]["price_zone"]["2"]["lq"])   
    #     println(result["solution"]["price_zone"]["1"]["lm"])   
    #     println(result["solution"]["price_zone"]["2"]["lm"])   
          
    end
    
    @testset "36 Bus Ilic 1.0 Northeast 2.25" begin
        data   = GasModels.parse_file("../data/TC_PennToNortheast_wValves_expansion_2.25.json")
        result = GasGridModels.run_ne_opf("../data/36bus_ilic_expansion_1.0.m", "../data/TC_PennToNortheast_wValves_expansion_2.25.json", SOCWRPowerModel, MISOCPGasModel, misocp_solver; power_opf_weight=365, gas_price_weight=365)
        
        @test isapprox(result["solution"]["price_zone"]["2"]["max_p"] * data["baseP"]^2, 255424.53496340988 ; atol = 1e2) 
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        @test isapprox(result["objective"], 4.1859768708376384e9; atol = 1e6)         
        @test isapprox(result["solution"]["price_zone"]["1"]["lp"], 0.0; atol = 1e-1) 
        @test isapprox(result["solution"]["price_zone"]["2"]["lp"], 807.1412267481705; atol = 1e-1) 
        
          @test isapprox(result["solution"]["price_zone"]["1"]["lq"] * data["baseQ"], 181.33325660643482; atol = 1e-1) 
#        @test isapprox(result["solution"]["price_zone"]["2"]["lq"] * data["baseQ"],599.6436029996856; atol = 1e-1) 
        @test isapprox(result["solution"]["price_zone"]["1"]["lm"], 886581.3924360978; atol = 1e4) 
        @test isapprox(result["solution"]["price_zone"]["2"]["lm"], 591720.2379956864; atol = 1e4)   
            
          
     #            println(result["solution"]["price_zone"]["1"]["lq"])   
         println(result["solution"]["price_zone"]["2"]["lq"] * data["baseQ"])   
     #    println(result["solution"]["price_zone"]["1"]["lm"])   
     #    println(result["solution"]["price_zone"]["2"]["lm"])   
          
    end
    

    
    
    
    # Really long running
   # @testset "36 Bus Ilic 1.0 Northeast 4.0" begin
    #    result = GasGridModels.run_ne_opf("../data/36bus_ilic_expansion_1.0.json", "../data/TC_PennToNortheast_wValves_expansion_4.0.json", SOCWRPowerModel, MISOCPGasModel, misocp_solver; power_opf_weight=365, gas_price_weight=365)
     #   @test result["status"] == :LocalOptimal || result["status"] == :Optimal
      #  @test isapprox(result["objective"], 4.389485957629279e9; atol = 1e5) 
    #end
          
end

