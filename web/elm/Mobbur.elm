port module Mobbur exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (toInt)
import Time exposing (Time, second)


-- import Html.Attributes exposing (..)


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL

type alias Model =
  { countdown : Int
  , interval : Int
  , state : State
  , team : Team
  }

type alias Team =
  { name : String
  , members : List TeamMember
  }

type alias TeamMember = { nick : String }

type alias TimeRecord =
  { minutes : Int, seconds : Int }

type State =
  Started
  | Paused
  | Stopped
  | Editing


initialModel : Model
initialModel =
    { countdown = 480
    , interval = 480
    , state = Stopped
    , team = { name = "", members = [] }
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


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
    | Reset
    | Pause
    | Start
    | Tick
    | UpdateMinutes String
    | UpdateSeconds String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Alarm ->
        --     ( { model | state = Stopped }, Cmd.none )
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
                update Reset model
            else if model.state == Started then
                ( { model | countdown = model.countdown - 1 }, Cmd.none )
            else
                ( model, Cmd.none )

        UpdateMinutes time ->
          let
            minutes = stringToSeconds time
            total = Debug.log "total minutes and seconds" ((minutes * 60) + (rem model.countdown 60))
          in
          ( { model | countdown = total, interval = total }, Cmd.none)

        UpdateSeconds time ->
          let
            seconds = stringToSeconds time
            total = (model.countdown // 60) + seconds
          in
            ( { model | countdown = total, interval = total}, Cmd.none)


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
        ]


countdownTimer : Model -> Html Msg
countdownTimer model =
      div []
          [ case model.state of
              Editing ->
                  inputFields model
              _ -> div [ onClick Edit ] [ text
                          <| Debug.log "after secondsToString"
                          <| secondsToString
                          <| Debug.log "countdown"
                          <| model.countdown ]
          ]

inputFields : Model -> Html Msg
inputFields model =
  div []
  [input
    [ type' "number"
    , placeholder <| toString <| .minutes <| secondsToTimeRecord <| model.countdown
    , Html.Attributes.value <| toString <| .minutes <| secondsToTimeRecord <| model.countdown
    , name "minutes"
    , onInput UpdateMinutes
    ]
    []
    , text ":"
  , input [ type' "number"
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
