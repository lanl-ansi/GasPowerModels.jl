# The GasPowerModels Mathematical Model
As GasPowerModels implements a variety of coupled gas grid network optimization problems, the implementation is the best reference for precise mathematical formulations.
This section provides a mathematical specification for constraints and physics that couple electric power and natural gas and provides an overview of the typical mathematical models in
GasPowerModels.


## Coupled Gas Electric Power Flow
GasPowerModels implements a steady-state model of gas flow and power flow based on the implementations of gas flows in GasModels.jl and power flows in PowerModels.jl.
The key coupling constraint between power and gas systems is through generators that consume gas to produce power.
This is expressed in terms of a heat rate curve, i.e.
```math
f = e * \rho \frac{h_2 * pg^2 + h_1 * pg + h_0}{3600}
```
where $h$ is a quadratic function used to convert MW per hour ($pg$) into Joules consumed per hour. This is divided by 3600 to get Joules per second (J/s). $h$ is in units of (J/MW^2, J/MW, J).
This is then converted to mass flow, $f$, (kg/s) of gas consumed to produce this energy.
Here, $e$ is an energy factor (m^3/J) and $\rho$ is standard density (kg/m^3).

## Co Optimization of Natural Gas and Electric Power

One of the largest challenges associated with modeling coupled natural gas and electric power systems is defining objective functions that span both systems. Each system has its own units, both in terms of actual quantities and methods for non dimensionalizing the equations to improve numerical performance. Further, the importance of optimizing the gas system relative to the electric power system may be problem specific. Thus, the native implementations of ``GasPowerModels`` support the ability to model a wide variety of components of a joint objective function and define weights on each component.  Each component of the objective function is defined in the space of non dimensionalized units, and these weighting constants can be used to (sometimes) transform the quantities into their real units.

### Expansion costs of electric power components

Some gas grid problems include network expansions on electric power lines. Objective functions which model the cost of electric power lines minimize a function of the form

```math
 \sum_{a \in A^e} \kappa_{a} z_{a}
```

where ```math A^e``` is the set of new electric power lines, ```math \kappa_a``` is the cost of installing ```math a```, and ```math z_a``` is the binary variable for a installing ```math a```. The constant term ``power_ne_weight`` can be provided as a parameter to weight this cost in an objective function. The units of this term is dollars.

### Expansion costs of natural gas=components

Some gas grid problems include network expansions on compressors and pipes. Objective functions which model the cost of compressors and pipes minimize a function of the form

```math
 \sum_{a \in A^g} \kappa_{a} z_{a}
```

where ```math A^g``` is the set of new pipes and compressors, ```math \kappa_a``` is the cost of installing ```math a```, and ```math z_a``` is the binary variable for a installing ```math a```. The constant term ``gas_ne_weight`` can be provided as a parameter to weight this cost in an objective function. The units of this term is dollars.

### Operation costs of generators

Some gas grid problems include operation cost of electric power generators of the form

```math
\sum_{i \in \Gamma} \mu_2^i pg^2_i + \mu_1^i pg_i + \mu_0
```

where ```\Gamma``` is the set of generators, ```math \mu``` is the coefficients of a quadractic function for computing the costs of operating generator ```math i```. In ```PowerModels``` the units of ```\mu``` are dollars per PU hour and ```math pg``` is expressed in the per unit system, so the costs are computed as dollars per MW hour. So, to get these costs into si units (for consistency with ``GasModels``), the objective function computes is dollars per second. Thus, ```math \mu_2 = \frac{\mu_2}{3600}```, ```math \mu_1 = \frac{\mu_1}{3600}``` and ```math \mu_0 = \frac{\mu_0}{3600}.```
The constant term ``power_opf_weight`` can be provided as a parameter to weight this cost in an objective function.
The units of this term is dollars per second.  In many applications, theses costs for natural gas generators are set to 0 so that the cost of gas generators is based only on the cost of gas
consumed (next sections), however, these costs can be set to non zero in order to model non fuel related costs.

### Cost for gas in a pricing zone

Some gas grid problems include a cost associated with the price of gas. This part of the objective function prices gas as function of flexible gas consumed in a zone. Reference

Russell Bent, Seth Blumsack, Pascal Van Hentenryck, Conrado Borraz-Sánchez, Mehdi Shahriari. Joint Electricity and Natural Gas Transmission Planning With Endogenous Market Feedbacks. IEEE Transactions on Power Systems. 33 (6):  6397 - 6409, 2018.

developed a pricing objective which computes the total cost (dollars per second) of flexible gas in a zone as the max of two functions.  The first function is

```math
m_2 * (fl_z * \frac{1.0}{\rho})^2 + m_1 * fl_z * \frac{1.0}{\\rho} + m_0
```
where ```math fl_z``` is the total mass (kg/s) consumed in zone ```math z```, ```math \rho```, is standard density (kg/m^3), and ```math m``` is a quadractic function with units of dollars per m^3 per second).

The second function is a minimum price for gas, i.e.,

```math
C_z * fl_z * \frac{1.0}{\rho}
```

The units of this objective is dollars per second. The constant term ``gas_price_weight`` can be provided as a parameter to weight this cost in an objective function.

### Penalty for pressure in a pricing zone

Some gas grid problems include a cost associated with the pressure of gas, which is used to model the amount of work is required to deliver gas in a congested network. Reference

Russell Bent, Seth Blumsack, Pascal Van Hentenryck, Conrado Borraz-Sánchez, Mehdi Shahriari. Joint Electricity and Natural Gas Transmission Planning With Endogenous Market Feedbacks. IEEE Transactions on Power Systems. 33 (6):  6397 - 6409, 2018.

developed a penalty objective which computes this cost (dollars) as the function

```math
n_2 * \pi_z^2 + n_1 * \pi_z + n_0
```

where  ```math \pi ``` is the maximum pressure squared in zone ```math z```, and ```math n``` is a quadratic function (dollars per pressure squared). The units of this objective is dollars. The constant term ``gas_price_weight`` can be provided as a parameter to weight this cost in an objective function.  Since the gas price has two terms, this term can be further weighted per zone with ``constant_p``. (Thus, the weight is `gas_price_weight * constant_p``)
