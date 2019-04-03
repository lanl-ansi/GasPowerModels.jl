#Check to see if generator connections to consumers are being correctly processed
@testset "test gas grid data" begin
    @testset "IEEE 14 Belgian case" begin
        data = PowerModels.parse_file("../test/data/case14.m")

        @test data["gen"]["1"]["consumer"] == -1
        @test data["gen"]["1"]["heat_rate_quad_coeff"] == 0
        @test data["gen"]["1"]["heat_rate_linear_coeff"] == 0
        @test data["gen"]["1"]["heat_rate_constant_coeff"] == 0

        @test data["gen"]["2"]["consumer"] == 4
        @test data["gen"]["2"]["heat_rate_quad_coeff"] == 0
        @test data["gen"]["2"]["heat_rate_linear_coeff"] == 140674.111111
        @test data["gen"]["2"]["heat_rate_constant_coeff"] == 0

        @test data["gen"]["3"]["consumer"] == 10012
        @test data["gen"]["3"]["heat_rate_quad_coeff"] == 0
        @test data["gen"]["3"]["heat_rate_linear_coeff"] == 140674.111111
        @test data["gen"]["3"]["heat_rate_constant_coeff"] == 0

        @test data["gen"]["4"]["consumer"] == -1
        @test data["gen"]["4"]["heat_rate_quad_coeff"] == 0
        @test data["gen"]["4"]["heat_rate_linear_coeff"] == 0
        @test data["gen"]["4"]["heat_rate_constant_coeff"] == 0

        @test data["gen"]["5"]["consumer"] == -1
        @test data["gen"]["5"]["heat_rate_quad_coeff"] == 0
        @test data["gen"]["5"]["heat_rate_linear_coeff"] == 0
        @test data["gen"]["5"]["heat_rate_constant_coeff"] == 0
    end
end
