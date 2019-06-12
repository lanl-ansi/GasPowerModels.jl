# GasPowerModels.jl Documentation

```@meta
CurrentModule = GasPowerModels
```

## Overview

GasPowerModels.jl is a Julia/JuMP package for Steady-State Gas Network Optimization. It provides utilities for modeling problems that combine elements of natural gas and electric power systems. It is designed to enable computational evaluation of emerging gas and power network formulations and algorithms in a common platform.

The code is engineered to decouple [Problem Specifications](@ref) (e.g. Flow, Expansion Planning, ...) from [Network Formulations](@ref) (e.g. MINLP, MISOC-relaxation, ...). This enables the definition of a wide variety of coupled network formulations and their comparison on common problem specifications.

## Installation

The latest stable release of GasPowerModels will be installed using the Julia package manager with

```julia
Pkg.add("GasPowerModels")
```

For the current development version, "checkout" this package with

```julia
Pkg.checkout("GasPowerModels")
```

At least one solver is required for running GasModels.  The open-source solver Pavito is recommended and can be used to solve a wide variety of the problems and network formulations provided in GasModels.  The Pavito solver can be installed via the package manager with

```julia
Pkg.add("Pavito")
```

Test that the package works by running

```julia
Pkg.test("GasPowerModels")
```
