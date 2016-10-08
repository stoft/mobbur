module Iterations.State exposing (update)

import Iterations.Types exposing (Model, Msg(..))


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model
                | iterationsToday = model.iterationsToday + 1
                , iterationsTotal = model.iterationsTotal + 1
            }
