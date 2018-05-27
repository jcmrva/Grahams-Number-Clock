module Utils exposing (..)


toStringList : String -> List String
toStringList =
    String.toList >> (List.map String.fromChar)
