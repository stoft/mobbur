port module Components.Timer exposing (..)

import Html exposing (..)


-- import Html.App as App

import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (toInt)
import Task
import Time exposing (Time, second)


-- MODEL


type alias Model =
    { countdown : Int
    , interval : Int
    , state : State
    }


type alias TimeRecord =
    { minutes : Int, seconds : Int }


type State
    = Started
    | Paused
    | Stopped
    | Editing


initialModel : Int -> Model
initialModel seconds =
    { countdown = seconds
    , interval = seconds
    , state = Stopped
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel 480, Cmd.none )


secondsToTimeRecord : Int -> TimeRecord
secondsToTimeRecord seconds =
    let
        mins =
            seconds // 60

        secs =
            rem seconds 60
    in
        { minutes = mins, seconds = secs }


secondsToString : Int -> String
secondsToString seconds =
    let
        minutes =
            seconds // 60 |> toString |> String.padLeft 2 '0'

        secs =
            rem seconds 60 |> toString |> String.padLeft 2 '0'
    in
        minutes ++ ":" ++ secs


stringToSeconds : String -> Int
stringToSeconds string =
    Result.withDefault 0 (String.toInt string)



-- UPDATE


type Msg
    = Edit
    | Alarm
    | Reset
    | Pause
    | Start
    | Tick
    | UpdateMinutes String
    | UpdateSeconds String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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

        Tick ->
            if (model.state == Started) && (model.countdown == 1) then
                ( { model | countdown = model.countdown - 1 }, alarm () )
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
                    (minutes * 60) + (rem model.countdown 60)
            in
                ( { model | countdown = total, interval = total }, Cmd.none )

        UpdateSeconds time ->
            let
                seconds =
                    stringToSeconds time

                total =
                    if seconds == -1 && model.countdown < 1 then
                        model.countdown
                    else
                        ((model.countdown // 60) * 60) + seconds
            in
                ( { model | countdown = total, interval = total }, Cmd.none )



-- OUTBOUND PORTS


port alarm : () -> Cmd msg



-- SUBSCRIPTIONS & INBOUND PORTS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every second (\_ -> Tick)



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ (if model.state == Started then
            pauseButton
           else
            startButton
          )
        , countdownTimer model
          -- , text (toString model)
        ]


countdownTimer : Model -> Html Msg
countdownTimer model =
    div []
        [ case model.state of
            Editing ->
                inputFields model

            _ ->
                div [ onClick Edit ] [ text <| secondsToString <| model.countdown ]
        ]


inputFields : Model -> Html Msg
inputFields model =
    div []
        [ input
            [ type' "number"
            , placeholder <| toString <| .minutes <| secondsToTimeRecord <| model.countdown
            , Html.Attributes.value <| toString <| .minutes <| secondsToTimeRecord <| model.countdown
            , name "minutes"
            , onInput UpdateMinutes
            ]
            []
        , text ":"
        , input
            [ type' "number"
            , placeholder <| toString <| .seconds <| secondsToTimeRecord <| model.countdown
            , Html.Attributes.value <| toString <| .seconds <| secondsToTimeRecord <| model.countdown
            , name "seconds"
            , onInput UpdateSeconds
            ]
            []
        ]


startButton : Html Msg
startButton =
    button [ onClick Start ] [ text ">" ]


pauseButton : Html Msg
pauseButton =
    button [ onClick Pause ] [ text "||" ]
