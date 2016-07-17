module Main exposing (..)

import Html exposing (Html, text, div, input, label)
import Html.App
import Html.Attributes exposing (type', name, checked)
import Html.Events exposing (onCheck)
import Components.Timer as Timer
import Components.Team as Team


-- import Components.Team as Team


main : Program Never
main =
    Html.App.program
        { init =
            ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--MODEL


type alias Model =
    { workTimer : Timer.Model
    , breakTimer : Timer.Model
    , activeTimer : ActiveTimer
    , useBreakTimer : Bool
    , autoRestart : Bool
    , autoRotateTeam : Bool
    , team : Team.Model
    }


type ActiveTimer
    = BreakTimer
    | WorkTimer


initialModel : Model
initialModel =
    { workTimer = Timer.initialModel 480
    , breakTimer = Timer.initialModel 30
    , activeTimer = WorkTimer
    , useBreakTimer = True
    , autoRestart = True
    , autoRotateTeam = True
    , team = Team.initialModel
    }



--UPDATE


type Msg
    = Noop
    | BreakTimerMsg Timer.Msg
    | TeamMsg Team.Msg
    | WorkTimerMsg Timer.Msg
    | UpdateAutoRestart Bool
    | UpdateAutoRotateTeam Bool
    | UpdateUseBreakTimer Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        BreakTimerMsg timerMsg ->
            let
                ( tmodel, tmsg ) =
                    Timer.update timerMsg model.breakTimer

                activeTimer =
                    case timerMsg of
                        Timer.Alarm ->
                            WorkTimer

                        _ ->
                            model.activeTimer

                ( workTimer, _ ) =
                    if model.autoRestart && timerMsg == Timer.Alarm then
                        Timer.update Timer.Start model.workTimer
                    else
                        ( model.workTimer, Cmd.none )
            in
                ( { model | breakTimer = tmodel, activeTimer = activeTimer, workTimer = workTimer }
                , Cmd.map BreakTimerMsg tmsg
                )

        WorkTimerMsg timerMsg ->
            let
                ( tmodel, tcmd ) =
                    Timer.update timerMsg model.workTimer

                ( ( breakTimer, bcmd ), ( workTimer, wcmd ) ) =
                    if timerMsg == Timer.Alarm && model.autoRestart then
                        if model.useBreakTimer then
                            (,) (Timer.update Timer.Start model.breakTimer) ( tmodel, tcmd )
                        else
                            (,) ( model.breakTimer, Cmd.none ) (Timer.update Timer.Start tmodel)
                    else
                        (,) ( model.breakTimer, Cmd.none ) ( tmodel, tcmd )

                activeTimer =
                    case timerMsg of
                        Timer.Alarm ->
                            if model.useBreakTimer then
                                BreakTimer
                            else
                                WorkTimer

                        _ ->
                            model.activeTimer

                ( team, _ ) =
                    case timerMsg of
                        Timer.Start ->
                            if model.autoRotateTeam then
                                (Team.update Team.SetNextMemberActive model.team)
                            else
                                ( model.team, Cmd.none )

                        _ ->
                            ( model.team, Cmd.none )
            in
                ( { model
                    | workTimer = workTimer
                    , activeTimer = activeTimer
                    , breakTimer = breakTimer
                    , team = team
                  }
                , Cmd.map WorkTimerMsg tcmd
                )

        TeamMsg teamMsg ->
            let
                ( tmodel, tmsg ) =
                    Team.update teamMsg model.team
            in
                ( { model | team = tmodel }, Cmd.map TeamMsg tmsg )

        UpdateAutoRestart flag ->
            ( { model | autoRestart = flag }, Cmd.none )

        UpdateAutoRotateTeam flag ->
            ( { model | autoRotateTeam = flag }, Cmd.none )

        UpdateUseBreakTimer flag ->
            ( { model | useBreakTimer = flag }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        timer =
            if model.activeTimer == BreakTimer then
                Html.App.map BreakTimerMsg (Timer.view model.breakTimer)
            else
                Html.App.map WorkTimerMsg (Timer.view model.workTimer)
    in
        div []
            [ optionView model
            , activeTimerView model
            , timer
            , Html.App.map TeamMsg (Team.view model.team)
            , text (toString model)
            ]


optionView : Model -> Html Msg
optionView model =
    div []
        [ label [] [ text "Use break timer" ]
        , input
            [ type' "checkbox"
            , checked model.useBreakTimer
            , name "use-break-timer"
            , onCheck UpdateUseBreakTimer
            ]
            []
        , label [] [ text "Auto-restart" ]
        , input
            [ type' "checkbox"
            , checked model.autoRestart
            , name "auto-restart"
            , onCheck UpdateAutoRestart
            ]
            []
        , label [] [ text "Auto-rotate team" ]
        , input
            [ type' "checkbox"
            , checked model.autoRotateTeam
            , name "auto-rotate-team"
            , onCheck UpdateAutoRotateTeam
            ]
            []
        ]


activeTimerView : Model -> Html Msg
activeTimerView model =
    div []
        [ case model.activeTimer of
            WorkTimer ->
                text "Work!"

            BreakTimer ->
                text "Cooldown!"
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map WorkTimerMsg (Timer.subscriptions model.workTimer)
        , Sub.map BreakTimerMsg (Timer.subscriptions model.breakTimer)
        ]
