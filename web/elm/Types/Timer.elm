module Types.Timer exposing (..)


type alias Model =
    { countdown : Int
    , interval : Int
    , state : State
    }


type alias TimeRecord =
    { minutes : Int, seconds : Int }


type State
    = Started
    | Paused
    | Stopped
    | Editing


type Msg
    = NoOp
    | Alarm
    | Edit
    | Reset
    | Pause
    | Start
    | Toggle
    | Tick
    | UpdateMinutes String
    | UpdateSeconds String
