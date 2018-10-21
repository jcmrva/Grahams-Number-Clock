module Utils exposing (toStringList, toTupledList)


toStringList : String -> List String
toStringList =
    String.toList >> List.map String.fromChar


toTupledList : String -> List ( Int, String )
toTupledList =
    toStringList >> List.indexedMap Tuple.pair
