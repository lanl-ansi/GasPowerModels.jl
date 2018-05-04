# Define NLP implementations of Gas Grid Models (note that this only refers to 

export 
    NLPGasGridModel, StandardNLPForm

@compat abstract type AbstractNLPForm <: AbstractGasGridFormulation end
@compat abstract type StandardNLPForm <: AbstractNLPForm  end
const NLPGasGridModel = GenericGasGridModel{StandardNLPForm}

" Constructor "
NLPGasGridModel(data::Dict{String,Any}; kwargs...) = GenericGasGridModel(data, StandardNLPForm; kwargs...)  
