module Team.Types exposing (..)

import Keyboard exposing (KeyCode)
import Time exposing (Time)


type alias Model =
    { name : String
    , members : List TeamMember
    , state : TeamState
    , newNick : String
    , activeMember : Maybe Int
    }


type alias TeamMember =
    { id : Int
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


getActiveMember : Model -> Maybe TeamMember
getActiveMember model =
    case model.activeMember of
        Just id_ ->
            model.members |> List.filter (\m -> m.id == id_) |> List.head

        _ ->
            Nothing


type Msg
    = NoOp
    | AddMember
    | EditMember Int
    | EditTeam
    | KeyPress KeyCode
    | MoveMemberDown Int
    | MoveMemberUp Int
    | RandomizeTeam
    | RandomizeTeamWithSeed Time
    | RemoveMember Int
    | SetNextMemberActive
    | SubmitNick Int
    | SubmitTeamName
    | UpdateNewNick String
    | UpdateNick Int String
    | UpdateTeamName String
