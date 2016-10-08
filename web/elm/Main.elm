module Main exposing (main)

import Html.App
import App.State exposing (update, subscriptions)
import Views.App exposing (view)


main : Program Never
main =
    Html.App.program
        { init =
            ( App.State.initialModel, App.State.getCurrentDate )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
