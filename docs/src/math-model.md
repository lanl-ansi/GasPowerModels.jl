# The GasPowerModels Mathematical Model
As GasPowerModels implements a variety of coupled gas grid network optimization problems, the implementation is the best reference for precise mathematical formulations.
This section provides a mathematical specification for constraints and physics that couple electric power and natural gas and provides an overview of the typical mathematical models in GasPowerModels.

## Coupled Gas and Electric Power Flow
GasPowerModels implements steady state models of gas flow and power flow, based on the implementations of gas flows in GasModels.jl and power flows in PowerModels.jl.
The key coupling constraint between power and gas systems is through generators that consume gas to produce power.
This is expressed in terms of a heat rate curve, i.e.,
```math
f = e \rho \sum_{i \in \Gamma} (h^{0}_{i} * pg_{i}^2 + h^{1}_{i} * pg_{i} + h^{2}_{i})
```
where $h_{i}$ are coefficients of a quadratic function used to convert MW ($pg_{i}$) at a generator into Joules consumed per second.
Note that $h_{i}$ coefficients are in units of (J/MW^2, J/MW, J).
This is then converted to mass flow, $f$, (kg/s) of gas consumed at a delivery point to produce this energy.
Here, $e$ is an energy factor (m^3/J) and $\rho$ is the gas standard density (kg/m^3).

## Co-optimization of Natural Gas and Electric Power
One of the largest challenges associated with modeling coupled natural gas and electric power systems is defining objective functions that span both systems.
Each system has its own units, both in terms of actual quantities and methods for nondimensionalizing the equations to improve numerical performance.
Further, the importance of optimizing the gas system relative to the electric power system may be problem specific.
Thus, the native implementations of GasPowerModels support the ability to model a wide variety of components of a joint objective function and define weights on each component.
Each component of the objective function is defined in the space of nondimensionalized units, and these weighting constants can be used to (sometimes) transform the quantities into their real units.

### Expansion costs of electric power components
Some gas grid problems include network expansions on electric power lines.
Objective functions which model the cost of electric power lines minimize a function of the form
```math
 \sum_{a \in A^e} \kappa_{a} z_{a}
```
where ``A^e`` is the set of new electric power lines, ``\kappa_a`` is the cost of installing ``a``, and ``z_a`` is the binary variable for installing ``a``.
The constant term `power_ne_weight` can be provided as a parameter to weight this cost in an objective function.
The units of this term are dollars.

### Expansion costs of natural gas components
Some gas grid problems include network expansions on compressors and pipes.
Objective functions which model the costs of compressors and pipes minimize a function of the form
```math
 \sum_{a \in A^g} \kappa_{a} z_{a}
```
where ``A^g`` is the set of new pipes and compressors, ``\kappa_a`` is the cost of installing ``a``, and ``z_a`` is the binary variable for installing ``a``.
The constant term `gas_ne_weight` can be provided as a parameter to weight this cost in an objective function.
The units of this term are dollars.

### Operation costs of generators
Some gas grid problems include operation cost of electric power generators of the form
```math
\sum_{i \in \Gamma} \mu_2^i pg^2_i + \mu_1^i pg_i + \mu_0
```
where ``\Gamma`` is the set of generators and ``\mu`` are the coefficients of a quadratic function for computing the costs of operating generator ``i``. 
In `PowerModels` the units of ``\mu`` are dollars per PU hour and ``pg`` is expressed in the per unit system, so the costs are computed as dollars per MW hour.
To get these costs into SI units (for consistency with `GasModels`), the objective function computes dollars per PU second.
Thus, ``\mu_2 = \frac{\mu_2}{3600}``, ``\mu_1 = \frac{\mu_1}{3600}``, and ``\mu_0 = \frac{\mu_0}{3600}.``
The constant term `power_opf_weight` can be provided as a parameter to weight this cost in an objective function.
The units of this term are dollars per second.
In many applications, these costs for natural gas generators are set to zero so that the cost of gas generators is based only on the cost of gas consumed (as discussed in the following sections).
However, these costs can be set to nonzero values in order to model costs unrelated to fuel.

### Cost for gas in a pricing zone
Some gas-grid problems include a cost associated with the price of gas.
This part of the objective function prices gas as a function of flexible gas consumed in a zone. Reference

Russell Bent, Seth Blumsack, Pascal Van Hentenryck, Conrado Borraz-Sánchez, Mehdi Shahriari. Joint Electricity and Natural Gas Transmission Planning With Endogenous Market Feedbacks. IEEE Transactions on Power Systems. 33 (6):  6397-6409, 2018.

