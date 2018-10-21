module MatchGame exposing (Element(..), GameData, InputAllowed(..), Options, Proximity(..), Score, ScoreType, TouchSelectType(..), selectionProximity)

import Date exposing (Date)


type alias GameData =
    { occurrances : Int
    , selected : Int
    , invalidSelected : Int
    , startDelayTime : Float
    , firstLastElapsedTime : Float
    , lastWaitTime : Float
    , fieldSize : Int
    , scoreHistory : Maybe List Score
    }


type alias Score =
    { maxPossible : Int
    , elementsIncluded : List Element
    , value : Int
    , occurredAt : Date
    }


type Element
    = Proximity
    | Selected
    | StartDelay
    | LastWait


type alias ScoreType =
    { matchLockAssist : Bool
    , selectionHintAssist : Bool
    }


type InputAllowed
    = Touch
    | Mouse
    | Both


type TouchSelectType
    = Initial
    | Last


type alias Options =
    { touchSelects : TouchSelectType
    , inputAllowed : InputAllowed
    , showScoreInProgress : Bool
    }


type Proximity
    = Dense
    | Moderate
    | Sparse


selectionProximity : List Int -> Int -> Proximity
selectionProximity nbrs width =
    Sparse
