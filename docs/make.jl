using Documenter, GasPowerModels

makedocs(
    modules = [GasPowerModels],
    format = Documenter.HTML(),
    sitename = "GasPowerModels",
    authors = "Russell Bent and contributors.",
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
                "Objective" => "objective.md",
                "Variables" => "variables.md",
                "Constraints" => "constraints.md"
            ],
            "File IO" => "parser.md"
        ],
        "Developer" => "developer.md",
        "Examples" => "examples.md"
    ]
)

deploydocs(
    repo = "github.com/lanl-ansi/GasPowerModels.jl.git",
)
