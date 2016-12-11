port module Main exposing (..)

import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)
import Test exposing (..)
import Expect
import Helpers.ListHelpers exposing (stepElementLeft, stepElementRight)


tests : Test
tests =
    let
        elements =
            [ 1, 2, 3 ]
    in
        describe "Move element right one"
            [ test "Move left one from middle"
                <| \() ->
                    Expect.equal [ 2, 1, 3 ]
                        (stepElementLeft (matchFunction 2) elements)
            , test "Move element from last to middle"
                <| \() ->
                    Expect.equal [ 1, 3, 2 ]
                        (stepElementLeft (matchFunction 3) elements)
            , test "Move element from first to last"
                <| \() ->
                    Expect.equal [ 2, 3, 1 ]
                        (stepElementLeft (matchFunction 1) elements)
            , test "Handle single element list"
                <| \() ->
                    Expect.equal [ 1 ]
                        (stepElementLeft (matchFunction 1) [ 1 ])
            , test "Handle empty list"
                <| \() ->
                    Expect.equal []
                        (stepElementLeft (matchFunction 1) [])
            , test "Move right one from middle"
                <| \() ->
                    Expect.equal [ 1, 3, 2 ]
                        (stepElementRight (matchFunction 2) elements)
            , test "Move right one from first"
                <| \() ->
                    Expect.equal [ 2, 1, 3 ]
                        (stepElementRight (matchFunction 1) elements)
            , test "Move element from last to first"
                <| \() ->
                    Expect.equal [ 3, 1, 2 ]
                        (stepElementRight (matchFunction 3) elements)
            , test "Handle single element list"
                <| \() ->
                    Expect.equal [ 1 ]
                        (stepElementRight (matchFunction 1) [ 1 ])
            , test "Handle empty list"
                <| \() ->
                    Expect.equal []
                        (stepElementRight (matchFunction 1) [])
            ]


matchFunction : Int -> Int -> Bool
matchFunction soughtValue value =
    soughtValue == value


main : Program Value
main =
    run emit tests


port emit : ( String, Value ) -> Cmd msg