developed a pricing objective which computes the total cost (dollars per second) of flexible gas in a zone as the maximum of two functions.
The first function is
```math
m_2 \left(fl_z \frac{1}{\rho}\right)^2 + m_1 fl_z \frac{1}{\rho} + m_0
```
where ``fl_z`` is the total mass (kg/s) consumed in zone ``z``, ``\rho`` is standard density (kg/m^3), and ``m`` is a quadratic function with units of dollars per cubic meter per second.
The second function is a minimum price for gas, i.e.,
```math
C_z fl_z \frac{1}{\rho}
```
The units of this objective are dollars per second.
The constant term `gas_price_weight` can be provided as a parameter to weight this cost in an objective function.

### Penalty for pressure in a pricing zone
Some gas grid problems include a cost associated with the pressure of gas, which is used to model the amount of work that is required to deliver gas in a congested network. Reference

Russell Bent, Seth Blumsack, Pascal Van Hentenryck, Conrado Borraz-Sánchez, Mehdi Shahriari. Joint Electricity and Natural Gas Transmission Planning With Endogenous Market Feedbacks. IEEE Transactions on Power Systems. 33 (6):  6397 - 6409, 2018.

developed a penalty objective which computes this cost (in dollars) as the function
```math
n_2 \pi_z^2 + n_1 \pi_z + n_0
```
where  ``\pi`` is the maximum pressure squared in zone ``z`` and ``n`` is a quadratic function (dollars per pressure squared).
The units of this objective are dollars.
The constant term `gas_price_weight` can be provided as a parameter to weight this cost in an objective function.
Since the gas price has two terms, this term can be further weighted per zone with `constant_p`.
(Thus, the weight is `gas_price_weight * constant_p`)


### Maximal load delivery
The task of the Maximal Load Delivery (MLD) problem and its unit commitment variant (MLD UC) are to determine feasible steady-state operating points for severely damaged joint gas-power networks while ensuring the maximal delivery of gas and power loads simultaneously.
Specifically, the MLD problem maximizes the amount of _nongeneration_ gas load (i.e., gas demand uncommitted to electric power generators) and _active_ power load simultaneously.
Let the objective term relating to the amount of nongeneration gas load be defined by
```math
\eta_{G}(d) := \left(\sum_{i \in \mathcal{D}^{\prime}} \beta_{i} d_{i}\right) \left(\sum_{i \in \mathcal{D}^{\prime}} \beta_{i} \overline{d}_{i}\right)^{-1},
```
where ``\mathcal{D}^{\prime}`` is the set the delivery points in the gas network not connected to interdependent generators in the power network, ``\beta_{i} \in \mathbb{R}_{+}`` (equal to the `priority` property of the `delivery`) is a predefined restoration priority for delivery ``i \in \mathcal{D}^{\prime}``, ``d_{i}`` is the variable mass flow of gas delivered at ``i \in \mathcal{D}^{\prime}`` and ``\overline{d}_{i}`` is the maximum deliverable gas load at ``i \in \mathcal{D}^{\prime}``.
Next, let the objective term relating to the amount of active power load be defined by
```math
\eta_{P}(z^{d}) := \left(\sum_{i \in \mathcal{L}} \beta_{i} z_{i}^{d} \Re({S}_{i}^{d})\right) \left(\sum_{i \in \mathcal{L}} \beta_{i} \Re({S}_{i}^{d})\right)^{-1}.
```
Here, ``\mathcal{L}`` is the set of loads in the power network, ``\beta_{i} \in \mathbb{R}_{+}`` (equal to the `weight` property of the `load`) is the load restoration priority for load ``i \in \mathcal{L}``, and ``z_{i} \in [0, 1]`` is a variable that scales the maximum amount of active power load, ``\Re({S}_{i}^{d})``, at load ``i \in \mathcal{L}``.

Note that these two terms, ``\eta_{G}(d)`` and ``\eta_{P}(z^{d})``, are normalized between zero and one.
This allows for a more straightforward analysis of the tradeoffs involved in maximal gas and power delivery.
The objective natively supported by the `build_mld` and `build_mld_uc` methods is maximization of
```math
    \lambda_{G} \eta_{G}(d) + \lambda_{P} \eta_{P}(z^{d}),
```
where it is recommended that ``0 < \lambda_{G} < 1``, that `gm_load_priority` in the network data specification be set to the value of ``\lambda_{G}`` desired, and that `pm_load_priority` similarly be set to the value ``1 - \lambda_{G} = \lambda_{P}``.
This type of parameterization allows for a straightforward analysis of tradeoffs, as the objective is naturally scaled between zero and one.
Lexicographic optimization of the two objective terms (e.g., maximize gas delivery first, then power) can be performed via the `solve_mld` function described in the [Algorithmic Utilities](@ref) section.