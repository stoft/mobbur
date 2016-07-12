module Main exposing (..)

import Html exposing (Html, text, div, input, label)
import Html.App
import Html.Attributes exposing (type', name)
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
    , team = Team.initialModel
    }



--UPDATE


type Msg
    = Noop
    | BreakTimerMsg Timer.Msg
    | TeamMsg Team.Msg
    | WorkTimerMsg Timer.Msg
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
            in
                ( { model | breakTimer = tmodel, activeTimer = activeTimer }, Cmd.map BreakTimerMsg tmsg )

        WorkTimerMsg timerMsg ->
            let
                ( tmodel, tmsg ) =
                    Timer.update timerMsg model.workTimer

                activeTimer =
                    case timerMsg of
                        Timer.Alarm ->
                            if model.useBreakTimer then
                                BreakTimer
                            else
                                WorkTimer

                        _ ->
                            model.activeTimer
            in
                ( { model | workTimer = tmodel, activeTimer = activeTimer }, Cmd.map WorkTimerMsg tmsg )

        TeamMsg teamMsg ->
            let
                ( tmodel, tmsg ) =
                    Team.update teamMsg model.team
            in
                ( { model | team = tmodel }, Cmd.map TeamMsg tmsg )

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
            [ viewUseBreakTimer model
            , timer
            , Html.App.map TeamMsg (Team.view model.team)
            , text (toString model)
            ]


viewUseBreakTimer : Model -> Html Msg
viewUseBreakTimer model =
    div []
        [ label [] [ text "Use break timer" ]
        , input
            [ type' "checkbox"
            , Html.Attributes.checked model.useBreakTimer
            , name "useBreakTimer"
            , onCheck UpdateUseBreakTimer
            ]
            []
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map WorkTimerMsg (Timer.subscriptions model.workTimer)
        , Sub.map BreakTimerMsg (Timer.subscriptions model.breakTimer)
        ]
