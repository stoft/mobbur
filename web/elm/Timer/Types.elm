module Timer.Types exposing (..)


type alias Model =
    { countdown : Int
    , interval : Int
    , state : State
    , audioUri : String
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
    | Pause
    | PreAlarm
    | Reset
    | Start
    | Tick
    | Toggle
    | UpdateAudioURI String
    | UpdateMinutes String
    | UpdateSeconds String
