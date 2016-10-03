port module State.Comm exposing (..)

import Types.Comm as Comm exposing (Model, Msg)


-- OUTBOUND PORTS


port alarm : () -> Cmd msg



--INBOUND PORTS


port globalStatus : (Int -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    globalStatus Comm.StatusUpdate


initialModel : Model
initialModel =
    { numberOfTeams = 0 }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Comm.NoOp ->
            ( model, Cmd.none )

        Comm.StatusUpdate totalOnline ->
            Debug.log "status update! " ( { model | numberOfTeams = totalOnline }, Cmd.none )
