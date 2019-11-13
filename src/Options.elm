module Options exposing (config)

import Cli.Option as Option
import Cli.OptionsParser as OptionsParser
import Cli.Program as Program
import Model exposing (CliOptions, Format(..))


config : Program.Config CliOptions
config =
    Program.config 
        |> Program.add
            (OptionsParser.build CliOptions
                |> OptionsParser.with
                    (Option.optionalKeywordArg "input"
                        |> Option.withDefault "docs.json"
                    )
                |> OptionsParser.with
                    (Option.optionalKeywordArg "output"
                        |> Option.withDefault "docs.md"
                    )
                |> OptionsParser.with
                    (Option.optionalKeywordArg "format"
                        |> Option.withDefault "markdown"
                        |> Option.oneOf Markdown
                            [ ( "markdown", Markdown )
                            , ( "html", Html )
                            ]
                    )
            )
