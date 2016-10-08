module Comm.Types exposing (..)


type alias Model =
    { numberOfTeams : Int }


type Msg
    = NoOp
    | StatusUpdate Int
