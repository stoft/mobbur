port module Comm.State exposing (..)

import Comm.Types as Comm exposing (Model, Msg, ReplicatedModel, Alarm)


-- OUTBOUND PORTS


port playAudio : String -> Cmd msg


port notify : { message : String, titleMessage : String, nick : Maybe String } -> Cmd msg


port teamStatus : ReplicatedModel -> Cmd msg



--INBOUND PORTS


port globalStatus : (List String -> msg) -> Sub msg


port teamState : (ReplicatedModel -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    globalStatus Comm.StatusUpdate


teamSubscription : ReplicatedModel -> Sub Msg
teamSubscription model =
    teamState Comm.TeamState


initialModel : Model
initialModel =
    { numberOfTeams = 0
    , teamNames = []
    }


initialReplicatedModel : ReplicatedModel
initialReplicatedModel =
    { workTimer = Comm.Timer 0 0 ""
    , breakTimer = Comm.Timer 0 0 ""
    , activeTimer = ""
    , useBreakTimer = True
    , autoRestart = True
    , autoRotateTeam = True
    , team = { name = "", members = [], activeMember = Nothing }
    , currentView = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Comm.NoOp ->
            ( model, Cmd.none )

        Comm.StatusUpdate teams ->
            let
                totalOnline =
                    List.length teams
            in
                ( { model | numberOfTeams = totalOnline, teamNames = teams }
                , Cmd.none
                )

        Comm.TeamState state ->
            ( Debug.log ("Elm received: " ++ toString state) model, Cmd.none )
