@testset "src/io/common.jl" begin
    @testset "parse_json" begin
        data = parse_json("../test/data/json/GasLib-11-case5.json")
        delivery_gens = data["dep"]["delivery_gen"]

        @test delivery_gens["1"]["status"] == 1
        @test delivery_gens["1"]["delivery"]["id"] == "1"
        @test delivery_gens["1"]["heat_rate_curve_coefficients"] == [1.0, 100000.0, 0.0]
        @test delivery_gens["1"]["gen"]["id"] == "3"

        @test delivery_gens["2"]["status"] == 1
        @test delivery_gens["2"]["delivery"]["id"] == "3"
        @test delivery_gens["2"]["heat_rate_curve_coefficients"] == [0.0, 100000.0, 0.0]
        @test delivery_gens["2"]["gen"]["id"] == "5"
    end


    @testset "parse_link_file" begin
        data = parse_link_file("../test/data/json/GasLib-11-case5.json")
        delivery_gens = data["dep"]["delivery_gen"]

        @test haskey(data, "multiinfrastructure")
        @test data["multiinfrastructure"] == true

        @test delivery_gens["1"]["status"] == 1
        @test delivery_gens["1"]["delivery"]["id"] == "1"
        @test delivery_gens["1"]["heat_rate_curve_coefficients"] == [1.0, 100000.0, 0.0]
        @test delivery_gens["1"]["gen"]["id"] == "3"

        @test delivery_gens["2"]["status"] == 1
        @test delivery_gens["2"]["delivery"]["id"] == "3"
        @test delivery_gens["2"]["heat_rate_curve_coefficients"] == [0.0, 100000.0, 0.0]
        @test delivery_gens["2"]["gen"]["id"] == "5"
    end


    @testset "parse_link_file (invalid extension)" begin
        path = "../examples/data/json/no_file.txt"
        @test_throws ErrorException parse_link_file(path)
    end


    @testset "parse_gas_file" begin
        path = "../test/data/matgas/GasLib-11-GPF.m"
        data = parse_gas_file(path)
        @test haskey(data, "multiinfrastructure")
        @test data["multiinfrastructure"] == true
    end


    @testset "parse_power_file" begin
        path = "../test/data/matpower/case5-GPF.m"
        data = parse_power_file(path)
        @test haskey(data, "multiinfrastructure")
        @test data["multiinfrastructure"] == true
    end


    @testset "parse_files" begin
        gas_path = "../test/data/matgas/GasLib-11-GPF.m"
        power_path = "../test/data/matpower/case5-GPF.m"
        link_path = "../test/data/json/GasLib-11-case5.json"
        data = parse_files(gas_path, power_path, link_path)

        @test haskey(data, "multiinfrastructure")
        @test data["multiinfrastructure"] == true
        @test haskey(data, "dep")
        @test haskey(data["it"], _PM.pm_it_name)
        @test haskey(data["it"], _GM.gm_it_name)
    end
end
