module GasPowerModels
    import JSON
    import JuMP
    import Memento
    import InfrastructureModels
    import GasModels
    import PowerModels

    const _IM = InfrastructureModels
    const _GM = GasModels
    const _PM = PowerModels

    # Create our module level logger (this will get precompiled)
    const _LOGGER = Memento.getlogger(@__MODULE__)

    # Register the module level logger at runtime so that folks can access the logger via `getlogger(GasPowerModels)`
    # NOTE: If this line is not included then the precompiled `GasPowerModels._LOGGER` won't be registered at runtime.
    __init__() = Memento.register(_LOGGER)

    "Suppresses information and warning messages output. For fine-grained control use the Memento package."
    function silence()
        Memento.info(_LOGGER, "Suppressing information and warning messages for the rest of this session. Use the Memento package for more fine-grained control of logging.")
        Memento.setlevel!(Memento.getlogger(InfrastructureModels), "error")
        Memento.setlevel!(Memento.getlogger(GasModels), "error")
        Memento.setlevel!(Memento.getlogger(PowerModels), "error")
    end

    "Allows the user to set the logging level without the need to add Memento."
    function logger_config!(level)
        Memento.config!(Memento.getlogger("GasPowerModels"), level)
    end

    include("core/base.jl")
    include("core/variable.jl")
    include("core/constraint.jl")
    include("core/constraint_template.jl")
    include("core/objective.jl")
    include("core/data.jl")

    include("form/qp.jl")
    include("form/nlp.jl")

    include("prob/gpf.jl")
    include("prob/ogpf.jl")
    include("prob/ne.jl")
    include("prob/neopf.jl")

    # This must come last to support automated export.
    include("core/export.jl")
end
