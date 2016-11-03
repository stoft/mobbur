module Views.GlobalPage exposing (..)

import App.Types exposing (Model, Msg)
import Html exposing (Html, div, text)
import Views.Tiles exposing (tileWithList, tile, tileWithOnlyTitle)


globalPageView : Model -> Html Msg
globalPageView model =
    let
        numberOfTeams =
            model.globalTeams.numberOfTeams

        title' =
            if numberOfTeams == 1 then
                "1 team online"
            else
                toString numberOfTeams ++ " teams online"
    in
        div []
            [ numbersCard model
            , namesCard model
            ]


numbersCard : Model -> Html Msg
numbersCard model =
    let
        numberOfTeams =
            model.globalTeams.numberOfTeams

        title =
            if numberOfTeams == 1 then
                (numberOfTeams |> toString) ++ " Team Online"
            else
                (numberOfTeams |> toString) ++ " Teams Online"
    in
        tileWithOnlyTitle title App.Types.Noop


namesCard : Model -> Html Msg
namesCard model =
    tileWithList "Teams" model.globalTeams.teamNames App.Types.Noop
