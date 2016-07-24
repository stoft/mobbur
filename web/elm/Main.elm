module Main exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (type', name, checked, class, href, style, value, max)
import Html.Events exposing (onCheck, onClick)
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
    , currentView : Page
    }


type Page
    = MainView
    | SettingsView


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
    , currentView = MainView
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
    | UpdateView Page


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
                        Timer.Alarm ->
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

        UpdateView page ->
            ( { model | currentView = page }, Cmd.none )


view : Model -> Html Msg
view model =
    section [ class "hero is-fullheight" ]
        [ div [ class "hero-head" ] [ navigationBar model ]
        , div [ class "hero-body" ]
            [ div [ class "container" ]
                [ pageView model
                ]
            ]
        , div [ class "hero-footer" ]
            []
        ]


navigationBar : Model -> Html Msg
navigationBar model =
    let
        settingsItem =
            a [ href "#settings", onClick (UpdateView SettingsView) ]
                [ span [ class "icon is-medium" ]
                    [ i [ class "fa fa-cog" ] []
                    ]
                ]

        mainItem =
            a [ href "#", onClick (UpdateView MainView) ]
                [ span [ class "icon is-medium" ]
                    [ i [ class "fa fa-clock-o" ] []
                    ]
                ]

        item =
            case model.currentView of
                MainView ->
                    settingsItem

                SettingsView ->
                    mainItem
    in
        nav [ class "nav" ]
            [ div [ class "nav-left" ]
                [ div [ class "nav-item" ]
                    [ h1 [ class "title is-5" ] [ text "mobbur" ]
                    ]
                ]
            , div [ class "nav-right" ]
                [ div [ class "nav-item" ] [ item ]
                ]
            ]



-- , div [ class "nav-center" ]
--     [ div [ class "nav-item" ]
--         [ span [ class "tag is-primary is-medium" ] [ text ("the " ++ model.team.name) ]
--         ]
--     ]


pageView : Model -> Html Msg
pageView model =
    case model.currentView of
        MainView ->
            frontPageView model

        SettingsView ->
            settingsView model


frontPageView : Model -> Html Msg
frontPageView model =
    let
        ( activeTimer, msgType ) =
            case model.activeTimer of
                WorkTimer ->
                    ( model.workTimer, WorkTimerMsg )

                BreakTimer ->
                    ( model.breakTimer, BreakTimerMsg )
    in
        div [ class "has-text-centered" ]
            [ h4 [ class "title is-medium" ] [ text (model.team.name) ]
            , Html.App.map msgType (Timer.displayView activeTimer)
            , progress [ class "is-primary is-small is-responsive", value "30", Html.Attributes.max "100" ] [ text "foo" ]
            ]


settingsView : Model -> Html Msg
settingsView model =
    let
        timer =
            if model.activeTimer == BreakTimer then
                Html.App.map BreakTimerMsg (Timer.view model.breakTimer)
            else
                Html.App.map WorkTimerMsg (Timer.view model.workTimer)
    in
        div [ class "has-text-centered" ]
            [ activeTimerView model
            , timer
            , Html.App.map WorkTimerMsg (Timer.settingsView model.workTimer)
            , Html.App.map BreakTimerMsg (Timer.settingsView model.breakTimer)
            , Html.App.map TeamMsg (Team.view model.team)
            , optionView model
            ]


optionView : Model -> Html Msg
optionView model =
    div [ class "column is-narrow is-grouped" ]
        [ div [ class "" ]
            [ label [ class "checkbox" ]
                [ input
                    [ type' "checkbox"
                    , checked model.useBreakTimer
                    , name "use-break-timer"
                    , onCheck UpdateUseBreakTimer
                    ]
                    []
                , text "Use cooldown"
                ]
            ]
        , div [ class "" ]
            [ label [ class "checkbox" ]
                [ input
                    [ type' "checkbox"
                    , checked model.autoRestart
                    , name "auto-restart"
                    , onCheck UpdateAutoRestart
                    ]
                    []
                , text "Auto-restart"
                ]
            ]
        , div [ class "" ]
            [ label [ class "checkbox" ]
                [ input
                    [ type' "checkbox"
                    , checked model.autoRotateTeam
                    , name "auto-rotate-team"
                    , onCheck UpdateAutoRotateTeam
                    ]
                    []
                , text "Auto-rotate team"
                ]
            ]
        ]


activeTimerView : Model -> Html Msg
activeTimerView model =
    div [ class "column" ]
        [ case model.activeTimer of
            WorkTimer ->
                span [] []

            -- span [ class "title is-5" ] [ text "Work!" ]
            BreakTimer ->
                span [ class "title is-5" ] [ text "Cooldown!" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map WorkTimerMsg (Timer.subscriptions model.workTimer)
        , Sub.map BreakTimerMsg (Timer.subscriptions model.breakTimer)
        ]
