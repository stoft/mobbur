module State.Timer exposing (..)

import Helpers.Timer exposing (stringToSeconds)
import State.Comm as Comm exposing (alarm)
import Task exposing (perform)
import Time exposing (every, second)
import Types.Timer exposing (..)


--INIT


initialModel : Int -> Model
initialModel seconds =
    { countdown = seconds
    , interval = seconds
    , state = Stopped
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel 480, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Alarm ->
            update Reset model

        Edit ->
            ( { model | state = Editing, countdown = model.interval }, Cmd.none )

        Reset ->
            ( { model | state = Stopped, countdown = model.interval }, Cmd.none )

        Start ->
            ( { model | state = Started }, Cmd.none )

        Pause ->
            ( { model | state = Paused }, Cmd.none )

        Toggle ->
            let
                newState =
                    case model.state of
                        Paused ->
                            Started

                        Stopped ->
                            Started

                        _ ->
                            Paused
            in
                ( { model | state = newState }, Cmd.none )

        Tick ->
            if (model.state == Started) && (model.countdown == 1) then
                ( { model | countdown = model.countdown - 1 }, Comm.alarm () )
            else if (model.state == Started) && (model.countdown < 1) then
                -- ( model, Cmd.map (always Reset) Cmd.none )
                ( model, Task.perform (always Alarm) (always Alarm) (Task.succeed ()) )
            else if model.state == Started then
                ( { model | countdown = model.countdown - 1 }, Cmd.none )
            else
                ( model, Cmd.none )

        UpdateMinutes time ->
            let
                minutes =
                    stringToSeconds time

                total =
                    (minutes * 60) + (rem model.interval 60)
            in
                case model.state of
                    Stopped ->
                        ( { model | countdown = total, interval = total }, Cmd.none )

                    _ ->
                        ( { model | interval = total }, Cmd.none )

        UpdateSeconds time ->
            let
                seconds =
                    stringToSeconds time

                total =
                    if seconds == -1 && model.interval < 1 then
                        model.interval
                    else
                        ((model.interval // 60) * 60) + seconds
            in
                case model.state of
                    Stopped ->
                        ( { model | countdown = total, interval = total }, Cmd.none )

                    _ ->
                        ( { model | interval = total }, Cmd.none )



-- SUBSCRIPTIONS & INBOUND PORTS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every second (\_ -> Tick)
