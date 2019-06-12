# The GasPowerModels Mathematical Model

As GasPowerModels implements a variety of coupled gas grid network optimization problems, the implementation is the best reference for precise mathematical formulations.  This section provides a mathematical specification for a prototypical coupled gas grid Flow problem, to provide an overview of the typical mathematical models in GasPowerModels.


## Coupled Gas Electric Power Flow

GasPowerModels implements a steady-state model of gas flow and power flow based on the implementations of gas flows in GasModels.jl and power flows in PowerModels.jl.  The key coupling constraint between
power and gas systems is through generators that consume gas to produce power.  This is expressed in terms of a heat rate curve, i.e.

```math
f = e * \rho (h_2 * pg^2 + h_1 * pg + h_0)
```
where $h$ is a quadratic function used to convert MW ($pg$) into Joules consumed per second. This is then converted to mass flow, $f$, (kg/s) of gas consumed to produce this energy. Here, $e$ is an energy factor (m^3/s) and $\rho$ is standard density (kg/m^3).

