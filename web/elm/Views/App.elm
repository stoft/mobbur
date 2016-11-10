module Views.App exposing (..)

import Html exposing (Html, section, div, a, span, h5, h4, text, i, nav)
import Html.Attributes exposing (class, type', name, checked, class, href, style, value, max, title)
import Html.Events exposing (onCheck, onClick)
import App.Types as App exposing (Model, Msg, Page)
import Views.FrontPage exposing (frontPageView)
import Views.GlobalPage exposing (globalPageView)
import Views.SettingsPage exposing (settingsView)


view : Model -> Html Msg
view model =
    section [ class "hero is-fullheight" ]
        [ div [ class "hero-head" ] [ navigationBar model ]
        , div [ class "hero-body" ]
            [ div [ class "container is-fluid" ]
                [ pageView model
                ]
            ]
        , div [ class "hero-footer" ]
            [ navFooter model
            ]
        ]


pageView : Model -> Html Msg
pageView model =
    case model.currentView of
        App.MainView ->
            frontPageView model

        App.SettingsView ->
            settingsView model

        App.GlobalView ->
            globalPageView model


navigationBar : Model -> Html Msg
navigationBar model =
    let
        settingsItem =
            a [ href "#", onClick (App.UpdateView App.SettingsView) ]
                [ span [ class "icon is-medium" ]
                    [ i [ class "fa fa-cog" ] []
                    ]
                ]

        mainItem =
            a [ href "#", onClick (App.UpdateView App.MainView) ]
                [ span [ class "icon is-medium" ]
                    [ i [ class "fa fa-clock-o" ] []
                    ]
                ]

        item =
            case model.currentView of
                App.MainView ->
                    settingsItem

                App.SettingsView ->
                    mainItem

                App.GlobalView ->
                    settingsItem
    in
        nav [ class "nav" ]
            [ div [ class "nav-left" ]
                [ div [ class "nav-item" ]
                    [ a [ href "https://github.com/stoft/mobbur" ]
                        [ h5 [ class "title is-5" ]
                            [ text "mobbur" ]
                        ]
                    ]
                ]
            , div [ class "nav-right" ]
                [ div [ class "nav-item" ] [ item ]
                ]
            ]


navFooter : Model -> Html Msg
navFooter model =
    let
        numberOfTeams =
            model.globalTeams.numberOfTeams

        title' =
            if numberOfTeams == 1 then
                "1 team online"
            else
                toString numberOfTeams ++ " teams online"

        icon size' =
            span
                [ class ("icon " ++ size')
                , title title'
                ]
                [ i [ class "fa fa-globe", style [ ( "color", "#1fc8db" ) ] ] []
                ]

        globe =
            if numberOfTeams < 5 then
                icon "is-small"
            else if numberOfTeams < 10 then
                icon ""
            else
                icon "is-medium"

        ( jumpToView, link' ) =
            case model.currentView of
                App.MainView ->
                    ( App.GlobalView, "#globalStatus" )

                App.GlobalView ->
                    ( App.MainView, "#" )

                App.SettingsView ->
                    ( App.GlobalView, "#globalStatus" )
    in
        nav [ class "nav" ]
            [ div [ class "nav-center" ]
                [ div [ class "nav-item" ]
                    [ h5 [ class "title is-5" ] [ text model.team.name ] ]
                ]
            , div [ class "nav-right" ]
                [ div [ class "nav-item" ]
                    [ a [ href link', onClick (App.UpdateView jumpToView) ]
                        [ globe ]
                      -- h5 [ class "title is-5" alt (toString model.globalTeams.numberOfTeams) ]
                      --     [ text <| toString model.globalTeams.numberOfTeams ]
                    ]
                ]
            ]
