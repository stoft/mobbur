module Comm.Types exposing (..)


type alias Model =
    { numberOfTeams : Int
    , teamNames : List String
    }


type Msg
    = NoOp
    | StatusUpdate (List String)
