module Views.GlobalPage exposing (..)

import App.Types exposing (Model, Msg)
import Html exposing (Html, div, text)


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
        div [] [ text title' ]
