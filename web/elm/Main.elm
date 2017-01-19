module Main exposing (main)

import Html
import App.State exposing (update, subscriptions)
import Views.App exposing (view)
import App.Types exposing (Model, Msg)


main : Program { teamName : String } App.Types.Model App.Types.Msg
main =
    Html.programWithFlags
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
