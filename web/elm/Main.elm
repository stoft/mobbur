module Main exposing (..)

import Html.App
import State.App exposing (update, subscriptions)
import Views.App exposing (view)


main : Program Never
main =
    Html.App.program
        { init =
            ( State.App.initialModel, State.App.getCurrentDate )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
