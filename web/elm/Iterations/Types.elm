module Iterations.Types exposing (..)

-- MODEL


type alias Model =
    { iterationsToday : Int
    , iterationsTotal : Int
    }



-- UPDATE


type Msg
    = Increment
