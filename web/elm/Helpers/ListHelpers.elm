module Helpers.ListHelpers exposing (stepElementLeft, stepElementRight, randomizeList)

import Array
import Random


randomizeList : List a -> Int -> List a
randomizeList list seedInt =
    doRandomizeList [] (Array.fromList list) (Random.initialSeed seedInt)


doRandomizeList : List a -> Array.Array a -> Random.Seed -> List a
doRandomizeList newList originalArray seed =
    let
        max =
            (Array.length originalArray)

        ( elementIndex, newSeed ) =
            Random.step (Random.int 1 max) seed
    in
        if max >= 1 then
            let
                ( element, rest ) =
                    takeIndexedElement originalArray (elementIndex - 1)
            in
                case element of
                    Just elem ->
                        doRandomizeList (elem :: newList) rest newSeed

                    Nothing ->
                        doRandomizeList newList rest newSeed
        else
            newList


takeIndexedElement : Array.Array a -> Int -> ( Maybe a, Array.Array a )
takeIndexedElement array index =
    let
        indexedList =
            array |> Array.toIndexedList

        element =
            indexedList
                |> List.filter (\( i, a ) -> i == index)
                |> List.map (\( i, a ) -> a)
                |> List.head

        rest =
            indexedList
                |> List.filter (\( i, a ) -> i /= index)
                |> List.map (\( i, a ) -> a)
                |> Array.fromList
    in
        ( element, rest )


stepElementLeft : (a -> Bool) -> List a -> List a
stepElementLeft matchFunction list =
    (doStepElementLeft [] list Nothing matchFunction) |> List.reverse


stepElementRight : (a -> Bool) -> List a -> List a
stepElementRight matchFunction list =
    (doStepElementRight [] list Nothing matchFunction) |> List.reverse


doStepElementLeft : List a -> List a -> Maybe a -> (a -> Bool) -> List a
doStepElementLeft newList currentList maybePreviousElement matches =
    case ( newList, currentList, maybePreviousElement ) of
        --start of many list:
        ( [], currentElement :: t, Nothing ) ->
            if (matches currentElement) then
                currentElement :: (List.reverse t)
            else
                doStepElementLeft [] t (Just currentElement) matches

        -- middle of many list:
        ( nl, currentElement :: t, Just previousElement ) ->
            if (matches currentElement) then
                doStepElementLeft (currentElement :: nl) t (Just previousElement) matches
            else
                doStepElementLeft (previousElement :: nl) t (Just currentElement) matches

        -- end of many list:
        ( nl, [], Just previousElement ) ->
            previousElement :: nl

        -- all other lists (empty, only one member)
        _ ->
            currentList


doStepElementRight : List a -> List a -> Maybe a -> (a -> Bool) -> List a
doStepElementRight newList currentList maybeMatchedElement matches =
    case ( newList, currentList, maybeMatchedElement ) of
        --start of many list:
        ( nl, currentElement :: t, Nothing ) ->
            if (matches currentElement) then
                doStepElementRight nl t (Just currentElement) matches
            else
                doStepElementRight (currentElement :: nl) t Nothing matches

        --middle of many list:
        ( nl, currentElement :: t, Just matchedElement ) ->
            doStepElementRight (matchedElement :: (currentElement :: nl)) t Nothing matches

        ( nl, [], Just matchedElement ) ->
            nl ++ [ matchedElement ]

        ( nl, [], _ ) ->
            nl
