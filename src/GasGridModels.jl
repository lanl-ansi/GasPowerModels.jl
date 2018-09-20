isdefined(Base, :__precompile__) && __precompile__()

module GasGridModels

using JSON
using MathProgBase
using JuMP
using Compat
using PowerModels
using GasModels
using InfrastructureModels

using Compat

include("core/base.jl")
include("core/variable.jl")
include("core/constraint.jl")
include("core/constraint_template.jl")
include("core/objective.jl")
include("core/solution.jl")
include("core/data.jl")

include("form/qp.jl")
include("form/nlp.jl")

include("prob/gpf.jl")
include("prob/ne.jl")
include("prob/neopf.jl")

end
