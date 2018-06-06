module Options exposing (..)

import Time exposing (Time)


type MatchType
    = Split
    | Connected


type MatchPart
    = HHMMSS MatchType
    | HHMM MatchType
    | MM
    | MMSS MatchType
    | SS


type Highlight
    = Random
    | All


type HourMode
    = Twelve
    | TwentyFour


type alias SiteOptions =
    { matchPart : MatchPart
    , highlight : Highlight
    , numberGridWidth : Int
    , hourMode : HourMode
    , background : Bool
    , clockResolutionMillis : Time
    , rotateOnPortraitDisplay : Bool
    }


siteOptionsDefault : SiteOptions
siteOptionsDefault =
    { matchPart = HHMMSS Split
    , highlight = All
    , numberGridWidth = 24
    , hourMode = TwentyFour
    , background = True
    , clockResolutionMillis = 200
    , rotateOnPortraitDisplay = False
    }
