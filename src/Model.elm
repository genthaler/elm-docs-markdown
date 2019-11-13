module Model exposing (CliOptions, Format(..), Model(..), toExit, toInit, toReading, toWriting)

import StateMachine exposing (Allowed, State(..))


type alias CliOptions =
    { input : String
    , output : String
    , format : Format
    }


type Format
    = Markdown
    | Html


type Model
    = Init (State { reading : Allowed } { input : String, output : String, format : Format })
    | Reading (State { writing : Allowed } { input : String, output : String, format : Format })
    | Writing (State { exit : Allowed } { output : String, format : Format })
    | Exit (State {} {})


toInit : CliOptions -> Model
toInit options =
    Init <| State { input = options.input, output = options.output, format = options.format }


toReading : State { a | reading : Allowed } { input : String, output : String, format : Format } -> Model
toReading (State state) =
    Reading <| State { input = state.input, output = state.output, format = state.format }


toWriting : State { a | writing : Allowed } { output : String, format : Format } -> Model
toWriting (State state) =
    Writing <| State { output = state.output, format = state.format }


toExit : State a {} -> Model
toExit _ =
    Exit <| State {}
