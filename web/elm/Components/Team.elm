module Components.Team exposing (..)

import Dom exposing (focus)
import Html exposing (Html, text, div, button, input, span, h4, i, label, a)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onBlur, onSubmit, onFocus)
import Keyboard exposing (KeyCode, presses)
import String exposing (trim)
import Task exposing (perform)


--MODEL


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


initialModel : Model
initialModel =
    { name = "Inglorious Anonymous"
    , members = initMembers
    , state = Displaying
    , newNick = ""
    , activeMember = Nothing
    }


initMembers : List TeamMember
initMembers =
    []



--UPDATE


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        AddMember ->
            handleAddMember model

        KeyPress code ->
            handleKeyPress code model

        EditMember id' ->
            let
                updatedMembers =
                    model.members
                        |> List.map
                            (\m ->
                                if m.id' == id' then
                                    { m | state = Editing }
                                else
                                    m
                            )
            in
                ( { model | members = updatedMembers }
                , Task.perform (always NoOp) (always NoOp) (Dom.focus ("team-member-" ++ toString id'))
                )

        EditTeam ->
            ( { model | state = EditingTeam }, Cmd.none )

        SetNextMemberActive ->
            handleSetNextMemberActive model

        SubmitNick id' ->
            let
                member =
                    List.filter (\m -> m.id' == id') model.members |> List.head

                changeToDisplaying =
                    (\m ->
                        if m.id' == id' then
                            { m | state = DisplayingMember }
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

        SubmitTeamName ->
            ( { model | state = Displaying }, Cmd.none )

        UpdateNick id' nick' ->
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

        UpdateNewNick nick ->
            ( { model | newNick = nick }, Cmd.none )

        UpdateTeamName name ->
            ( { model | name = name }, Cmd.none )


handleKeyPress : KeyCode -> Model -> ( Model, Cmd Msg )
handleKeyPress code model =
    case code of
        13 ->
            update AddMember model

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
            TeamMember nextId model.newNick DisplayingMember

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



--SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.presses (\code -> KeyPress code)



--VIEW


view : Model -> Html Msg
view model =
    div [ class "column is-narrow" ]
        [ renderTeamName model
        , renderMemberList model.activeMember model.members
        , div [ class "has-addons" ]
            [ renderMemberInput model
            , button [ class "button is-primary", onClick AddMember ]
                [ span [ class "icon" ]
                    [ i [ class "fa fa-plus-square" ] [] ]
                ]
            , button [ class "button is-primary", onClick SetNextMemberActive ]
                [ span [ class "icon" ]
                    [ i [ class "fa fa-fast-forward" ] []
                    ]
                ]
            ]
          -- , div [] [ text (toString model) ]
        ]


teamSettingsView : Model -> Html Msg
teamSettingsView model =
    div [ class "tile notification is-info" ]
        [ div [ class "tile is-child" ]
            [ h4 [ class "title" ] [ text "Team" ]
            , label [ class "label" ]
                [ text "Team Name" ]
            , input
                [ type' "text"
                , class "input"
                , value model.name
                , name "team-name"
                , onInput UpdateTeamName
                , onBlur SubmitTeamName
                ]
                []
            , label [ class "label" ] [ text "Add Member" ]
            , div [ class "control has-addons" ]
                [ renderMemberInput model
                , button [ class "button is-info is-inverted", onClick AddMember ]
                    [ span [ class "icon" ]
                        [ i [ class "fa fa-plus-square" ] [] ]
                    ]
                ]
            ]
        ]


memberSettingsView : Model -> Html Msg
memberSettingsView model =
    div [ class "tile is-child notification is-info" ]
        [ h4 [ class "title" ] [ text "Members" ]
        , renderMemberList model.activeMember model.members
        , button [ class "button is-info is-inverted", onClick SetNextMemberActive ]
            [ span [ class "icon" ]
                [ i [ class "fa fa-fast-forward" ] []
                ]
            ]
        ]


renderTeamName : Model -> Html Msg
renderTeamName model =
    case model.state of
        EditingTeam ->
            input
                [ type' "text"
                , class "input"
                , style [ ( "width", "200px" ) ]
                , value model.name
                , name "team-name"
                , onInput UpdateTeamName
                , onBlur SubmitTeamName
                ]
                []

        _ ->
            h4 [ class "title is-medium", onClick EditTeam ] [ text model.name ]


renderMemberList : Maybe Int -> List TeamMember -> Html Msg
renderMemberList activeMember members =
    case activeMember of
        Just id' ->
            div [] (List.map (renderMember id') members)

        Nothing ->
            div [] (List.map (renderMember 0) members)


renderMemberInput : Model -> Html Msg
renderMemberInput model =
    input
        [ type' "text"
        , class "input"
        , placeholder "Add member nick..."
        , name "nick"
        , value model.newNick
        , onInput UpdateNewNick
        , onSubmit AddMember
        ]
        []


renderMember : Int -> TeamMember -> Html Msg
renderMember activeMember member =
    case member.state of
        Editing ->
            let
                ( _, memberId ) =
                    ( Task.perform (Debug.log "failed" (always NoOp)) (always NoOp) (Dom.focus ("team-member-" ++ toString member.id'))
                    , member.id'
                    )
            in
                input
                    [ type' "text"
                    , id ("team-member-" ++ toString member.id')
                    , class "input"
                    , name "nick"
                    , value member.nick
                    , onInput (UpdateNick member.id')
                    , onBlur (SubmitNick member.id')
                    ]
                    []

        DisplayingMember ->
            if member.id' == activeMember then
                div
                    [ onClick (EditMember member.id')
                    , id ("team-member-" ++ toString member.id')
                    ]
                    [ a [ class "title label is-4" ] [ text (member.nick) ] ]
            else
                div
                    [ onClick (EditMember member.id')
                    , id ("team-member-" ++ toString member.id')
                    ]
                    [ a [ class "title is-5" ] [ text member.nick ]
                    ]
