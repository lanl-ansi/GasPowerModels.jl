# GasGridModels.jl 

Dev:
[![Build Status](https://travis-ci.org/lanl-ansi/GasGridModels.jl.svg?branch=master)](https://travis-ci.org/lanl-ansi/GasGridModels.jl)
[![codecov](https://codecov.io/gh/lanl-ansi/GasGridModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/lanl-ansi/GasGridModels.jl)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://lanl-ansi.github.io/GasGridModels.jl/latest)

GasGridModels.jl is a Julia/JuMP package for Simultaneous Steady-State Natural Gas and Electric Power Network Optimization.
It is designed to enable computational evaluation of emerging Gas-Grid network formulations and algorithms in a common platform.
The code is engineered to decouple problem specifications (e.g. Flow, Expansion planning, ...) from the gas and power network formulations (e.g. MINLP, MISOCP, ...) defined in PowerModels.jl and GasModels.jl
This enables the definition of a wide variety of formulations and their comparison on common problem specifications.

**Core Problem Specifications**
* Flow (f)
* Expansion Planning (ne)

**Core Network Formulations**
* MINLP 
* MISOCP

## Installation

For the moment, GasGridModels.jl is not yet registered as a Julia package.  Hence, "clone" should be used instead of "add" for package installation,

`Pkg.clone("https://github.com/lanl-ansi/GasGridModels.jl.git")`

At least one solver is required for running GasModels.  Commercial or psuedo-commerical solvers seem to handle these problems much better than
some of the open source alternatives.  Gurobi and Cplex perform well on the MISOCP model, and SCIP handles the MINLP model reasonably well.


## Basic Usage

Once GasGridModels is installed, a solver is installed, and a network data file  has been acquired, a Gas-Grid Flow can be executed with,
```
using GasGridModels
using <solver_package>

run_gpf("foo_gasgrid.json", "foo_electricpower.json", "foo_gas.json", FooGasGridModel, FooPowerModel, FooGasModel, FooSolver())
```

Similarly, an expansion solver can be executed with,
```
run_ne("foo_gasgrid.json", "foo_electricpower.json", "foo_gas.json", FooGasGridModel, FooPowerModel, FooGasModel, FooSolver())
```

where FooGasModel is the implementation of the mathematical program of the Gas equations you plan to use (i.e. MINLPGasModel) and FooSolver is the JuMP solver you want to use to solve the optimization problem (i.e. IpoptSolver).


## Acknowledgments

The primary developer is Russell Bent, with significant contributions from Conrado Borraz-Sanchez, Pascal van Hentenryck, and Seth Blumsack.

Special thanks to Miles Lubin for his assistance in integrating with Julia/JuMP.


## License

This code is provided under a BSD license as part of the Multi-Infrastructure Control and Optimization Toolkit (MICOT) project, LA-CC-13-108.
