import Gurobi
import InfrastructureModels
import JSON
import JuMP

using GasPowerModels
const GPM = GasPowerModels

env = Gurobi.Env(); # Set up Gurobi optimizer environment.
optimizer = JuMP.optimizer_with_attributes(() -> Gurobi.Optimizer(env), "OutputFlag" => 0)
gas_path = "../examples/data/matgas/NG146.m"
power_path = "../examples/data/matpower/EP36.m"
link_path = "../examples/data/json/NG146-EP36.json"
damage_path = "../examples/data/json/damage_scenario.json"

data = GPM.parse_files(gas_path, power_path, link_path)
modifications = JSON.parsefile(damage_path)
InfrastructureModels.update_data!(data, modifications)
GPM.correct_network_data!(data)

gpm_type = GPM.GasPowerModel{CRDWPGasModel, SOCWRPowerModel}

for weight in [0.0, 0.381, 0.5, 0.605, 0.61, 1.0]
	result = GPM.solve_mld(data, gpm_type, build_mld_uc, optimizer, weight)
    gas_load_served = result["gas_load_nonpower_served"]
    power_load_served = result["active_power_served"]
    println("$(weight),$(gas_load_served),$(power_load_served)")
end
