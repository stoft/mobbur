module Components.Team exposing (..)

import Html exposing (Html, text, div, button, input)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


--MODEL


type alias Model =
    { name : String
    , members : List TeamMember
    , state : TeamState
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
    , members = []
    , state = Display
    }



--UPDATE


type Msg
    = NoOp
    | EditTeam



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



--VIEW


view : Model -> Html Msg
view model =
    div []
        [ text model.name
        , renderMemberInput
        , button
            [{--onClick AddMember--}
            ]
            [ text "+" ]
        ]



-- ++ (List.map renderMember team.members)


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
