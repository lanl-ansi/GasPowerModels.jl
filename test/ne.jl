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

# Check the qp gas and power flow model. This is contrived to make sure
# something is built on both sides.
@testset "test qp ne" begin
    @testset "IEEE 14 and Belgian Network Expansion" begin
        gfile, pfile = "../test/data/matgas/belgian_ne.m", "../test/data/case14-ne.m"
        gtype, ptype = _GM.MISOCPGasModel, _PM.SOCWRPowerModel

        result = run_ne(gfile, pfile, gtype, ptype, juniper,
            gas_ne_weight=1.0, power_ne_weight=1.0, obj_normalization=1.0e-8,
            gm_solution_processors=[_GM.sol_psqr_to_p!],
            pm_solution_processors=[_PM.sol_data_model!])

        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 0.07226588*1.0e-8, atol=1.0)
        @test isapprox(result["solution"]["junction"]["4"]["p"], 0.937914, rtol=1.0e-2)
        @test isapprox(result["solution"]["junction"]["15"]["p"], 0.65232, rtol=1.0e-2)
        @test isapprox(result["solution"]["junction"]["171"]["p"], 0.821771, rtol=1.0e-2)
        @test isapprox(result["solution"]["bus"]["8"]["vm"], 1.05085, rtol=1.0e-2)
        @test isapprox(result["solution"]["bus"]["12"]["vm"], 0.993202, rtol=1.0e-2)
        @test isapprox(result["solution"]["gen"]["4"]["qg"], 0.238042, rtol=1.0e-2)
        @test isapprox(result["solution"]["gen"]["4"]["pg"], 0.992462, rtol=1.0e-2)
        @test isapprox(result["solution"]["ne_branch"]["1"]["built"], 1.0, atol=1.0e-4)
        @test isapprox(result["solution"]["ne_branch"]["14"]["built"], 1.0, atol=1.0e-4)
        @test isapprox(result["solution"]["ne_pipe"]["32"]["z"], 1.0, atol=1.0e-4)
        @test isapprox(result["solution"]["ne_pipe"]["47"]["z"], 1.0, atol=1.0e-4)
        @test isapprox(result["solution"]["receipt"]["5"]["qg"], 0.0607955, rtol=1.0e-2)
        @test isapprox(result["solution"]["receipt"]["5"]["fg"], 0.0607955, rtol=1.0e-2)
        @test isapprox(result["solution"]["compressor"]["10"]["y"], 1.0, atol=1.0e-4)
        @test isapprox(result["solution"]["delivery"]["15"]["fl"], 0.147911, rtol=1.0e-2)
        @test isapprox(result["solution"]["delivery"]["15"]["ql"], 0.147911, rtol=1.0e-2)
        check_voltage_status_ne(result["solution"])
        check_pressure_status_ne(result["solution"])
    end
end
