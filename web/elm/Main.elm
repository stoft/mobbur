module Main exposing (..)

import Char exposing (fromCode)
import Components.Iterations as Iterations
import Components.Team as Team
import Components.Timer as Timer
import Date exposing (Date, now)
import Html exposing (..)
import Html.App
import Html.Attributes exposing (type', name, checked, class, href, style, value, max)
import Html.Events exposing (onCheck, onClick)
import Keyboard exposing (KeyCode, presses)
import Task exposing (perform)


main : Program Never
main =
    Html.App.program
        { init =
            ( initialModel, getCurrentDate )
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
    , today : Date
    , iterations : Iterations.Model
    }


type Page
    = MainView
    | SettingsView


type ActiveTimer
    = BreakTimer
    | WorkTimer


initialModel : Model
initialModel =
    { workTimer = Timer.initialModel 300
    , breakTimer = Timer.initialModel 30
    , activeTimer = WorkTimer
    , useBreakTimer = True
    , autoRestart = True
    , autoRotateTeam = True
    , team = Team.initialModel
    , currentView =
        -- SettingsView
        MainView
    , today = Date.fromTime 0
    , iterations = { iterationsToday = 0, iterationsTotal = 0 }
    }



--UPDATE


type Msg
    = Noop
    | BreakTimerMsg Timer.Msg
    | TeamMsg Team.Msg
    | KeyPress KeyCode
    | WorkTimerMsg Timer.Msg
    | SetCurrentDate Date
    | UpdateAutoRestart Bool
    | UpdateAutoRotateTeam Bool
    | UpdateUseBreakTimer Bool
    | UpdateView Page


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        SetCurrentDate date ->
            ( { model | today = date }, Cmd.none )

        KeyPress code ->
            handleKeyPress code model

        BreakTimerMsg timerMsg ->
            handleBreakTimerMsg timerMsg model

        WorkTimerMsg timerMsg ->
            handleWorkTimerMsg timerMsg model

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


handleKeyPress : KeyCode -> Model -> ( Model, Cmd Msg )
handleKeyPress code model =
    let
        toggleTimer timer =
            let
                ( model', _ ) =
                    Timer.update Timer.Toggle timer
            in
                model'

        ( workTimer', breakTimer' ) =
            case model.activeTimer of
                WorkTimer ->
                    ( (toggleTimer model.workTimer), model.breakTimer )

                BreakTimer ->
                    ( model.workTimer, (toggleTimer model.breakTimer) )
    in
        case (fromCode code) of
            ' ' ->
                if model.currentView == MainView then
                    ( { model | workTimer = workTimer', breakTimer = breakTimer' }, Cmd.none )
                else
                    ( model, Cmd.none )

            'e' ->
                if model.currentView == MainView then
                    ( { model | currentView = SettingsView }, Cmd.none )
                else
                    ( model, Cmd.none )

            _ ->
                ( model, Cmd.none )


handleBreakTimerMsg : Timer.Msg -> Model -> ( Model, Cmd Msg )
handleBreakTimerMsg timerMsg model =
    let
        ( tmodel, tmsg ) =
            Timer.update timerMsg model.breakTimer

        -- newToday =
        --   case model.today == Date.fromTime 0 then
        --
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


handleWorkTimerMsg : Timer.Msg -> Model -> ( Model, Cmd Msg )
handleWorkTimerMsg timerMsg model =
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
                        -- (BreakTimer, (Iterations.update Iterations.Increment model.iterations))
                    else
                        WorkTimer

                -- (WorkTimer, (Iterations.update Iterations.Increment model.iterations))
                _ ->
                    model.activeTimer

        ( team, _ ) =
            case timerMsg of
                Timer.Alarm ->
                    if model.autoRotateTeam then
                        (Team.update Team.SetNextMemberActive model.team)
                    else
                        ( model.team, Cmd.none )

                Timer.Start ->
                    if model.autoRotateTeam && model.team.activeMember == Nothing then
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map WorkTimerMsg (Timer.subscriptions model.workTimer)
        , Sub.map BreakTimerMsg (Timer.subscriptions model.breakTimer)
        , Sub.map TeamMsg (Team.subscriptions model.team)
        , Sub.map KeyPress (Keyboard.presses (\code -> code))
        ]



-- EFFECTS


getCurrentDate : Cmd Msg
getCurrentDate =
    Task.perform SetCurrentDate SetCurrentDate Date.now



-- VIEW


view : Model -> Html Msg
view model =
    section [ class "hero is-fullheight" ]
        [ div [ class "hero-head" ] [ navigationBar model ]
        , div [ class "hero-body" ]
            [ div [ class "container is-fluid" ]
                [ pageView model
                ]
            ]
        , div [ class "hero-footer" ]
            [ navFooter model
            ]
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
                    [ a [ href "https://github.com/stoft/mobbur" ]
                        [ h5 [ class "title is-5" ]
                            [ text "mobbur" ]
                        ]
                    ]
                ]
            , div [ class "nav-right" ]
                [ div [ class "nav-item" ] [ item ]
                ]
            ]


