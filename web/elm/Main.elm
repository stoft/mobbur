module Main exposing (main)

import Html.App
import App.State exposing (update, subscriptions)
import Views.App exposing (view)


main : Program { teamName : String }
main =
    Html.App.programWithFlags
        { init =
            \flags -> App.State.init flags
            -- ( App.State.initialModel
            -- , Cmd.batch
            --     [ App.State.getCurrentDate
            --     , App.State.sendInitialState App.State.initialModel
            --     ]
            -- )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- programWithFlags : { init : flags -> ( model, Platform.Cmd.Cmd msg )
--   , update : msg -> model -> ( model, Platform.Cmd.Cmd msg )
--   , subscriptions : model -> Platform.Sub.Sub msg , view : model -> Html msg } -> Platform.Program flags
