module Components.Iterations exposing (..)

-- MODEL


type alias Model =
    { iterationsToday : Int
    , iterationsTotal : Int
    }



-- UPDATE


type Msg
    = Increment


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model
                | iterationsToday = model.iterationsToday + 1
                , iterationsTotal = model.iterationsTotal + 1
            }
