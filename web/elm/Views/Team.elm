module Views.Team exposing (..)

import Dom exposing (focus)
import Html exposing (Html, text, div, button, input, span, h4, i, label, a)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onBlur, onSubmit, onFocus)
import Task exposing (perform)
import Types.Team as Team exposing (Model, Msg)


teamSettingsView : Model -> Html Msg
teamSettingsView model =
    div [ class "tile notification is-info" ]
        [ div [ class "tile is-child" ]
            [ h4 [ class "title" ] [ text "Team" ]
            , label [ class "label" ]
                [ text "Team Name" ]
            , input
                [ type' "text"
                , class "input"
                , value model.name
                , name "team-name"
                , onInput Team.UpdateTeamName
                , onBlur Team.SubmitTeamName
                ]
                []
            , label [ class "label" ] [ text "Add Member" ]
            , div [ class "control has-addons" ]
                [ renderMemberInput model
                , button [ class "button is-info is-inverted", onClick Team.AddMember ]
                    [ span [ class "icon" ]
                        [ i [ class "fa fa-plus-square" ] [] ]
                    ]
                ]
            ]
        ]


memberSettingsView : Model -> Html Msg
memberSettingsView model =
    div [ class "tile is-child notification is-info" ]
        [ h4 [ class "title" ] [ text "Members" ]
        , renderMemberList model.activeMember model.members
        , button [ class "button is-info is-inverted", onClick Team.SetNextMemberActive ]
            [ span [ class "icon" ]
                [ i [ class "fa fa-fast-forward" ] []
                ]
            ]
        ]


renderMemberList : Maybe Int -> List Team.TeamMember -> Html Msg
renderMemberList activeMember members =
    case activeMember of
        Just id' ->
            div [] (List.map (renderMember id') members)

        Nothing ->
            div [] (List.map (renderMember 0) members)


renderMemberInput : Model -> Html Msg
renderMemberInput model =
    input
        [ type' "text"
        , class "input"
        , placeholder "Add member nick..."
        , name "nick"
        , value model.newNick
        , onInput Team.UpdateNewNick
        , onSubmit Team.AddMember
        ]
        []


renderMember : Int -> Team.TeamMember -> Html Msg
renderMember activeMember member =
    case member.state of
        Team.Editing ->
            let
                ( _, memberId ) =
                    ( Task.perform (Debug.log "failed" (always Team.NoOp)) (always Team.NoOp) (Dom.focus ("team-member-" ++ toString member.id'))
                    , member.id'
                    )
            in
                input
                    [ type' "text"
                    , id ("team-member-" ++ toString member.id')
                    , class "input"
                    , name "nick"
                    , value member.nick
                    , onInput (Team.UpdateNick member.id')
                    , onBlur (Team.SubmitNick member.id')
                    ]
                    []

        Team.DisplayingMember ->
            if member.id' == activeMember then
                div
                    [ onClick (Team.EditMember member.id')
                    , id ("team-member-" ++ toString member.id')
                    ]
                    [ a [ class "title label is-4" ] [ text (member.nick) ] ]
            else
                div
                    [ onClick (Team.EditMember member.id')
                    , id ("team-member-" ++ toString member.id')
                    ]
                    [ a [ class "title is-5" ] [ text member.nick ]
                    ]
