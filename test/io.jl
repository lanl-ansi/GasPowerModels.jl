@testset "src/io/common.jl" begin
    @testset "parse_json" begin
        data = parse_json("../test/data/json/GasLib-11-case5.json")
        delivery_gens = data["it"]["dep"]["delivery_gen"]

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
        delivery_gens = data["it"]["dep"]["delivery_gen"]

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
        @test haskey(data["it"], "dep")
        @test haskey(data["it"], _PM.pm_it_name)
        @test haskey(data["it"], _GM.gm_it_name)
    end


    @testset "Per-unit versus SI gas input files" begin
        power_path = "../test/data/matpower/case5-GPF.m"
        link_path = "../test/data/json/GasLib-11-case5.json"

        gas_path_pu = "../test/data/matgas/GasLib-11-GPF.m"
        data_pu = parse_files(gas_path_pu, power_path, link_path)

        gas_path_si = "../test/data/matgas/GasLib-11-SI.m"
        data_si = parse_files(gas_path_si, power_path, link_path)

        # Test that relevant junction properties are nearly equal.
        for property in ["p_min", "p_max", "p_nominal"]
            value_pu = data_pu["it"]["gm"]["junction"]["1"][property]
            value_si = data_si["it"]["gm"]["junction"]["1"][property]
            @test isapprox(value_pu, value_si)
        end

        # Test that relevant pipe properties are nearly equal.
        for property in ["diameter", "length", "friction_factor",
            "p_min", "p_max", "flow_min", "flow_max"]
            value_pu = data_pu["it"]["gm"]["pipe"]["1"][property]
            value_si = data_si["it"]["gm"]["pipe"]["1"][property]
            @test isapprox(value_pu, value_si)
        end

        # Test that relevant compressor properties are nearly equal.
        for property in ["outlet_p_min", "outlet_p_max", "inlet_p_min",
            "inlet_p_max", "diameter", "length", "diameter",
            "operating_cost", "friction_factor", "power_max",
            "c_ratio_min", "c_ratio_max", "flow_min", "flow_max"]
            value_pu = data_pu["it"]["gm"]["compressor"]["1"][property]
            value_si = data_si["it"]["gm"]["compressor"]["1"][property]
            @test isapprox(value_pu, value_si)
        end

        # Test that relevant valve properties are nearly equal.
        for property in ["flow_min", "flow_max"]
            value_pu = data_pu["it"]["gm"]["valve"]["1"][property]
            value_si = data_si["it"]["gm"]["valve"]["1"][property]
            @test isapprox(value_pu, value_si)
        end

        # Test that relevant receipt properties are nearly equal.
        for property in ["injection_min", "injection_max", "injection_nominal"]
            value_pu = data_pu["it"]["gm"]["receipt"]["1"][property]
            value_si = data_si["it"]["gm"]["receipt"]["1"][property]
            @test isapprox(value_pu, value_si)
        end

        # Test that relevant delivery properties are nearly equal.
        for property in ["withdrawal_min", "withdrawal_max", "withdrawal_nominal"]
            value_pu = data_pu["it"]["gm"]["delivery"]["1"][property]
            value_si = data_si["it"]["gm"]["delivery"]["1"][property]
            @test isapprox(value_pu, value_si)
        end

        # Test that relevant price zone properties are nearly equal.
        for property in ["cost_q_1", "cost_q_2", "cost_q_3", "cost_p_1",
                "cost_p_2", "cost_p_3", "constant_p", "min_cost"]
            value_pu = data_pu["it"]["gm"]["price_zone"]["1"][property]
            value_si = data_si["it"]["gm"]["price_zone"]["1"][property]
            @test isapprox(value_pu, value_si)

            value_pu = data_pu["it"]["gm"]["price_zone"]["2"][property]
            value_si = data_si["it"]["gm"]["price_zone"]["2"][property]
            @test isapprox(value_pu, value_si)
        end

        # Test that relevant linking properties are nearly equal.
        delivery_gen_pu = data_pu["it"]["dep"]["delivery_gen"]["1"]
        delivery_gen_si = data_si["it"]["dep"]["delivery_gen"]["1"]
        array_pu = delivery_gen_pu["heat_rate_curve_coefficients"]
        array_si = delivery_gen_si["heat_rate_curve_coefficients"]
        @test all(isapprox.(array_pu, array_si))
    end
end
