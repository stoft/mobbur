module Views.SettingsPage exposing (..)

import Html.App
import Html exposing (Html, div, h3, h4, a, text, label, input)
import Html.Attributes exposing (class, type', checked, name)
import Html.Events exposing (onClick, onCheck)
import Types.App as App exposing (Model, Msg)
import Views.Team as Team
import Views.Timer as Timer


settingsView : Model -> Html Msg
settingsView model =
    let
        optionSettings =
            optionView model

        workTimerSettings =
            [ h4 [ class "title" ] [ text "Timer" ]
            , Html.App.map App.WorkTimerMsg (Timer.settingsView model.workTimer)
            ]
                |> childTile "is-primary"
                |> parentTile

        breakTimerSettings =
            [ h4 [ class "title" ] [ text "Cooldown" ]
            , Html.App.map App.BreakTimerMsg (Timer.settingsView model.breakTimer)
            ]
                |> childTile "is-warning"
                |> parentTile

        teamSettings =
            Html.App.map App.TeamMsg (Team.teamSettingsView model.team) |> parentTile

        teamMemberSettings =
            Html.App.map App.TeamMsg (Team.memberSettingsView model.team)
                |> parentTile

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
                [ controlCheckBox "use-break-timer" "Use cooldown" model.useBreakTimer App.UpdateUseBreakTimer
                , controlCheckBox "auto-restart" "Auto-restart" model.autoRestart App.UpdateAutoRestart
                , controlCheckBox "auto-rotate-team" "Auto-rotate team" model.autoRotateTeam App.UpdateAutoRotateTeam
                ]
            ]
        ]


controlCheckBox : String -> String -> Bool -> (Bool -> App.Msg) -> Html Msg
controlCheckBox name_ text_ flag msg =
    div [ class "control" ]
        [ label [ class "checkbox" ]
            [ input
                [ type' "checkbox"
                , checked flag
                , name name_
                , onCheck msg
                ]
                []
            , text text_
            ]
        ]



--
-- tile : String -> String -> Html Msg -> Html Msg
-- tile title' color' content =
--     [ h4 [ class "title" ] [ text "Timer" ]
--     , Html.App.map App.WorkTimerMsg (Timer.settingsView model.workTimer)
--     ]
--         |> childTile "is-primary"
--         |> parentTile


parentTile : Html Msg -> Html Msg
parentTile child =
    div [ class "tile is-parent" ] [ child ]


childTile : String -> List (Html Msg) -> Html Msg
childTile color' content =
    div [ class ("tile is-child notification " ++ color') ] content
