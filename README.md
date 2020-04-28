# GasPowerModels.jl 

Dev:
[![Build Status](https://travis-ci.org/lanl-ansi/GasPowerModels.jl.svg?branch=master)](https://travis-ci.org/lanl-ansi/GasPowerModels.jl)
[![codecov](https://codecov.io/gh/lanl-ansi/GasPowerModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/lanl-ansi/GasPowerModels.jl)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://lanl-ansi.github.io/GasPowerModels.jl/latest)

GasPowerModels.jl is a Julia/JuMP package for Simultaneous Steady-State Natural Gas and Electric Power Network Optimization.
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

GasPowerModels.jl should be installed using the command

`add GasPowerModels`

At least one solver is required for running GasPowerModels.  Commercial or psuedo-commerical solvers seem to handle these problems much better than some of the open source alternatives.  Gurobi and Cplex perform well on the MISOCP model, and SCIP handles the MINLP model reasonably well.

## Basic Usage

Once GasPowerModels is installed, a solver is installed, and a network data file  has been acquired, a Gas-Grid Flow can be executed with,
```
using GasPowerModels
using <solver_package>

run_gpf("power.m", "gas.m", <>PowerModel, <>GasModel, <>Solver())
```

Similarly, an expansion solver can be executed with,
```
run_ne("power.m", "gas.m", <>PowerModel, <>GasModel, <>Solver())
```

where <>GasModel is the implementation of the mathematical program of the Gas equations you plan to use (i.e. MINLPGasModel) and <>Solver is the JuMP solver you want to use to solve the optimization problem (i.e. IpoptSolver).


## Acknowledgments

The primary developers are Russell Bent and Kaarthik Sundar. Significant contributions on the technical model were made by Conrado Borraz-Sanchez, Pascal van Hentenryck, and Seth Blumsack.

Special thanks to Miles Lubin and Carleton Coffrin for their assistance in integrating with Julia/JuMP and PowerModels.jl.


## License

This code is provided under a BSD license as part of the Multi-Infrastructure Control and Optimization Toolkit (MICOT) project, LA-CC-13-108.
