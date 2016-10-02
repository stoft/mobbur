module Types.Team exposing (..)

import Keyboard exposing (KeyCode)


type alias Model =
    { name : String
    , members : List TeamMember
    , state : TeamState
    , newNick : String
    , activeMember : Maybe Int
    }


type alias TeamMember =
    { id' : Int
    , nick : String
    , state : MemberState
    }


type MemberState
    = DisplayingMember
    | Editing


type TeamState
    = EditingMember
    | EditingTeam
    | Displaying


type Msg
    = NoOp
    | AddMember
    | EditMember Int
    | EditTeam
    | KeyPress KeyCode
    | SetNextMemberActive
    | SubmitNick Int
    | SubmitTeamName
    | UpdateNewNick String
    | UpdateNick Int String
    | UpdateTeamName String
