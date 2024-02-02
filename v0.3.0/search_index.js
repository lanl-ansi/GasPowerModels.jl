var documenterSearchIndex = {"docs":
[{"location":"math-model/#The-GasPowerModels-Mathematical-Model","page":"Mathematical Model","title":"The GasPowerModels Mathematical Model","text":"","category":"section"},{"location":"math-model/","page":"Mathematical Model","title":"Mathematical Model","text":"As GasPowerModels implements a variety of coupled gas grid network optimization problems, the implementation is the best reference for precise mathematical formulations. This section provides a mathematical specification for a prototypical coupled gas grid flow problem to provide an overview of the typical mathematical models in GasPowerModels.","category":"page"},{"location":"math-model/#Coupled-Gas-Electric-Power-Flow","page":"Mathematical Model","title":"Coupled Gas Electric Power Flow","text":"","category":"section"},{"location":"math-model/","page":"Mathematical Model","title":"Mathematical Model","text":"GasPowerModels implements a steady-state model of gas flow and power flow based on the implementations of gas flows in GasModels.jl and power flows in PowerModels.jl. The key coupling constraint between power and gas systems is through generators that consume gas to produce power. This is expressed in terms of a heat rate curve, i.e.","category":"page"},{"location":"math-model/","page":"Mathematical Model","title":"Mathematical Model","text":"f = e * rho (h_2 * pg^2 + h_1 * pg + h_0)","category":"page"},{"location":"math-model/","page":"Mathematical Model","title":"Mathematical Model","text":"where h is a quadratic function used to convert MW (pg) into Joules consumed per second. This is then converted to mass flow, f, (kg/s) of gas consumed to produce this energy. Here, e is an energy factor (m^3/s) and rho is standard density (kg/m^3).","category":"page"},{"location":"network-data/#GasPowerModels-Network-Data-Format","page":"Network Data Format","title":"GasPowerModels Network Data Format","text":"","category":"section"},{"location":"network-data/#The-Network-Data-Dictionary","page":"Network Data Format","title":"The Network Data Dictionary","text":"","category":"section"},{"location":"network-data/","page":"Network Data Format","title":"Network Data Format","text":"Internally, GasPowerModels uses a dictionary to store network data for power systems (see PowerModels) and gas models (see GasModels.jl). The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange. The I/O for GasPowerModels utilizes the serializations available in PowerModels.jl and GasModels.jl to construct the two network models. All data is assumed to be in per unit (non-dimenisionalized) or SI units.","category":"page"},{"location":"network-data/","page":"Network Data Format","title":"Network Data Format","text":"Besides the standard network data supported by GasModels.jl and PowerModels.jl, there are a few extra fields that are required to couple the two systems together. These are discussed as follows:","category":"page"},{"location":"network-data/#Gas-Networks","page":"Network Data Format","title":"Gas Networks","text":"","category":"section"},{"location":"network-data/","page":"Network Data Format","title":"Network Data Format","text":"{\n    \"energy_factor\": <Float64>,      # Factor for converting the Joules per second used by a generator to m^3 per second gas consumption. SI units are m^3 per Joules.\n    \"price_zone\": {\n        \"1\": {\n          \"cost_q_1\": <Float64>,     # Quadratic coefficient on the cost curve for non-firm gas consumed in the zone. SI units are dollars per m^3 at standard pressure.\n          \"cost_q_2\": <Float64>,     # Linear coefficient on the cost curve for non-firm gas consumed in the zone. SI units are dollars per m^3 at standard pressure.\n          \"cost_q_3\": <Float64>,     # Constant term on the cost curve for non-firm gas consumed in the zone. SI units are dollars per m^3 at standard pressure.\n          \"cost_p_1\": <Float64>,     # Quadratic coefficient on the cost curve for pressure squared in the zone. SI units are dollars per Pascal^2.\n          \"cost_p_2\": <Float64>,     # Linear coefficient on the cost curve for pressure squared in the zone. SI units are dollars per Pascal^2.\n          \"cost_p_3\": <Float64>,     # Constant term on the cost curve for pressure squared in the zone. SI units are dollars per Pascal^2.\n          \"min_cost\": <Float64>,     # Minimum cost per unit of non-firm gas consumed in the zone. SI units are dollars per m^3 at standard pressure.\n          \"constant_p\": <Float64>,   # Bias factor for weighting pressure penalty cost relative to demand penalty cost.\n           ...\n        },\n        \"2\": {\n            ...\n        },\n        ...\n    },\n    \"junction\": {\n        \"1\": {\n          \"price_zone\": <Int64>        # Index of the corresponding price zone for the junction. -1 implies no zone.\n          ...\n        },\n        \"2\": {\n          ...\n        },\n        ...\n    },\n    ...\n}","category":"page"},{"location":"network-data/#Power-Networks","page":"Network Data Format","title":"Power Networks","text":"","category":"section"},{"location":"network-data/","page":"Network Data Format","title":"Network Data Format","text":"{\n\"gen\":{\n    \"1\":{\n       \"heat_rate_quad_coeff\": <Float64>,      # Quadratic term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second   \n       \"heat_rate_linear_coeff\": <Float64>,    # Linear term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second   \n       \"heat_rate_constant_coeff\": <Float64>,  # Constant term of a heat rate curve that converts MW into J/s. SI Units are J per MW produced in a second\n       ...\n    },\n    \"2\": {\n      ...\n    },\n    ...\n}","category":"page"},{"location":"developer/#Developer-Documentation","page":"Developer","title":"Developer Documentation","text":"","category":"section"},{"location":"parser/#File-IO","page":"File IO","title":"File IO","text":"","category":"section"},{"location":"parser/","page":"File IO","title":"File IO","text":"Parsing uses the native parsing features of GasModels.jl and PowerModels.jl.","category":"page"},{"location":"quickguide/#Quick-Start-Guide","page":"Getting Started","title":"Quick Start Guide","text":"","category":"section"},{"location":"quickguide/#Installation","page":"Getting Started","title":"Installation","text":"","category":"section"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"The latest stable release of GasPowerModels can be installed using the Julia package manager with","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"] add GasPowerModels","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"For the current development version, install the package using","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"] add GasPowerModels#master","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"Finally, test that the package works as expected by executing","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"] test GasPowerModels","category":"page"},{"location":"quickguide/#Installation-of-Optimization-Solvers","page":"Getting Started","title":"Installation of Optimization Solvers","text":"","category":"section"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"At least one optimization solver is required to run GasPowerModels. The solver selected typically depends on the type of problem formulation being employed. As an example, the mixed-integer nonlinear programming solver Juniper can be used for testing any of the problem formulations considered in this package. Juniper itself depends on the installation of a nonlinear programming solver (e.g., Ipopt) and a mixed-integer linear programming solver (e.g., CBC). Installation of the JuMP interfaces to Juniper, Ipopt, and Cbc can be performed via the Julia package manager, i.e.,","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"] add JuMP Juniper Ipopt Cbc","category":"page"},{"location":"quickguide/#Solving-a-Problem","page":"Getting Started","title":"Solving a Problem","text":"","category":"section"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"Once the above dependencies have been installed, obtain the files belgian-ne_opf.m and case14-ne.m. Here, belgian-ne_opf.m is a MATGAS file describing a portion of the Belgian gas network. In accord, case14-ne.m is a MATPOWER file specifying a 14-bus power network. The combination of data from these two files provides the required information to set up the problem. After downloading the data, the optimal power flow with network expansion problem can be solved with","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"using JuMP, Juniper, Ipopt, Cbc\nusing GasPowerModels\n\n# Set up the optimization solvers.\nipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, \"print_level\"=>0, \"sb\"=>\"yes\")\ncbc = JuMP.optimizer_with_attributes(Cbc.Optimizer, \"logLevel\"=>0)\njuniper = JuMP.optimizer_with_attributes(Juniper.Optimizer, \"nl_solver\"=>ipopt, \"mip_solver\"=>cbc)\n\n# Specify paths to the gas and power network files.\ng_file = \"examples/data/matgas/belgian-ne_opf.m\" # Gas network.\np_file = \"examples/data/matpower/case14-ne.m\" # Power network.\n\n# Specify the gas and power formulation types separately.\ng_type, p_type = CRDWPGasModel, SOCWRPowerModel\n\n# Solve the optimal power flow with network expansion problem.\nresult = run_ne_opf(g_file, p_file, g_type, p_type, juniper;\n    gm_solution_processors=[GasPowerModels._GM.sol_psqr_to_p!],\n    pm_solution_processors=[GasPowerModels._PM.sol_data_model!])","category":"page"},{"location":"quickguide/#Obtaining-Results","page":"Getting Started","title":"Obtaining Results","text":"","category":"section"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"The run commands in GasPowerModels return detailed results data in the form of a Julia Dict. This dictionary can be saved for further processing as follows:","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"result = run_ne_opf(g_file, p_file, g_type, p_type, juniper;\n    gm_solution_processors=[GasPowerModels._GM.sol_psqr_to_p!],\n    pm_solution_processors=[GasPowerModels._PM.sol_data_model!])","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"For example, the algorithm's runtime and final objective value can be accessed with","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"result[\"solve_time\"] # Total solve time required (seconds).\nresult[\"objective\"] # Final objective value (in units of the objective).","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"The \"solution\" field contains detailed information about the solution produced by the run method. For example, the following can be used to read the build status of the network expansion pipe in the gas system","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"result[\"solution\"][\"ne_pipe\"][\"16\"][\"z\"]","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"As another example, the following can be used to inspect pressures in the solution","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"Dict(name => data[\"p\"] for (name, data) in result[\"solution\"][\"junction\"])","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"As a final example, the following can be used to inspect real power generation in the solution","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"Dict(name => data[\"pg\"] for (name, data) in result[\"solution\"][\"gen\"])","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"For more information about GasPowerModels result data, see the GasPowerModels Result Data Format section.","category":"page"},{"location":"quickguide/#Accessing-Different-Formulations","page":"Getting Started","title":"Accessing Different Formulations","text":"","category":"section"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"To solve the preceding problem using the mixed-integer nonconvex model for natural gas flow, the following can be executed:","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"# Specify the gas and power formulation types separately.\ng_type, p_type = DWPGasModel, SOCWRPowerModel\n\n# Solve the optimal power flow with network expansion problem.\nresult = run_ne_opf(g_file, p_file, g_type, p_type, juniper;\n    gm_solution_processors=[GasPowerModels._GM.sol_psqr_to_p!],\n    pm_solution_processors=[GasPowerModels._PM.sol_data_model!])","category":"page"},{"location":"quickguide/#Modifying-Network-Data","page":"Getting Started","title":"Modifying Network Data","text":"","category":"section"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"The following example demonstrates one way to perform GasPowerModels solves while modifying network data.","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"# Read in the gas and power network data.\ng_data = GasPowerModels._GM.parse_file(g_file)\np_data = GasPowerModels._PM.parse_file(p_file)\n\n# Ensure the two datasets use the same units for power.\nresolve_units!(g_data, p_data)\n\n# Reduce the minimum pressures for selected nodes.\ng_data[\"junction\"][\"1\"][\"p_min\"] *= 0.1\ng_data[\"junction\"][\"2\"][\"p_min\"] *= 0.1\ng_data[\"junction\"][\"3\"][\"p_min\"] *= 0.1\n\n# Solve the problem using `g_data` and `p_data`.\nresult_mod = run_ne_opf(g_data, p_data, g_type, p_type, juniper;\n    gm_solution_processors=[GasPowerModels._GM.sol_psqr_to_p!],\n    pm_solution_processors=[GasPowerModels._PM.sol_data_model!])","category":"page"},{"location":"quickguide/#Alternate-Methods-for-Building-and-Solving-Models","page":"Getting Started","title":"Alternate Methods for Building and Solving Models","text":"","category":"section"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"The following example demonstrates how to decompose a run_ne_opf call into separate model building and solving steps. This allows inspection of the JuMP model created by GasPowerModels:","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"# Read in the gas and power network data.\ng_data = GasPowerModels._GM.parse_file(g_file)\np_data = GasPowerModels._PM.parse_file(p_file)\n\n# Ensure the two datasets use the same units for power.\nresolve_units!(g_data, p_data)\n\n# Store the required `ref` extensions for the problem.\ngm_ref_extensions = [GasPowerModels._GM.ref_add_ne!, ref_add_price_zones!]\npm_ref_extensions = [GasPowerModels._PM.ref_add_on_off_va_bounds!, GasPowerModels._PM.ref_add_ne_branch!]\n\n# Instantiate the model.\ngm, pm = instantiate_model(g_data, p_data, g_type, p_type, build_ne_opf,\n    gm_ref_extensions=gm_ref_extensions, pm_ref_extensions=pm_ref_extensions)\n\n# Print the contents of the JuMP model.\nprintln(gm.model)","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"The problem can then be solved and its two result dictionaries can be stored via:","category":"page"},{"location":"quickguide/","page":"Getting Started","title":"Getting Started","text":"# Create separate gas and power result dictionaries.\ngas_result = GasPowerModels._IM.optimize_model!(gm, optimizer=juniper)\npower_result = GasPowerModels._IM.build_result(pm, gas_result[\"solve_time\"])","category":"page"},{"location":"constraints/#Constraints","page":"Constraints","title":"Constraints","text":"","category":"section"},{"location":"constraints/","page":"Constraints","title":"Constraints","text":"Modules = [GasPowerModels]\nPages   = [\"core/constraint_template.jl\"]\nOrder   = [:type, :function]\nPrivate  = true","category":"page"},{"location":"constraints/#GasPowerModels.constraint_pressure_price-Tuple{GasModels.AbstractGasModel,Int64}","page":"Constraints","title":"GasPowerModels.constraint_pressure_price","text":"Constraint that relates the pressure price to the price zone.\n\n\n\n\n\n","category":"method"},{"location":"constraints/#GasPowerModels.constraint_zone_demand-Tuple{GasModels.AbstractGasModel,Int64}","page":"Constraints","title":"GasPowerModels.constraint_zone_demand","text":"Constraint that bounds demand zone price using delivery flows within the zone.\n\n\n\n\n\n","category":"method"},{"location":"constraints/#GasPowerModels.constraint_zone_demand_price-Tuple{GasModels.AbstractGasModel,Int64}","page":"Constraints","title":"GasPowerModels.constraint_zone_demand_price","text":"constraints associated with bounding the demand zone prices  This is equation 22 in the HICCS paper\n\n\n\n\n\n","category":"method"},{"location":"model/#Gas-Grid-Model","page":"GasGridModel","title":"Gas Grid Model","text":"","category":"section"},{"location":"model/","page":"GasGridModel","title":"GasGridModel","text":"A gas grid model is defined in terms of a GasModel and a PowerModel.","category":"page"},{"location":"specifications/#Problem-Specifications","page":"Problem Specifications","title":"Problem Specifications","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"In these specifications, pm refers to a PowerModels model and gm refers to a GasModels model.","category":"page"},{"location":"specifications/#Gas-Power-Flow-(GPF)","page":"Problem Specifications","title":"Gas-Power Flow (GPF)","text":"","category":"section"},{"location":"specifications/#Inherited-Variables-and-Constraints","page":"Problem Specifications","title":"Inherited Variables and Constraints","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# Gas-only related variables and constraints\n_GM.build_gf(gm)\n\n# Power-only related variables and constraints\n_PM.build_pf(pm)","category":"page"},{"location":"specifications/#Constraints","page":"Problem Specifications","title":"Constraints","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# Gas-power related parts of the problem formulation.\nfor i in _GM.ids(gm, :delivery)\n    constraint_heat_rate_curve(pm, gm, i)\nend","category":"page"},{"location":"specifications/#Optimal-Gas-Power-Flow-(OGPF)","page":"Problem Specifications","title":"Optimal Gas Power Flow (OGPF)","text":"","category":"section"},{"location":"specifications/#Objective","page":"Problem Specifications","title":"Objective","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# This objective function minimizes operation cost.\nobjective_min_opf_cost(gm, pm)","category":"page"},{"location":"specifications/#Inherited-Variables-and-Constraints-2","page":"Problem Specifications","title":"Inherited Variables and Constraints","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# Gas-only related variables and constraints\n_GM.build_gf(gm)\n\n# Power-only related variables and constraints\n_PM.build_pf(pm)","category":"page"},{"location":"specifications/#Variables","page":"Problem Specifications","title":"Variables","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# Variables related to the OGPF problem.\nvariable_zone_demand(gm)\nvariable_zone_demand_price(gm)\nvariable_zone_pressure(gm)\nvariable_pressure_price(gm)","category":"page"},{"location":"specifications/#Constraints-2","page":"Problem Specifications","title":"Constraints","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# Gas-power related parts of the problem formulation.\nfor i in _GM.ids(gm, :delivery)\n    constraint_heat_rate_curve(pm, gm, i)\nend\n\n# Constraints related to price zones.\nfor (i, price_zone) in _GM.ref(gm, :price_zone)\n    constraint_zone_demand(gm, i)\n    constraint_zone_demand_price(gm, i)\n    constraint_zone_pressure(gm, i)\n    constraint_pressure_price(gm, i)\nend","category":"page"},{"location":"specifications/#Network-Expansion-Planning-(NE)","page":"Problem Specifications","title":"Network Expansion Planning (NE)","text":"","category":"section"},{"location":"specifications/#Objective-2","page":"Problem Specifications","title":"Objective","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# This objective function minimizes cost of network expansion.\nobjective_min_ne_cost(pm, gm)","category":"page"},{"location":"specifications/#Inherited-Variables-and-Constraints-3","page":"Problem Specifications","title":"Inherited Variables and Constraints","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# Gas-only-related variables and constraints.\n_GM.build_nels(gm)\n\n# Power-only-related variables and constraints.\n_PM.build_tnep(pm)","category":"page"},{"location":"specifications/#Constraints-3","page":"Problem Specifications","title":"Constraints","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# Gas-power related constraints of the problem formulation.\nfor i in _GM.ids(gm, :delivery)\n   constraint_heat_rate_curve(pm, gm, i)\nend","category":"page"},{"location":"specifications/#Expansion-Planning-with-Optimal-Gas-Power-Flow-(NE-OGPF)","page":"Problem Specifications","title":"Expansion Planning with Optimal Gas-Power Flow (NE OGPF)","text":"","category":"section"},{"location":"specifications/#Objective-3","page":"Problem Specifications","title":"Objective","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# Objective function minimizes network expansion, demand, and pressure cost.\nobjective_min_ne_opf_cost(pm, gm)","category":"page"},{"location":"specifications/#Inherited-Variables-and-Constraints-4","page":"Problem Specifications","title":"Inherited Variables and Constraints","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# Gas-only-related variables and constraints.\n_GM.build_nels(gm)\n\n# Power-only-related variables and constraints.\n_PM.build_tnep(pm)","category":"page"},{"location":"specifications/#Variables-2","page":"Problem Specifications","title":"Variables","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# Variables related to the NE OGPF problem.\nvariable_zone_demand(gm)\nvariable_zone_demand_price(gm)\nvariable_zone_pressure(gm)\nvariable_pressure_price(gm)","category":"page"},{"location":"specifications/#Constraints-4","page":"Problem Specifications","title":"Constraints","text":"","category":"section"},{"location":"specifications/","page":"Problem Specifications","title":"Problem Specifications","text":"# Constraints related to price zones.\nfor (i, price_zone) in _GM.ref(gm, :price_zone)\n    constraint_zone_demand(gm, i)\n    constraint_zone_demand_price(gm, i)\n    constraint_zone_pressure(gm, i)\n    constraint_pressure_price(gm, i)\nend","category":"page"},{"location":"result-data/#GasPowerModels-Result-Data-Format","page":"Result Data Format","title":"GasPowerModels Result Data Format","text":"","category":"section"},{"location":"result-data/#The-Result-Data-Dictionary","page":"Result Data Format","title":"The Result Data Dictionary","text":"","category":"section"},{"location":"result-data/","page":"Result Data Format","title":"Result Data Format","text":"GasPowerModels uses a dictionary to organize the results of a run_ command. The dictionary uses strings as key values so it can be serialized to JSON for algorithmic data exchange. The data dictionary organization is designed to be consistent with the GasPowerModels The Network Data Dictionary.","category":"page"},{"location":"result-data/","page":"Result Data Format","title":"Result Data Format","text":"At the top level the results data dictionary is structured as follows:","category":"page"},{"location":"result-data/","page":"Result Data Format","title":"Result Data Format","text":"{\n    \"optimizer\": <string>,                # name of the JuMP optimizer used to solve the model\n    \"termination_status\": <julia symbol>, # solver status at termination\n    \"dual_status\": <julia symbol>,        # dual feasibility status at termination\n    \"primal_status\": <julia symbol>,      # primal feasibility status at termination\n    \"solve_time\": <float>,                # reported time required for solution\n    \"objective\": <float>,                 # the final evaluation of the objective function\n    \"objective_lb\": <float>,              # the final lower bound of the objective function (if available)\n    \"solution\": {...}                     # problem solution information (details below)\n}","category":"page"},{"location":"result-data/#Solution-Data","page":"Result Data Format","title":"Solution Data","text":"","category":"section"},{"location":"result-data/","page":"Result Data Format","title":"Result Data Format","text":"The solution object provides detailed information about the problem solution produced by the run command. The solution is organized similarly to The Network Data Dictionary with the same nested structure and parameter names, when available. A network solution most often only includes a small subset of the data included in the network data. For example the data for a gas network junction, e.g., g_data[\"junction\"][\"1\"] is structured as follows:","category":"page"},{"location":"result-data/","page":"Result Data Format","title":"Result Data Format","text":"{\n    \"lat\": 0.0,\n    ...\n}","category":"page"},{"location":"result-data/","page":"Result Data Format","title":"Result Data Format","text":"A solution specifying a pressure for the same object, i.e., result[\"solution\"][\"junction\"][\"1\"], would result in,","category":"page"},{"location":"result-data/","page":"Result Data Format","title":"Result Data Format","text":"{\n    \"psqr\": 0.486908,\n    \"p\": 0.697788\n}","category":"page"},{"location":"result-data/","page":"Result Data Format","title":"Result Data Format","text":"Because the data dictionary and the solution dictionary have the same structure, the InfrastructureModels update_data! helper function can be used to update a data dictionary with values from a solution, e.g.,","category":"page"},{"location":"result-data/","page":"Result Data Format","title":"Result Data Format","text":"GasPowerModels._IM.update_data!(g_data[\"junction\"][\"1\"], result[\"solution\"][\"junction\"][\"1\"])","category":"page"},{"location":"result-data/","page":"Result Data Format","title":"Result Data Format","text":"By default, all results are reported per-unit (non-dimensionalized). Functions from GasModels and PowerModels can be used to convert such data back to their dimensional forms.","category":"page"},{"location":"formulations/#Network-Formulations","page":"Network Formulations","title":"Network Formulations","text":"","category":"section"},{"location":"formulations/","page":"Network Formulations","title":"Network Formulations","text":"The network formulations for joint gas-power modeling use the formulations defined in GasModels.jl and PowerModels.jl.","category":"page"},{"location":"variables/#Variables","page":"Variables","title":"Variables","text":"","category":"section"},{"location":"variables/","page":"Variables","title":"Variables","text":"We provide the following methods to provide a compositional approach for defining common variables used in coupled gas grid flow models. These methods should always be defined over AbstractGasModel and/or AbstractPowerModel.","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"Modules = [GasPowerModels]\nPages   = [\"core/variable.jl\"]\nOrder   = [:type, :function]\nPrivate  = true","category":"page"},{"location":"variables/#GasPowerModels.getstart","page":"Variables","title":"GasPowerModels.getstart","text":"extracts the start value \n\n\n\n\n\n","category":"function"},{"location":"variables/#GasPowerModels.variable_pressure_price","page":"Variables","title":"GasPowerModels.variable_pressure_price","text":"Initializes variables associated with zonal pressure cost.\n\n\n\n\n\n","category":"function"},{"location":"variables/#GasPowerModels.variable_zone_demand","page":"Variables","title":"GasPowerModels.variable_zone_demand","text":"function for creating variables associated with zonal demand \n\n\n\n\n\n","category":"function"},{"location":"variables/#GasPowerModels.variable_zone_demand_price","page":"Variables","title":"GasPowerModels.variable_zone_demand_price","text":"function for creating variables associated with zonal demand \n\n\n\n\n\n","category":"function"},{"location":"variables/#GasPowerModels.variable_zone_pressure","page":"Variables","title":"GasPowerModels.variable_zone_pressure","text":"Initializes variables associated with zonal demand.\n\n\n\n\n\n","category":"function"},{"location":"objective/#Objective","page":"Objective","title":"Objective","text":"","category":"section"},{"location":"objective/","page":"Objective","title":"Objective","text":"Modules = [GasPowerModels]\nPages   = [\"core/objective.jl\"]\nOrder   = [:function]\nPrivate  = true","category":"page"},{"location":"objective/#GasPowerModels.objective_min_ne_cost-Tuple{PowerModels.AbstractPowerModel,GasModels.AbstractGasModel}","page":"Objective","title":"GasPowerModels.objective_min_ne_cost","text":"Objective that minimizes expansion costs only (as in the HICCS paper).\n\n\n\n\n\n","category":"method"},{"location":"#GasPowerModels.jl-Documentation","page":"Home","title":"GasPowerModels.jl Documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = GasPowerModels","category":"page"},{"location":"#Overview","page":"Home","title":"Overview","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"GasPowerModels.jl is a Julia/JuMP package for the joint optimization of steady state natural gas and power transmission networks. It provides utilities for modeling problems that combine elements of natural gas and electric power systems. It is designed to enable the computational evaluation of historical and emerging gas-power network optimization formulations and algorithms using a common platform. The code is engineered to decouple Problem Specifications (e.g., gas-power flow, network expansion planning) from Network Formulations (e.g., mixed-integer linear, mixed-integer nonlinear). This decoupling enables the definition of a variety of optimization formulations and their comparison on common problem specifications.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The latest stable release of GasPowerModels can be installed using the Julia package manager with","category":"page"},{"location":"","page":"Home","title":"Home","text":"] add GasPowerModels","category":"page"},{"location":"","page":"Home","title":"Home","text":"For the current development version, install the package using","category":"page"},{"location":"","page":"Home","title":"Home","text":"] add GasPowerModels#master","category":"page"},{"location":"","page":"Home","title":"Home","text":"Finally, test that the package works as expected by executing","category":"page"},{"location":"","page":"Home","title":"Home","text":"] test GasPowerModels","category":"page"},{"location":"#Usage-at-a-Glance","page":"Home","title":"Usage at a Glance","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"At least one optimization solver is required to run GasPowerModels. The solver selected typically depends on the type of problem formulation being employed. As an example, the mixed-integer nonlinear programming solver Juniper can be used for testing any of the problem formulations considered in this package. Juniper itself depends on the installation of a nonlinear programming solver (e.g., Ipopt) and a mixed-integer linear programming solver (e.g., CBC). Installation of the JuMP interfaces to Juniper, Ipopt, and Cbc can be performed via the Julia package manager, i.e.,","category":"page"},{"location":"","page":"Home","title":"Home","text":"] add JuMP Juniper Ipopt Cbc","category":"page"},{"location":"","page":"Home","title":"Home","text":"After installation of the required solvers, an example gas-power flow feasibility problem (whose file inputs can be found in the examples directory within the GasPowerModels repository) can be solved via","category":"page"},{"location":"","page":"Home","title":"Home","text":"using JuMP, Juniper, Ipopt, Cbc\nusing GasPowerModels\n\n# Set up the optimization solvers.\nipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, \"print_level\"=>0, \"sb\"=>\"yes\")\ncbc = JuMP.optimizer_with_attributes(Cbc.Optimizer, \"logLevel\"=>0)\njuniper = JuMP.optimizer_with_attributes(Juniper.Optimizer, \"nl_solver\"=>ipopt, \"mip_solver\"=>cbc)\n\n# Specify paths to the gas and power network files.\ng_file = \"examples/data/matgas/belgian.m\" # Gas network.\np_file = \"examples/data/matpower/case14.m\" # Power network.\n\n# Specify the gas and power formulation types separately.\ng_type, p_type = CRDWPGasModel, SOCWRPowerModel\n\n# Solve the gas-power flow feasibility problem.\nresult = run_gpf(g_file, p_file, g_type, p_type, juniper;\n    gm_solution_processors=[GasPowerModels._GM.sol_psqr_to_p!],\n    pm_solution_processors=[GasPowerModels._PM.sol_data_model!])","category":"page"},{"location":"","page":"Home","title":"Home","text":"After solving the problem, results can then be analyzed, e.g.,","category":"page"},{"location":"","page":"Home","title":"Home","text":"# The termination status of the optimization solver.\nresult[\"termination_status\"]\n\n# Generator 1's real power generation.\nresult[\"solution\"][\"gen\"][\"1\"][\"pg\"]\n\n# Junction 1's pressure.\nresult[\"solution\"][\"junction\"][\"1\"][\"p\"]","category":"page"}]
}