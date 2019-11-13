module Main exposing (main)

import Cli.Program as Program
import Elm.Docs
import Json.Decode as D
import Model exposing (CliOptions, Model(..), toExit, toInit, toReading, toWriting)
import Options exposing (config)
import Ports exposing (Response(..), echoRequest, exit, fileReadRequest, fileWriteRequest, response)
import Result.Extra
import StateMachine exposing (State(..), map, untag)
import Task


message : msg -> Cmd msg
message msg =
    Task.perform identity (Task.succeed msg)


init : Program.FlagsIncludingArgv flags -> CliOptions -> ( Model, Cmd Response )
init _ options =
    ( toInit options, Cmd.batch [ echoRequest ("Reading " ++ options.input), message NoOp ] )


update : CliOptions -> Response -> Model -> ( Model, Cmd Response )
update _ msg model =
    (case Debug.log (Debug.toString msg) ( model, msg ) of
        ( _, Stderr stderr ) ->
            Err stderr

        ( Init state, _ ) ->
            Ok ( toReading state, fileReadRequest [ state |> untag |> .input ] )

        ( Reading state, Stdout stdout ) ->
            stdout
                |> (D.decodeString (D.list <| Elm.Docs.decoder)
                        >> Result.mapError D.errorToString
                   )
                |> Result.map
                    (\moduleList ->
                        ( toWriting <| State { output = state |> untag |> .output, format = state |> untag |> .format }
                        , fileWriteRequest
                            [ ( [ state |> untag |> .output ], Debug.todo "pretty print moduleList" moduleList ) ]
                        )
                    )

        ( Writing _, Stdout _ ) ->
            Ok ( toExit <| State {}, Cmd.batch [ exit 0 "Done" ] )

        ( state, cmd ) ->
            let
                _ =
                    Debug.log "( state, cmd )" ( state, cmd )
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
