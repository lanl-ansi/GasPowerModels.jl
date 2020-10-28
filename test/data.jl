@testset "Gas-Power Linking Data" begin
    data = _PM.parse_file("../test/data/matpower/case5-GPF.m")

    @test data["gen"]["1"]["delivery"] == -1
    @test data["gen"]["1"]["heat_rate_quad_coeff"] == 0.0
    @test data["gen"]["1"]["heat_rate_linear_coeff"] == 0.0
    @test data["gen"]["1"]["heat_rate_constant_coeff"] == 0.0

    @test data["gen"]["2"]["delivery"] == -1
    @test data["gen"]["2"]["heat_rate_quad_coeff"] == 0.0
    @test data["gen"]["2"]["heat_rate_linear_coeff"] == 0.0
    @test data["gen"]["2"]["heat_rate_constant_coeff"] == 0.0

    @test data["gen"]["3"]["delivery"] == 1
    @test data["gen"]["3"]["heat_rate_quad_coeff"] == 3600.0
    @test data["gen"]["3"]["heat_rate_linear_coeff"] == 360000000.0
    @test data["gen"]["3"]["heat_rate_constant_coeff"] == 0.0

    @test data["gen"]["4"]["delivery"] == -1
    @test data["gen"]["4"]["heat_rate_quad_coeff"] == 0.0
    @test data["gen"]["4"]["heat_rate_linear_coeff"] == 0.0
    @test data["gen"]["4"]["heat_rate_constant_coeff"] == 0.0

    @test data["gen"]["5"]["delivery"] == 3
    @test data["gen"]["5"]["heat_rate_quad_coeff"] == 0.0
    @test data["gen"]["5"]["heat_rate_linear_coeff"] == 360000000.0
    @test data["gen"]["5"]["heat_rate_constant_coeff"] == 0.0
end
