@testset "parse_json" begin
    data = parse_json("../test/data/json/GasLib-11-case5.json")
    @test data[1]["status"] == true
    @test data[2]["status"] == true
end


@testset "parse_file (.json)" begin
    data = parse_file("../test/data/json/GasLib-11-case5.json")

    @test data[1]["status"] == true
    @test data[1]["heat_rate_curve_coefficients"] == [1.0, 100000.0, 0.0]
    @test data[1]["components"][1]["infrastructure_type"] == "power_transmission"
    @test data[1]["components"][2]["infrastructure_type"] == "natural_gas"

    @test data[2]["status"] == true
    @test data[2]["heat_rate_curve_coefficients"] == [0.0, 100000.0, 0.0]
    @test data[2]["components"][1]["infrastructure_type"] == "power_transmission"
    @test data[2]["components"][2]["infrastructure_type"] == "natural_gas"
end


@testset "parse_file (invalid extension)" begin
    path = "../examples/data/json/no_file.txt"
    @test_throws ErrorException parse_file(path)
end
