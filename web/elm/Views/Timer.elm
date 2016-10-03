module Views.Timer exposing (..)

import Html exposing (Html, div, a, text, label, input)
import Html.Attributes exposing (class, style, type', placeholder, name)
import Html.Events exposing (onClick, onInput)
import Helpers.Timer exposing (secondsToString, secondsToTimeRecord)
import Types.Timer exposing (..)


displayView : Model -> Html Msg
displayView model =
    let
        percentage =
            (toFloat model.countdown) / (toFloat model.interval) * 100 |> round

        getColor =
            if percentage > 30 then
                "is-primary"
            else if percentage > 10 then
                "is-warning"
            else
                "is-danger"

        ( action, color' ) =
            case model.state of
                Paused ->
                    ( Start, "is-default" )

                Stopped ->
                    ( Start, "is-default" )

                _ ->
                    ( Pause, getColor )
    in
        div [ class "column is-narrow" ]
            [ a
                [ class ("title box is-1 is-large notification " ++ color')
                , onClick action
                , style [ ( "font-size", "28vw" ), ( "border", "none" ) ]
                ]
                [ text <| secondsToString <| model.countdown ]
            ]


settingsView : Model -> Html Msg
settingsView model =
    inputFields model


inputFields : Model -> Html Msg
inputFields model =
    div [ class "control-group" ]
        [ label [ class "label" ]
            [ text "mins: "
            , input
                [ type' "number"
                , class "input"
                , style [ ( "width", "100px" ) ]
                , placeholder <| toString <| .minutes <| secondsToTimeRecord <| model.interval
                , Html.Attributes.value <| toString <| .minutes <| secondsToTimeRecord <| model.interval
                , name "minutes"
                , onInput UpdateMinutes
                ]
                []
            ]
        , label [ class "label" ]
            [ text "secs: "
            , input
                [ type' "number"
                , class "input"
                , style [ ( "width", "100px" ) ]
                , placeholder <| toString <| .seconds <| secondsToTimeRecord <| model.interval
                , Html.Attributes.value <| toString <| .seconds <| secondsToTimeRecord <| model.interval
                , name "seconds"
                , onInput UpdateSeconds
                ]
                []
            ]
        ]
