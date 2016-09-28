port module Components.Comm exposing (..)


port globalStatus : (Int -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    globalStatus StatusUpdate



-- TYPES


type alias Model =
    { numberOfTeams : Int }


type Msg
    = NoOp
    | StatusUpdate Int



-- STATE


initialModel : Model
initialModel =
    { numberOfTeams = 0 }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        StatusUpdate totalOnline ->
            Debug.log "status update! " ( { model | numberOfTeams = totalOnline }, Cmd.none )
