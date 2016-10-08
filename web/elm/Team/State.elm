module Team.State exposing (..)

import Dom exposing (focus)
import Keyboard exposing (KeyCode)
import String
import Task exposing (perform)
import Team.Types as Team exposing (Model, Msg, TeamMember)


--SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.presses (\code -> Team.KeyPress code)


initialModel : Model
initialModel =
    { name = "Inglorious Anonymous"
    , members = initMembers
    , state = Team.Displaying
    , newNick = ""
    , activeMember = Nothing
    }


initMembers : List TeamMember
initMembers =
    []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Team.NoOp ->
            ( model, Cmd.none )

        Team.AddMember ->
            handleAddMember model

        Team.KeyPress code ->
            handleKeyPress code model

        Team.EditMember id' ->
            let
                updatedMembers =
                    model.members
                        |> List.map
                            (\m ->
                                if m.id' == id' then
                                    { m | state = Team.Editing }
                                else
                                    m
                            )
            in
                ( { model | members = updatedMembers }
                , Task.perform (always Team.NoOp) (always Team.NoOp) (Dom.focus ("team-member-" ++ toString id'))
                )

        Team.EditTeam ->
            ( { model | state = Team.EditingTeam }, Cmd.none )

        Team.SetNextMemberActive ->
            handleSetNextMemberActive model

        Team.SubmitNick id' ->
            let
                member =
                    List.filter (\m -> m.id' == id') model.members |> List.head

                changeToDisplaying =
                    (\m ->
                        if m.id' == id' then
                            { m | state = Team.DisplayingMember }
                        else
                            m
                    )

                removeMember =
                    List.filter (\m -> m.id' /= id') model.members

                updatedMembers =
                    case member of
                        Just m ->
                            if (String.trim m.nick) == "" then
                                removeMember
                            else
                                List.map changeToDisplaying model.members

                        Nothing ->
                            model.members
            in
                ( { model | members = updatedMembers }, Cmd.none )

        Team.SubmitTeamName ->
            ( { model | state = Team.Displaying }, Cmd.none )

        Team.UpdateNick id' nick' ->
            let
                updatedMembers =
                    model.members
                        |> List.map
                            (\m ->
                                if m.id' == id' then
                                    { m | nick = nick' }
                                else
                                    m
                            )
            in
                ( { model | members = updatedMembers }, Cmd.none )

        Team.UpdateNewNick nick ->
            ( { model | newNick = nick }, Cmd.none )

        Team.UpdateTeamName name ->
            ( { model | name = name }, Cmd.none )


handleKeyPress : KeyCode -> Model -> ( Model, Cmd Msg )
handleKeyPress code model =
    case code of
        13 ->
            update Team.AddMember model

        _ ->
            ( model, Cmd.none )


handleAddMember : Model -> ( Model, Cmd Msg )
handleAddMember model =
    let
        findMax =
            (\m max ->
                if m.id' > max then
                    m.id'
                else
                    max
            )

        nextId =
            List.foldl findMax 0 model.members |> (+) 1

        newMember =
            TeamMember nextId model.newNick Team.DisplayingMember

        updatedMembers =
            if (String.trim model.newNick) == "" then
                model.members
            else
                model.members ++ [ newMember ]
    in
        ( { model | members = updatedMembers, newNick = "" }, Cmd.none )


handleSetNextMemberActive : Model -> ( Model, Cmd Msg )
handleSetNextMemberActive model =
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
                    Just m.id'

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
                ( { model | activeMember = nextActiveMember, members = model.members }, Cmd.none )

            Just _ ->
                ( { model | activeMember = nextActiveMember, members = rotatedMembers }, Cmd.none )
