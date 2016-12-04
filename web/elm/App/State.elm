module App.State exposing (..)

import Char exposing (fromCode)
import Date exposing (Date, now)
import Keyboard exposing (KeyCode, presses)
import App.Types as App exposing (Model, ActiveTimer(..), Page(..), Msg(..))
import Comm.State as Comm
import Comm.NativeToPortConverter
import Team.State as Team
import Timer.State as Timer
import Timer.Types as Timer
import Team.Types as Team
import Task exposing (perform)


-- SUBSCRIPTIONS


getCurrentDate : Cmd Msg
getCurrentDate =
    Task.perform SetCurrentDate App.SetCurrentDate Date.now


sendInitialState : Model -> Cmd Msg
sendInitialState model =
    Comm.teamStatus (Comm.NativeToPortConverter.convertModel model)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map App.WorkTimerMsg (Timer.subscriptions model.workTimer)
        , Sub.map App.BreakTimerMsg (Timer.subscriptions model.breakTimer)
        , Sub.map App.TeamMsg (Team.subscriptions model.team)
        , Sub.map App.KeyPress (Keyboard.presses (\code -> code))
        , Sub.map App.CommMsg (Comm.subscriptions model.globalTeams)
        , Sub.map App.CommMsg (Comm.teamSubscription Comm.initialReplicatedModel)
        ]



--INIT


init : { teamName : String } -> ( Model, Cmd Msg )
init flags =
    let
        model =
            initialModel

        cmds =
            Cmd.batch
                [ getCurrentDate
                , sendInitialState initialModel
                ]

        modifiedTeam team =
            { team | name = flags.teamName }
    in
        ( { model | team = (modifiedTeam model.team) }, cmds )


initialModel : Model
initialModel =
    { workTimer = Timer.initialModel 300 "http://www.nasa.gov/mp3/640149main_Computers%20are%20in%20Control.mp3"
    , breakTimer = Timer.initialModel 30 "http://www.nasa.gov/mp3/640148main_APU%20Shutdown.mp3"
    , activeTimer = App.WorkTimer
    , useBreakTimer = True
    , autoRestart = True
    , autoRotateTeam = True
    , team = Team.initialModel
    , currentView =
        -- SettingsView
        App.MainView
    , today = Date.fromTime 0
    , iterations = { iterationsToday = 0, iterationsTotal = 0 }
    , globalTeams = Comm.initialModel
    , clientID = ""
    }



--UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        CommMsg msg ->
            let
                ( newGlobalTeams, _ ) =
                    (Comm.update msg model.globalTeams)
            in
                ( { model | globalTeams = newGlobalTeams }, Cmd.none )

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
            ( { model | currentView = page }, Comm.teamStatus (Comm.NativeToPortConverter.convertModel model) )


handleKeyPress : KeyCode -> Model -> ( Model, Cmd Msg )
handleKeyPress keyCode model =
    case model.currentView of
        MainView ->
            handleMainViewKeyPress keyCode model

        GlobalView ->
            handleGlobalViewKeyPress keyCode model

        _ ->
            ( model, Cmd.none )


handleMainViewKeyPress : KeyCode -> Model -> ( Model, Cmd Msg )
handleMainViewKeyPress keyCode model =
    let
        ( workTimer_, breakTimer_ ) =
            case model.activeTimer of
                App.WorkTimer ->
                    ( (updateTimerWithKeyPress keyCode model.workTimer), model.breakTimer )

                App.BreakTimer ->
                    ( model.workTimer, (updateTimerWithKeyPress keyCode model.breakTimer) )
    in
        case (fromCode keyCode) of
            ' ' ->
                ( { model | workTimer = workTimer_, breakTimer = breakTimer_ }, Cmd.none )

            'r' ->
                ( { model | workTimer = workTimer_, breakTimer = breakTimer_ }, Cmd.none )

            'e' ->
                ( { model | currentView = SettingsView }, Cmd.none )

            'g' ->
                ( { model | currentView = GlobalView }, Cmd.none )

            _ ->
                ( model, Cmd.none )


handleGlobalViewKeyPress : KeyCode -> Model -> ( Model, Cmd Msg )
handleGlobalViewKeyPress keycode model =
    case (fromCode keycode) of
        ' ' ->
            ( { model | currentView = MainView }, Cmd.none )

        'g' ->
            ( { model | currentView = MainView }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateTimerWithKeyPress : KeyCode -> Timer.Model -> Timer.Model
updateTimerWithKeyPress keyCode timer =
    let
        keyPress =
            fromCode keyCode

        dictionary =
            [ ( ' ', Timer.Toggle ), ( 'r', Timer.Reset ) ]

        msg =
            (List.filter (\( char, _ ) -> char == keyPress) dictionary)
                |> List.head
                |> (Maybe.withDefault ( '_', Timer.NoOp ))
                |> snd
    in
        Timer.update msg timer |> fst


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
