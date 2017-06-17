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


getActiveMemberNick : Model -> Maybe String
getActiveMemberNick model =
    case model.activeMember of
        Just id_ ->
            model.members
                |> List.filter (\m -> m.id == id_)
                |> List.head
                |> Maybe.map (.nick)

        _ ->
            Nothing


setNextMemberActive : Model -> Model
setNextMemberActive model =
    let
        head =
            List.head model.members

        tail =
            List.tail model.members

        rotatedMembers =
            case tail of
                Just list ->
                    case head of
                        Just m ->
                            list ++ [ m ]

                        Nothing ->
                            list

                Nothing ->
                    []

        getIdOfFirstMember members =
            case List.head members of
                Just m ->
                    Just m.id

                Nothing ->
                    Nothing

        nextActiveMember =
            case model.activeMember of
                Just _ ->
                    getIdOfFirstMember rotatedMembers

                Nothing ->
                    getIdOfFirstMember model.members
    in
        case model.activeMember of
            Nothing ->
                { model | activeMember = nextActiveMember, members = model.members }

            Just _ ->
                { model | activeMember = nextActiveMember, members = rotatedMembers }


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
