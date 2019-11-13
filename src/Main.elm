module Main exposing (main)

import Cli.Program as Program
import Elm.Project exposing (..)
import Json.Decode as D
import Json.Encode as E
import Model exposing (..)
import Options exposing (config)
import Ports exposing (..)
import StateMachine exposing (State(..), map, untag)


message : msg -> Cmd msg
message msg =
    Task.perform identity (Task.succeed msg)


init : Program.FlagsIncludingArgv flags -> CliOptions -> ( Model, Cmd Response )
init _ options =
    ( toInit options, Cmd.batch [ echoRequest initMessage, message NoOp ] )


update : CliOptions -> Response -> Model -> ( Model, Cmd Response )
update _ msg model =
    (case Debug.log (Debug.toString msg) ( model, msg ) of
        ( _, Stderr stderr ) ->
            Err stderr

        ( Init state, _ ) ->
            Ok ( toReading state, fileReadRequest [ state.input ] )

        ( Reading state, Stdout stdout ) ->
            stdout
                |> (D.decodeString (D.list <| Elm.Docs.decoder)
                        >> Result.mapError D.errorToString
                   )
                |> Result.map
                    (\moduleList ->
                        ( toWwriting state
                        , fileWriteRequest
                            [ ( [ state.output ], Debug.todo "pretty print moduleList" moduleList ) ]
                        )
                    )

        ( Writing state, Stdout stdout ) ->
            ( toExit {}, Cmd.batch [ echoRequest exitMessage ] )

        ( state, cmd ) ->
            let
                _ =
                    Debug.log "( state, cmd )" ( state, cmd )
            in
            Err "Invalid State Transition"
    )
        |> Result.Extra.extract (\err -> ( model, exit 1 err ))


subscriptions : Model -> Sub Response
subscriptions model =
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
