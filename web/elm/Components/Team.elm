module Components.Team exposing (..)

import Html exposing (Html, text, div, button, input, span)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onBlur, onSubmit, onFocus)


--MODEL


type alias Model =
    { name : String
    , members : List TeamMember
    , state : TeamState
    , newNick : String
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
    }


initMembers : List TeamMember
initMembers =
    [ { id' = 1, nick = "pippo", state = DisplayingMember }
    , { id' = 2, nick = "pluto", state = DisplayingMember }
    ]



--UPDATE


type Msg
    = NoOp
    | AddMember
    | EditMember Int
    | EditTeam
    | SubmitTeamName
    | SubmitNick Int
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

        SubmitNick id' ->
            let
                updatedMembers =
                    model.members
                        |> List.map
                            (\m ->
                                if m.id' == id' then
                                    { m | state = DisplayingMember }
                                else
                                    m
                            )
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



--VIEW


view : Model -> Html Msg
view model =
    div []
        [ renderTeamName model
        , renderMemberList model.members
        , renderMemberInput model
        , button [ onClick AddMember ]
            [ text "+" ]
        , div [] [ text (toString model) ]
        ]


renderTeamName : Model -> Html Msg
renderTeamName model =
    case model.state of
        EditingTeam ->
            input
                [ type' "text"
                , value model.name
                , name "team-name"
                , onInput UpdateTeamName
                , onBlur SubmitTeamName
                ]
                []

        _ ->
            span [ onClick EditTeam ] [ text model.name ]


renderMemberList : List TeamMember -> Html Msg
renderMemberList members =
    div [] (List.map renderMember members)


renderMemberInput : Model -> Html Msg
renderMemberInput model =
    input
        [ type' "text"
        , placeholder "Nick..."
        , name "nick"
        , value model.newNick
        , onInput UpdateNewNick
        ]
        []


renderMember : TeamMember -> Html Msg
renderMember member =
    case member.state of
        Editing ->
            input
                [ type' "text"
                , name "nick"
                , value member.nick
                , onInput (UpdateNick member.id')
                , onBlur (SubmitNick member.id')
                ]
                []

        DisplayingMember ->
            div [ onClick (EditMember member.id') ]
                [ text member.nick ]