navFooter : Model -> Html Msg
navFooter model =
    nav [ class "nav" ]
        [ div [ class "nav-center" ]
            [ div [ class "nav-item" ]
                [ h5 [ class "title is-5" ] [ text model.team.name ] ]
            ]
        ]


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

        activeMember =
            case model.team.activeMember of
                Just id' ->
                    List.filter (\m -> m.id' == id') model.team.members
                        |> List.head

                Nothing ->
                    Nothing

        timerContent =
            Html.App.map msgType (Timer.displayView activeTimer)

        getNick member =
            Maybe.withDefault { nick = "", id' = 0, state = Team.DisplayingMember } member |> .nick

        content =
            if (model.activeTimer == BreakTimer && activeMember /= Nothing) then
                [ h3 [ class "title is-3" ] [ text "Cooldown!" ]
                , h4 [ class "title is-4" ] [ text ("Up next: " ++ (getNick activeMember)) ]
                , timerContent
                ]
            else if activeMember /= Nothing then
                [ a [ class "title is-4", onClick (TeamMsg Team.SetNextMemberActive) ]
                    [ text (getNick activeMember) ]
                , timerContent
                ]
            else
                [ timerContent ]
    in
        div [ class "has-text-centered" ] content


progressBar : Html Msg
progressBar =
    progress
        [ class "progress is-primary is-small"
        , value "30"
        , Html.Attributes.max "100"
        ]
        [ text "foo" ]


settingsView : Model -> Html Msg
settingsView model =
    let
        optionSettings =
            optionView model

        workTimerSettings =
            div [ class "tile is-parent" ]
                [ div [ class "tile notification is-primary is-child" ]
                    [ h4 [ class "title" ] [ text "Timer" ]
                    , Html.App.map WorkTimerMsg (Timer.settingsView model.workTimer)
                    ]
                ]

        breakTimerSettings =
            div [ class "tile is-parent" ]
                [ div [ class "tile notification is-warning is-child" ]
                    [ h4 [ class "title" ] [ text "Cooldown" ]
                    , Html.App.map BreakTimerMsg (Timer.settingsView model.breakTimer)
                    ]
                ]

        teamSettings =
            div [ class "tile is-parent" ] [ Html.App.map TeamMsg (Team.teamSettingsView model.team) ]

        teamMemberSettings =
            div [ class "tile is-parent" ] [ Html.App.map TeamMsg (Team.memberSettingsView model.team) ]

        team =
            if model.team.members /= [] then
                div [ class "tile" ] [ teamSettings, teamMemberSettings ]
            else
                div [ class "tile" ] [ teamSettings ]

        timerSettings =
            if model.useBreakTimer then
                div [ class "tile" ] [ optionSettings, workTimerSettings, breakTimerSettings ]
            else
                div [ class "tile" ] [ optionSettings, workTimerSettings ]
    in
        div [ class "tile is-ancestor is-vertical" ]
            [ timerSettings, team ]


optionView : Model -> Html Msg
optionView model =
    div [ class "tile is-parent" ]
        [ div [ class "tile is-child notification is-success" ]
            [ h4 [ class "title" ]
                [ text "General" ]
            , div [ class "control-group is-grouped" ]
                [ div [ class "control" ]
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
                , div [ class "control" ]
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
                , div [ class "control" ]
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
