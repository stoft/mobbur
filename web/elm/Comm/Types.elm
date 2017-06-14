module Comm.Types exposing (..)


type alias Model =
    { numberOfTeams : Int
    , teamNames : List String
    }


type alias ReplicatedModel =
    { workTimer : Timer
    , breakTimer : Timer
    , activeTimer : String
    , useBreakTimer : Bool
    , autoRestart : Bool
    , autoRotateTeam : Bool
    , team : Team
    , currentView : String
    }


type alias Team =
    { name : String
    , members : List TeamMember
    , activeMember : Maybe Int
    }


type alias TeamMember =
    { id : Int
    , nick : String
    }


type alias Alarm =
    { nick : Maybe String, audioUri : String }


type alias Timer =
    { countdown : Int
    , interval : Int
    , state : String
    }


type Msg
    = NoOp
    | StatusUpdate (List String)
    | TeamState ReplicatedModel
