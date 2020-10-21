# The GasPowerModels Mathematical Model
As GasPowerModels implements a variety of coupled gas grid network optimization problems, the implementation is the best reference for precise mathematical formulations.
This section provides a mathematical specification for constraints and physics that couple electric power and natural gas and provides an overview of the typical mathematical models in
GasPowerModels.


## Coupled Gas Electric Power Flow
GasPowerModels implements a steady-state model of gas flow and power flow based on the implementations of gas flows in GasModels.jl and power flows in PowerModels.jl.
The key coupling constraint between power and gas systems is through generators that consume gas to produce power.
This is expressed in terms of a heat rate curve, i.e.
```math
f = e * \rho (h_2 * pg^2 + h_1 * pg + h_0)
```
where $h$ is a quadratic function used to convert MW ($pg$) into Joules consumed per second (J/s). $h$ is in units of (J/MW^2, J/MW, J).
This is then converted to mass flow, $f$, (kg/s) of gas consumed to produce this energy.
Here, $e$ is an energy factor (m^3/J) and $\rho$ is standard density (kg/m^3).

## Co Optimization of Natural Gas and Electric Power

One of the largest challenges associated with modeling coupled natural gas and electric power systems is defining objective functions that span both systems. Each system has its own units, both in terms of actual quantities and methods for non dimensionalizing the equations to improve numerical performance. Further, the importance of optimizing the gas system relative to the electric power system may be problem specific. Thus, the native implementations of ``GasPowerModels`` support the ability to model a wide variety of components of a joint objective function and define weights on each component.  Each component of the objective function is defined in the space of non dimensionalized units, and these weighting constants can be used to transform the quantities into their real units.

### Expansion costs of electric power components

Some gas grid problems include network expansions on electric power lines. Objective functions which model the cost of electric power lines minimize a function of the form

```math
foo
```

### Expansion costs of natural gas=components

### Operation costs of non natural gas generators

### Cost for gas in a pricing zone

### Cost for gas
