function test_voltage_status(sol)
    for (idx, val) in sol["bus"]
        @test val["vm"] >= 0.0 # Power flow only says magnitude is bigger than zero.
    end
end

function test_pressure_status(sol)
    for (idx, val) in sol["junction"]
        @test val["p"] >= 0.0
    end
end

@testset "Test QP Gas-Power Flow" begin
    @testset "IEEE 14 (Power) and Belgian (Gas)" begin
        g_file, p_file = "../test/data/matgas/belgian.m", "../test/data/case14.m"
        g_type, p_type = MISOCPGasModel, SOCWRPowerModel
        result = run_gpf(g_file, p_file, g_type, p_type, juniper,
            gm_solution_processors=[_GM.sol_psqr_to_p!],
            pm_solution_processors=[_PM.sol_data_model!])

        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 0.0, atol=1.0e-6)
        @test isapprox(result["solution"]["junction"]["4"]["p"], 0.749184, rtol=1.0e-2)
        @test isapprox(result["solution"]["junction"]["15"]["p"], 0.653442, rtol=1.0e-2)
        @test isapprox(result["solution"]["junction"]["171"]["p"], 0.821063, rtol=1.0e-2)
        @test isapprox(result["solution"]["bus"]["8"]["vm"], 1.09, rtol=1.0e-2)
        @test isapprox(result["solution"]["bus"]["12"]["vm"], 0.92993, rtol=1.0e-2)
        @test isapprox(result["solution"]["gen"]["4"]["qg"], 4.61349, rtol=1.0e-2)
        @test isapprox(result["solution"]["gen"]["4"]["pg"], 0.0, atol=1.0e-2)
        test_voltage_status(result["solution"])
        test_pressure_status(result["solution"])
    end      
end
