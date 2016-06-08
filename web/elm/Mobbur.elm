port module Mobbur exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (..)
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
    , started : Bool
    }


initialModel : Model
initialModel =
    { countdown = 2
    , started = False
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- UPDATE


type Msg
    = Alarm
    | Reset
    | Pause
    | Start
    | Tick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Alarm ->
            ( { model | started = False }, Cmd.none )

        Reset ->
            ( initialModel, Cmd.none )

        Start ->
            ( { model | started = True }, Cmd.none )

        Pause ->
            ( { model | started = False }, Cmd.none )

        Tick ->
            if (model.started == True) && (model.countdown < 1) then
                ( initialModel, alarm () )
            else if model.started == True then
                ( { model | countdown = model.countdown - 1 }, Cmd.none )
            else
                ( model, Cmd.none )



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
        [ (if model.started == True then
            pauseButton
           else
            startButton
          )
        , countdownTimer model
        ]


countdownTimer : Model -> Html Msg
countdownTimer model =
    let
        minutes =
            model.countdown // 60

        seconds =
            rem model.countdown 60
    in
        div []
            [ div [] [ text ((toString minutes) ++ ":" ++ (toString seconds)) ]
            ]


startButton : Html Msg
startButton =
    button [ onClick Start ] [ text ">" ]


pauseButton : Html Msg
pauseButton =
    button [ onClick Pause ] [ text "||" ]
