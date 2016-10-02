module Views.SettingsPage exposing (..)

import Html.App
import Html exposing (Html, div, h3, h4, a, text, label, input)
import Html.Attributes exposing (class, type', checked, name)
import Html.Events exposing (onClick, onCheck)
import Types.App as App exposing (Model, Msg)
import Components.Timer as Timer
import Views.Team as Team


settingsView : Model -> Html Msg
settingsView model =
    let
        optionSettings =
            optionView model

        workTimerSettings =
            div [ class "tile is-parent" ]
                [ div [ class "tile notification is-primary is-child" ]
                    [ h4 [ class "title" ] [ text "Timer" ]
                    , Html.App.map App.WorkTimerMsg (Timer.settingsView model.workTimer)
                    ]
                ]

        breakTimerSettings =
            div [ class "tile is-parent" ]
                [ div [ class "tile notification is-warning is-child" ]
                    [ h4 [ class "title" ] [ text "Cooldown" ]
                    , Html.App.map App.BreakTimerMsg (Timer.settingsView model.breakTimer)
                    ]
                ]

        teamSettings =
            div [ class "tile is-parent" ] [ Html.App.map App.TeamMsg (Team.teamSettingsView model.team) ]

        teamMemberSettings =
            div [ class "tile is-parent" ] [ Html.App.map App.TeamMsg (Team.memberSettingsView model.team) ]

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
                            , onCheck App.UpdateUseBreakTimer
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
                            , onCheck App.UpdateAutoRestart
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
                            , onCheck App.UpdateAutoRotateTeam
                            ]
                            []
                        , text "Auto-rotate team"
                        ]
                    ]
                ]
            ]
        ]
