# Examples Documentation

The examples folder contains a library gas power network instances which have been developed in the literature.

Many of the examples can be run using the `run_examples.jl` script which executes various problems and formulations on the library of instances and verifies that `GasPowerModels` returns solutions which were reported in the literature. Some results, esp. those based on relaxations, have departed from those reported in the literature due to advances that have tightened these relaxations since those papers have been published.

Long term, the plan is to move the examples out of the `GasPowerModels` repository and maintain a special `GasPowerModelsLib` repository specifically for warehousing models developed in the literature.


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


## Sources

[1] Russell Bent, Seth Blumsack, Pascal Van Hentenryck, Conrado Borraz-Sánchez, Mehdi Shahriari. Joint Electricity and Natural Gas Transmission Planning With Endogenous Market Feedbacks. IEEE Transactions on Power Systems. 33 (6):  6397 - 6409, 2018.

[2] C. Borraz-Sanchez, R. Bent, S. Backhaus, S. Blumsack, H. Hijazi, and P. van Hentenryck. Convex Optimization for Joint Expansion Planning of Natural Gas and Power Systems. Proceedings of the 49th Hawaii International Conference on System Sciences (HICSS-49) (HICSS 2016), Jan. 2016, Grand Hyatt, Kauai.
