using Documenter, GasGridModels

makedocs(
    modules = [GasGridModels],
    format = :html,
    sitename = "GasGridModels",
    authors = "Russell Bent and contributors.",
    analytics = "UA-367975-10",
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "Getting Started" => "quickguide.md",
            "Network Data Format" => "network-data.md",
            "Result Data Format" => "result-data.md",
            "Mathematical Model" => "math-model.md"
        ],
        "Library" => [
            "Network Formulations" => "formulations.md",
            "Problem Specifications" => "specifications.md",
            "Modeling Components" => [
                "GasGridModel" => "model.md",
                "Objective" => "objective.md",
                "Variables" => "variables.md",
                "Constraints" => "constraints.md"
            ],
            "File IO" => "parser.md"
        ],
        "Developer" => "developer.md"
    ]
)

deploydocs(
    deps = nothing,
    make = nothing,
    target = "build",
    repo = "github.com/lanl-ansi/GasGridModels.jl.git",
    julia = "1.1"
)
