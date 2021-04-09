## Algorithmic Utilities

### solve_mld
This utility serves as a convenient interface for examining the tradeoffs between lexicographic gas-power maximal load delivery (MLD) and weighted MLD problem formulations.
The primary functional interface is
```julia
solve_mld(data, model_type, build_method, optimizer, alpha; relax_integrality, kwargs...)
```
Here, `data` is the joint network data dictionary; `model_type` is the model formulation (e.g., `GasPowerModel{CRDWPGasModel, SOCWRPowerModel}`); `build_method` is the build function for the problem specification (i.e., `build_mld` for a problem where generator and bus statuses are continuously relaxed and `build_mld_uc` for a problem where these statuses are treated as discrete); `optimizer` is the solver to be used for optimization; `alpha` is a continuous tradeoff parameter, which should be between zero and one, where zero corresponds to prioritizing active power delivery first, and one corresponds to prioritizing nongeneration gas delivery first; and `relax_integrality` is a Boolean variable indicating whether or not the continuous relaxation of the problem should be solved (`false` by default).

Notably, the algorithm ultimately used to solve the MLD problem is dependent on the selection of `alpha`.
If `alpha = 1`, a lexicographic algorithm is used that first solves an optimization problem that maximizes nongeneration gas delivery, then solves a second-stage optimization problem that maximizes active power load delivery.
Within the second-stage problem, a constraint is applied that ensures the total nongeneration gas load in the second-stage is greater than or equal to the nongeneration gas load in the first stage.
Similarly, when `alpha = 0`, a lexicographic algorithm is used that first solves an optimization problem that maximizes active power delivery, then solves a second-stage optimization problem that maximizes nongeneration gas delivery.
Note that both of these algorithms are sometimes numerically sensitive, as the application of the second-stage constraint can sometimes result in the second-stage problem being classified as infeasible due to numerical tolerance.
To alleviate this, the second-stage constraint's tolerance (currently hard coded) could be loosened, or a more direct lexicographic optimization could be implemented using a solver interface that supports it (e.g., Gurobi).
The current implementation of each lexicographic algorithm is solver-independent.

When `alpha` is strictly between zero and one, a single-stage optimization problem is solved, where the weighting on the nongeneration gas portion of the objective is equal to `alpha` and the weighting on the active power portion of the objective is equal to `1 - alpha`.
Since this is a single-stage problem, the algorithm that solves is it typically more numerically stable than the lexicographic algorithms described above.
To gain a better understanding of the objective terms used in `solve_mld`, please read the [Maximal load delivery](@ref) section.

Aside from the typical data provided in a `result` dictionary, which is returned from the `solve_mld` method, a number of useful data are also computed and placed at the top level of the `result` dictionary.
These include `gas_load_served`, `gas_load_nonpower_served`, `active_power_served`, and `reactive_power_served`.
In redimensionalized units (i.e., `kg/s` and `MW`), these provide the total amount of gas demand served, total amount of nongeneration gas demand served, total amount of active power load served, and total amount of reactive power load served in the solution of the MLD problem.