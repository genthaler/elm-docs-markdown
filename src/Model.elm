module Model exposing (Format(..), Model(..), CliOptions =
    { input : String
    , output : String
    , format : Format
    }


type Format
    = Markdown
    | Html


type Model
    = Init (State { reading : Allowed } { input : String, output : String, format : Format })
    | Reading (State { writing : Allowed } { output : String, format : Format })
    | Writing (State {} {})
    | Exit (State {} {})


toInit : Options -> Model
toInit options =
    Init <| State { input = options.input, output = options.output, format = options.format }


toReading : State { a | reading : Allowed } { output : String, format : Format } -> Model
toReading (State state) =
    Reading <| State { output = state.output, format = state.format }


toWriting : State { a | writing : Allowed } {} -> Model
toWriting _ =
    Writing <| State {}


toExit : State { a | writing : Allowed } {} -> Model
toExit _ =
    Exit <| State {}
