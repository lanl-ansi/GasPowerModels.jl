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
        gfile, pfile = ["../test/data/matgas/belgian.m", "../test/data/case14.m"]
        gtype, ptype = [_GM.MISOCPGasModel, _PM.SOCWRPowerModel]
        result = run_gpf(gfile, pfile, gtype, ptype, juniper, psp=[_PM.sol_data_model!])

        @test result["termination_status"] == _MOI.LOCALLY_SOLVED
        @test isapprox(result["objective"], 0.0, atol=1.0e-6)
        @test isapprox(result["solution"]["junction"]["4"]["p"], 0.749184, rtol=1.0e-2)
        @test isapprox(result["solution"]["junction"]["15"]["p"], 0.653442, rtol=1.0e-2)
        @test isapprox(result["solution"]["junction"]["171"]["p"], 0.821063, rtol=1.0e-2)
        @test isapprox(result["solution"]["bus"]["8"]["vm"], 1.09, rtol=1.0e-2)
        @test isapprox(result["solution"]["bus"]["12"]["vm"], 0.92993, rtol=1.0e-2)
        @test isapprox(result["solution"]["gen"]["4"]["qg"], 4.61349, rtol=1.0e-2)
        @test isapprox(result["solution"]["gen"]["4"]["pg"], 0.0, atol=1.0e-7)

        #@test isapprox(result["solution"]["junction"]["4"]["p"], 0.937914, rtol=1.0e-2)
        #@test isapprox(result["solution"]["junction"]["15"]["p"], 0.65232, rtol=1.0e-2)
        #@test isapprox(result["solution"]["junction"]["171"]["p"], 0.821771, rtol=1.0e-2)
        #@test isapprox(result["solution"]["bus"]["8"]["vm"], 1.05085, rtol=1.0e-2)
        #@test isapprox(result["solution"]["bus"]["12"]["vm"], 0.993202, rtol=1.0e-2)
        #@test isapprox(result["solution"]["gen"]["4"]["qg"], 0.238042, rtol=1.0e-2)
        #@test isapprox(result["solution"]["gen"]["4"]["pg"], 0.992462, rtol=1.0e-2)
        #@test isapprox(result["solution"]["ne_branch"]["1"]["built"], 1.0, atol=1.0e-4)
        #@test isapprox(result["solution"]["ne_branch"]["14"]["built"], 1.0, atol=1.0e-4)
        #@test isapprox(result["solution"]["ne_pipe"]["32"]["built"], 1.0, atol=1.0e-4)
        #@test isapprox(result["solution"]["ne_pipe"]["47"]["built"], 1.0, atol=1.0e-4)
        #@test isapprox(result["solution"]["producer"]["5"]["qg"], 0.0607955, rtol=1.0e-2)
        #@test isapprox(result["solution"]["producer"]["5"]["fg"], 0.0607955, rtol=1.0e-2)
        #@test isapprox(result["solution"]["compressor"]["10"]["yp"], 1.0, atol=1.0e-4)
        #@test isapprox(result["solution"]["compressor"]["10"]["yn"], 0.0, atol=1.0e-4)
        #@test isapprox(result["solution"]["consumer"]["15"]["fl"], 0.147911, rtol=1.0e-2)
        #@test isapprox(result["solution"]["consumer"]["15"]["ql"], 0.147911, rtol=1.0e-2)
        #test_voltage_status(result["solution"])
        #test_pressure_status(result["solution"])
    end      
end
