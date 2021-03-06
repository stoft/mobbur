module Team.State exposing (..)

import Basics exposing (Never)
import Dom exposing (focus)
import Helpers.ListHelpers exposing (stepElementLeft, stepElementRight, randomizeList)
import Keyboard exposing (KeyCode)
import String
import Task exposing (perform)
import Team.Types as Team exposing (Model, Msg, TeamMember)
import Time


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

        Team.EditMember id ->
            let
                updatedMembers =
                    model.members
                        |> List.map
                            (\m ->
                                if m.id == id then
                                    { m | state = Team.Editing }
                                else
                                    m
                            )
            in
                ( { model | members = updatedMembers }
                , Task.attempt (always Team.NoOp) (Dom.focus ("team-member-" ++ toString id))
                )

        -- perform : (a -> msg) -> Task Never a -> Cmd msg
        Team.EditTeam ->
            ( { model | state = Team.EditingTeam }, Cmd.none )

        Team.MoveMemberUp id ->
            let
                updatedMembers =
                    moveMemberLeftOne id model.members
            in
                ( { model | members = updatedMembers }, Cmd.none )

        Team.MoveMemberDown id ->
            let
                updatedMembers =
                    moveMemberRightOne id model.members
            in
                ( { model | members = updatedMembers }, Cmd.none )

        Team.RandomizeTeam ->
            ( model, Task.perform Team.RandomizeTeamWithSeed Time.now )

        Team.RandomizeTeamWithSeed time ->
            let
                updatedMembers =
                    randomizeList model.members (round time)
            in
                ( { model | members = updatedMembers }, Cmd.none )

        Team.RemoveMember id ->
            let
                updatedMembers =
                    List.filter (\m -> m.id /= id) model.members
            in
                ( { model | members = updatedMembers }, Cmd.none )

        Team.SetNextMemberActive ->
            ( Team.setNextMemberActive model, Cmd.none )

        Team.SubmitNick id ->
            let
                member =
                    List.filter (\m -> m.id == id) model.members |> List.head

                changeToDisplaying =
                    (\m ->
                        if m.id == id then
                            { m | state = Team.DisplayingMember }
                        else
                            m
                    )

                removeMember =
                    List.filter (\m -> m.id /= id) model.members

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

        Team.UpdateNick id nick_ ->
            let
                updatedMembers =
                    model.members
                        |> List.map
                            (\m ->
                                if m.id == id then
                                    { m | nick = nick_ }
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
                if m.id > max then
                    m.id
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


moveMemberLeftOne : Int -> List TeamMember -> List TeamMember
moveMemberLeftOne id list =
    if List.length list < 2 then
        list
    else
        stepElementLeft (matchFunction id) list


moveMemberRightOne : Int -> List TeamMember -> List TeamMember
moveMemberRightOne id list =
    if List.length list < 2 then
        list
    else
        stepElementRight (matchFunction id) list


matchFunction : Int -> TeamMember -> Bool
matchFunction soughtId member =
    member.id == soughtId
