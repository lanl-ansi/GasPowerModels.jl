using Documenter, GasPowerModels

makedocs(
    modules = [GasPowerModels],
    format = :html,
    sitename = "GasPowerModels",
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
    repo = "github.com/lanl-ansi/GasPowerModels.jl.git",
)
