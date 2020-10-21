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

The convention adopting when deriving a relaxation or approximation of a non convex constraint that links a natural gas model and an electric power model is to relax or approximate the linking constraint according to the most "complex" infrastructure model.  So, for example, if the natural gas formulation uses a linear representation and the electric power model uses a quadractic representation, then the linking constraint uses the tightest possible relaxation using linear and quadractic equations.
