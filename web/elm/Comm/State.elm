port module Comm.State exposing (..)

import Comm.Types as Comm exposing (Model, Msg)


-- OUTBOUND PORTS


port alarm : () -> Cmd msg


port teamStatus : String -> Cmd msg



--INBOUND PORTS


port globalStatus : (List String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    globalStatus Comm.StatusUpdate


initialModel : Model
initialModel =
    { numberOfTeams = 0
    , teamNames = []
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Comm.NoOp ->
            ( model, Cmd.none )

        Comm.StatusUpdate teams ->
            let
                totalOnline =
                    List.length (Debug.log "teams: " teams)
            in
                Debug.log "status update! "
                    ( { model
                        | numberOfTeams = totalOnline
                        , teamNames = teams
                      }
                    , Cmd.none
                    )
