module Helpers.Timer exposing (..)

import String exposing (padLeft)
import Types.Timer exposing (TimeRecord)


secondsToTimeRecord : Int -> TimeRecord
secondsToTimeRecord seconds =
    let
        mins =
            seconds // 60

        secs =
            rem seconds 60
    in
        { minutes = mins, seconds = secs }


secondsToString : Int -> String
secondsToString seconds =
    let
        minutes =
            seconds // 60 |> toString |> String.padLeft 2 '0'

        secs =
            rem seconds 60 |> toString |> String.padLeft 2 '0'
    in
        minutes ++ ":" ++ secs


secondsToStrings : Int -> { minutes : String, seconds : String }
secondsToStrings seconds =
    let
        minutes =
            seconds // 60 |> toString |> String.padLeft 2 '0'

        secs =
            rem seconds 60 |> toString |> String.padLeft 2 '0'
    in
        { minutes = minutes, seconds = secs }


stringToSeconds : String -> Int
stringToSeconds string =
    Result.withDefault 0 (String.toInt string)
