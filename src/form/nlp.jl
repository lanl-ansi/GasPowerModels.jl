# Define NLP implementations of Gas Grid Models (note that this only refers to 

export 
    NLPGasModel, StandardNLPForm

@compat abstract type AbstractNLPForm <: AbstractGasGridFormulation end
@compat abstract type StandardNLPForm <: AbstractNLPForm  end
const NLPGasModel = GenericGasGridModel{StandardNLPForm}

" Constructor "
NLPGasGridModel(data::Dict{String,Any}; kwargs...) = GenericGasGridModel(data, StandardNLPForm; kwargs...)  
