

RelaxedPowerModels = Union{_PM.DCPPowerModel,_PM.DCMPPowerModel,_PM.BFAPowerModel,_PM.NFAPowerModel,
                           _PM.DCPLLPowerModel,_PM.LPACCPowerModel,_PM.SOCWRPowerModel,_PM.SOCWRConicPowerModel,
                           _PM.QCRMPowerModel,_PM.QCLSPowerModel,_PM.SOCBFPowerModel,_PM.SOCBFConicPowerModel,
                           _PM.SDPWRMPowerModel,_PM.SparseSDPWRMPowerModel}

RelaxaedGasModels = Union{_GM.AbstractCRDWPModel,_GM.AbstractLRWPModel,_GM.AbstractLRDWPModel}
