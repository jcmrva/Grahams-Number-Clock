module MatchGame exposing (..)


type alias ScoreData =
    { occurrances : Int
    , selected : Int
    , invalidSelected : Int
    , startDelayTime : Float
    , firstLastElapsedTime : Float
    , lastWaitTime : Float
    , fieldSize : Int
    }


type alias ScoreType =
    { matchLockAssist : Bool
    , selectionHintAssist : Bool
    }


type Proximity
    = Dense
    | Moderate
    | Sparse


selectionProximity : List Int -> Int -> Proximity
selectionProximity nbrs width =
    Sparse
