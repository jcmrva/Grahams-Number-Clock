module Utils exposing (..)


suc : Maybe Int -> Maybe Int
suc n =
    case n of
        Just x ->
            if x >= 0 then
                Just (x + 1)
            else
                Nothing

        Nothing ->
            Nothing


toStringList : String -> List String
toStringList =
    (String.toList >> (List.map String.fromChar))
