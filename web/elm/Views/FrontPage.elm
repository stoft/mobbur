module Views.FrontPage exposing (..)

import Html.App
import Html exposing (Html, div, h3, h4, a, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Types.App as App exposing (Model, Msg)
import Types.Team as Team
import Views.Timer as Timer


frontPageView : Model -> Html Msg
frontPageView model =
    let
        ( activeTimer, msgType ) =
            case model.activeTimer of
                App.WorkTimer ->
                    ( model.workTimer, App.WorkTimerMsg )

                App.BreakTimer ->
                    ( model.breakTimer, App.BreakTimerMsg )

        activeMember =
            case model.team.activeMember of
                Just id' ->
                    List.filter (\m -> m.id' == id') model.team.members
                        |> List.head

                Nothing ->
                    Nothing

        timerContent =
            Html.App.map msgType (Timer.displayView activeTimer)

        getNick member =
            Maybe.withDefault { nick = "", id' = 0, state = Team.DisplayingMember } member |> .nick

        content =
            if (model.activeTimer == App.BreakTimer && activeMember /= Nothing) then
                [ h3 [ class "title is-3" ] [ text "Cooldown!" ]
                , h4 [ class "title is-4" ] [ text ("Up next: " ++ (getNick activeMember)) ]
                , timerContent
                ]
            else if activeMember /= Nothing then
                [ a [ class "title is-4", onClick (App.TeamMsg Team.SetNextMemberActive) ]
                    [ text (getNick activeMember) ]
                , timerContent
                ]
            else
                [ timerContent ]
    in
        div [ class "has-text-centered" ] content



-- TODO: Possibly remove?
--
-- activeTimerView : Model -> Html Msg
-- activeTimerView model =
--     div [ class "column" ]
--         [ case model.activeTimer of
--             WorkTimer ->
--                 span [] []
--
--             BreakTimer ->
--                 span [ class "title is-5" ] [ text "Cooldown!" ]
--         ]
