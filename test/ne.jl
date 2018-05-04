function check_voltage_status_ne(sol)
    for (idx,val) in sol["bus"]
        @test val["vm"] >= 0.94 && val["vm"] <= 1.06 
    end
end

function check_pressure_status_ne(sol)
    for (idx,val) in sol["junction"]
        @test val["p"] >= 0.0
    end
end


#Check the qp gas and power flow model, this is contrived to make sure something is built on both sides

@testset "test qp ne" begin
    @testset "IEEE 14 Belgian NE case" begin
        normalization = .0001
        result = GasGridModels.run_ne("../test/data/case14-ne.json", "../test/data/belgian-ne.json", SOCWRPowerModel, MISOCPGasModel, pajarito_glpk_solver; obj_normalization=normalization)
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        @test isapprox(result["objective"], 222991605.4 * normalization; atol = 1.0) 
        check_voltage_status_ne(result["solution"])
        check_pressure_status_ne(result["solution"])                    
    end      
end




