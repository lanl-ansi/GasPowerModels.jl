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
        normalization = .000001
        result = GasGridModels.run_ne("../test/data/case14-ne.m", "../test/data/belgian-ne.json", SOCWRPowerModel, MISOCPGasModel, misocp_solver; obj_normalization=normalization)
        @test result["status"] == :LocalOptimal || result["status"] == :Optimal
        println(result["objective"] / normalization)
        
        if misocp_solver == pajarito_glpk_solver                 
            @test isapprox(result["objective"], 222991605.4 * normalization; atol = 1.0)
        elseif misocp_solver == pajarito_cbc_solver       
            @test isapprox(result["objective"], 4.616444760136424e9 * normalization; atol = 1.0)         
        else      
            @test isapprox(result["objective"], 222991605.4 * normalization; atol = 1.0)
        end  
        check_voltage_status_ne(result["solution"])
        check_pressure_status_ne(result["solution"])                    
    end      
end




