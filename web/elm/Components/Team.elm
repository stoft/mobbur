module Components.Team exposing (..)

import Html exposing (Html, text, div, button, input, span, h4, i, label, a)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onBlur, onSubmit, onFocus)


--MODEL


type alias Model =
    { name : String
    , members : List TeamMember
    , state : TeamState
    , newNick : String
    , activeMember : Int
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
    , activeMember = 0
    }


initMembers : List TeamMember
initMembers =
    []



-- [ { id' = 1, nick = "pippo", state = DisplayingMember }
-- , { id' = 2, nick = "pluto", state = DisplayingMember }
-- ]
--UPDATE


type Msg
    = NoOp
    | AddMember
    | DoKey String
    | EditMember Int
    | EditTeam
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
                    model.members ++ [ newMember ]
            in
                ( { model | members = updatedMembers, newNick = "" }, Cmd.none )

        DoKey key ->
            let
                ( _, cmd ) =
                    ( (Debug.log "Key press: " key), Cmd.none )
            in
                ( model, Cmd.none )

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
                ( { model | members = updatedMembers }, Cmd.none )

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
                            if m.nick == "" then
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

        nextActiveMember =
            case List.head model.members of
                Just m ->
                    m.id'

                Nothing ->
                    0
    in
        ( { model | activeMember = nextActiveMember, members = rotatedMembers }, Cmd.none )



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


renderMemberList : Int -> List TeamMember -> Html Msg
renderMemberList activeMember members =
    div [] (List.map (renderMember activeMember) members)


renderMemberInput : Model -> Html Msg
renderMemberInput model =
    input
        [ type' "text"
        , class "input"
        , placeholder "Add member nick..."
        , name "nick"
        , value model.newNick
        , onInput UpdateNewNick
        ]
        []


renderMember : Int -> TeamMember -> Html Msg
renderMember activeMember member =
    case member.state of
        Editing ->
            input
                [ type' "text"
                , class "input"
                , name "nick"
                , value member.nick
                , onInput (UpdateNick member.id')
                , onBlur (SubmitNick member.id')
                ]
                []

        DisplayingMember ->
            if member.id' == activeMember then
                div [ onClick (EditMember member.id') ]
                    [ a [ class "title label is-4" ] [ text (member.nick) ] ]
            else
                div [ class "", onClick (EditMember member.id') ]
                    [ a [ class "title is-5" ] [ text member.nick ]
                    ]
