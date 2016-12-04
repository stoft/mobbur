module Views.Timer exposing (..)

import Html exposing (Html, div, a, text, label, input, span, i, button)
import Html.Attributes exposing (class, style, type', placeholder, name, title)
import Html.Events exposing (onClick, onInput)
import Timer.Helpers exposing (secondsToString, secondsToTimeRecord)
import Timer.Types exposing (..)


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

        resetButton =
            a [ class "button is-link is-white", onClick Reset, title "Reset (r)" ]
                [ span [ class "icon is-medium" ] [ i [ class "fa fa-undo" ] [] ]
                ]

        ( action, color_, control ) =
            case model.state of
                Paused ->
                    ( Start, "is-default", resetButton )

                Stopped ->
                    ( Start, "is-default", resetButton )

                _ ->
                    ( Pause, getColor, div [] [] )
    in
        div [ class "column is-narrow unselectable" ]
            [ a
                [ class ("title box is-1 is-large notification " ++ color_)
                , onClick action
                , style [ ( "font-size", "28vw" ), ( "border", "none" ) ]
                ]
                [ text <| secondsToString <| model.countdown ]
            , control
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
        , label [ class "label" ]
            [ text "Audio URI: " ]
        , input
            [ type' "string"
            , class "input"
            , style [ ( "width", "200px" ) ]
            , placeholder <| model.audioUri
            , Html.Attributes.value <| model.audioUri
            , name "audio_uri"
            , onInput UpdateAudioURI
            ]
            []
        ]
