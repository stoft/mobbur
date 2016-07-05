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
    { nick : String }


type TeamState
    = EditingMember
    | EditingTeam
    | Display


initialModel : Model
initialModel =
    { name = "Inglorious Anonymous"
    , members = [ { nick = "pippo" }, { nick = "pluto" } ]
    , state = Display
    , newNick = ""
    }



--UPDATE


type Msg
    = NoOp
    | AddMember
    | EditTeam
    | SubmitTeamName
    | UpdateNewNick String
    | UpdateTeamName String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        AddMember ->
            let
                newMember =
                    TeamMember model.newNick

                updatedMembers =
                    model.members ++ [ newMember ]
            in
                ( { model | members = updatedMembers, newNick = "" }, Cmd.none )

        EditTeam ->
            ( { model | state = EditingTeam }, Cmd.none )

        SubmitTeamName ->
            ( { model | state = Display }, Cmd.none )

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



-- ++ (List.map renderMember team.members)


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
    div [ onClick NoOp ]
        [ text member.nick ]
