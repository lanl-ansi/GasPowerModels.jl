# Network Formulations
The network formulations for joint gas-power modeling use the formulations defined in GasModels.jl and PowerModels.jl.


# GasPower Model

```@meta
CurrentModule = GasPowerModels
```

All methods for constructing a ``GasModel`` and a ``PowerModel`` should be defined with the type ``GasModels.AbstractGasModel`` and ``PowerModels.AbstractPowerModel``, respectively. ``GasPowerModels`` utilizes the following (internal) functions to construct a ``GasModel``, a ``PowerModel``, and their interrelationships :

```@docs
instantiate_model
```

# Network Formulations

## Type Hierarchy

``GasPowerModels`` inherit the type hierarchy of ``GasModels`` and ``PowerModels`` and functions are dispatched based on the choice of types for each of models. An example is the function


```@docs
constraint_heat_rate_curve
```
