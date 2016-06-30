module Main exposing (..)

import Html exposing (Html, text, div)
import Html.App
import Components.Timer as Timer


main : Program Never
main =
    Html.App.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--MODEL


type alias Model =
    { timer : Timer.Model }


initialModel : Model
initialModel =
    { timer = Timer.initialModel }



--UPDATE


type Msg
    = Noop
    | TimerMsg Timer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        TimerMsg timerMsg ->
            let
                ( tmodel, tmsg ) =
                    Timer.update timerMsg model.timer
            in
                ( { model | timer = tmodel }, Cmd.map TimerMsg tmsg )


view : Model -> Html Msg
view model =
    div []
        [ Html.App.map TimerMsg
            (Timer.view model.timer)
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map TimerMsg (Timer.subscriptions model.timer)
