module Main exposing (main)

import Cli.Option as Option
import Cli.OptionsParser as OptionsParser
import Cli.Program as Program
import Elm.Docs
import Json.Decode as D
import Markdown
import Model exposing (CliOptions, Format(..), Model(..), toExit, toInit, toReading, toWriting)
import Ports exposing (Response(..), echoRequest, exit, fileReadRequest, fileWriteRequest, response)
import Result.Extra
import StateMachine exposing (State(..), map, untag)
import Task


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


message : msg -> Cmd msg
message msg =
    Task.perform identity (Task.succeed msg)


init : Program.FlagsIncludingArgv flags -> CliOptions -> ( Model, Cmd Response )
init _ options =
    ( toInit options, message NoOp )


update : CliOptions -> Response -> Model -> ( Model, Cmd Response )
update _ msg model =
    (case ( model, msg ) of
        ( _, Stderr stderr ) ->
            Err stderr

        ( Init state, _ ) ->
            Ok
                ( toReading state
                , fileReadRequest (state |> untag |> .input)
                )

        ( Reading state, Stdout stdout ) ->
            stdout
                |> (D.decodeString (D.list <| Elm.Docs.decoder)
                        >> Result.mapError D.errorToString
                   )
                |> Result.map
                    (\moduleList ->
                        ( toWriting <| State { output = state |> untag |> .output, format = state |> untag |> .format }
                        , fileWriteRequest
                            ( state |> untag |> .output, Markdown.render moduleList )
                        )
                    )

        ( Writing _, Stdout _ ) ->
            Ok ( toExit <| State {}, exit 0 "Done" )

        ( state, cmd ) ->
            let
                _ =
                    ( state, cmd )
            in
            Err "Invalid State Transition"
    )
        |> Result.Extra.extract (\err -> ( model, exit 1 err ))


subscriptions : Model -> Sub Response
subscriptions _ =
    response


main : Program.StatefulProgram Model Response CliOptions {}
main =
    Program.stateful
        { printAndExitFailure = exit 1
        , printAndExitSuccess = exit 0
        , init = init
        , config = config
        , update = update
        , subscriptions = subscriptions
        }
