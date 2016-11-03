module Views.Tiles exposing (..)

import Html exposing (Html, div, text, h4)
import Html.Attributes exposing (class)


tile : String -> String -> a -> Html a
tile title content msg =
    div [ class "tile is-parent" ]
        [ div [ class "tile is-child notification is-success" ]
            [ h4 [ class "title" ]
                [ text title ]
            , div [ class "content" ]
                [ text content ]
            ]
        ]


tileWithOnlyTitle : String -> a -> Html a
tileWithOnlyTitle title msg =
    div [ class "tile is-parent" ]
        [ div [ class "tile is-child notification is-success" ]
            [ h4 [ class "title" ]
                [ text title ]
            ]
        ]


tileWithList : String -> List String -> a -> Html a
tileWithList title content msg =
    let
        wrapInDiv content =
            div [ class "content" ] [ text content ]

        list =
            List.map wrapInDiv content
    in
        div [ class "tile is-parent" ]
            [ div [ class "tile is-child notification is-success" ]
                ((h4 [ class "title" ]
                    [ text title ]
                 )
                    :: list
                )
            ]
