module State.Iterations exposing (update)

import Types.Iterations exposing (Model, Msg(..))


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model
                | iterationsToday = model.iterationsToday + 1
                , iterationsTotal = model.iterationsTotal + 1
            }
