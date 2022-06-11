module Options exposing (..)


type Highlight
    = Random
    | All


type HourMode
    = Twelve
    | TwentyFour


type alias SiteOptions =
    { highlight : Highlight
    , numberGridWidth : Int
    , hourMode : HourMode
    , background : Bool
    , clockResolutionMillis : Float
    , rotateOnPortraitDisplay : Bool
    }


siteOptionsDefault : SiteOptions
siteOptionsDefault =
    { highlight = All
    , numberGridWidth = 24
    , hourMode = TwentyFour
    , background = True
    , clockResolutionMillis = 200
    , rotateOnPortraitDisplay = False
    }
