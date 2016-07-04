module Components.Team exposing (..)

import Html exposing (Html, text, div, button, input, span)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onBlur, onSubmit, onFocus)


--MODEL


type alias Model =
    { name : String
    , members : List TeamMember
    , state : TeamState
    , foo : Int
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
    , foo = 0
    }



--UPDATE


type Msg
    = NoOp
    | EditTeam
    | UpdateTeamName String
    | SubmitTeamName



{--| AddMember
    | NewMember String
--}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        EditTeam ->
            ( { model | state = EditingTeam }, Cmd.none )

        SubmitTeamName ->
            ( { model | state = Display }, Cmd.none )

        UpdateTeamName name ->
            ( { model | name = name }, Cmd.none )



--VIEW


view : Model -> Html Msg
view model =
    div []
        [ renderTeamName model
        , renderMemberList model.members
        , renderMemberInput
        , button
            [{--onClick AddMember--}
            ]
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


renderMemberInput : Html Msg
renderMemberInput =
    input
        [ type' "text"
        , placeholder "Nick..."
        , name "nick"
        ]
        []


renderMember : TeamMember -> Html Msg
renderMember member =
    div [ onClick NoOp ]
        [ text member.nick ]
