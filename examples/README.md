# GasPowerModels Examples

This folder contains a number of examples using GasPowerModels.

## Network Expansion
The network expansion case reproduce the results contained in the paper

[1] Russell Bent, Seth Blumsack, Pascal Van Hentenryck, Conrado Borraz-Sánchez, Mehdi Shahriari. Joint Electricity and Natural Gas Transmission Planning With Endogenous Market Feedbacks. IEEE Transactions on Power Systems. 33 (6):  6397 - 6409, 2018.

[2] C. Borraz-Sanchez, R. Bent, S. Backhaus, S. Blumsack, H. Hijazi, and P. van Hentenryck. Convex Optimization for Joint Expansion Planning of Natural Gas and Power Systems. Proceedings of the 49th Hawaii International Conference on System Sciences (HICSS-49) (HICSS 2016), Jan. 2016, Grand Hyatt, Kauai.*

| Problems                  | Source                    |
| -----------------------   | ------------------------  |
| case36                    | [1] (base model)          |
| case36-ne-*               | [1] (network expansion)   |
| case14-ne                 | [2] (0% stress case)      |
| case14-ne-100             | [2] (100% stress case)    |
| northeast                 | [1] (base model)          |
| northeast-ne-*            | [1] (network expansion)   |
| northeast-ne-C            | [1] (section IV-C)        |
| northeast-ne-D-*          | [1] (section IV-D)        |
| northeast-ne-E-*          | [1] (section IV-E)        |
| belgian-ne                | [2] (0% stress case)      |
| belgian-ne-100            | [2] (100% stress case)    |

* results with the CRDWP model on these problems may change due to tightening of the CRDWP relaxation since 2016.

## Maximal Load Delivery
The example script `mld.jl` solves a series of Maximal Load Delivery (MLD) problems for a single gas-power damage scenario while varying the gas-power delivery tradeoff parameter.
The script exemplifies the procedure used within the broader proof-of-concept Pareto analysis described in the report

[3] Byron Tasseff, Carleton Coffrin, and Russell Bent. Convex Relaxations of Maximal Load Delivery for Multi-contingency Analysis of Joint Electric Power and Natural Gas Transmission Networks. arXiv preprint arXiv:2108.12361, 2021.
