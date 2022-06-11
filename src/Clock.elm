module Clock exposing (..)

import Options
import Time


type alias TimeParts =
    { hh : Int
    , mm : Int
    , ss : Int
    }


to12Hour : Int -> Int
to12Hour hh =
    if hh > 12 then
        hh - 12

    else if hh == 0 then
        12

    else
        hh


toTimeParts : Time.Zone -> Options.HourMode -> Time.Posix -> TimeParts
toTimeParts zone mode time =
    let
        hour =
            case mode of
                Options.Twelve ->
                    time |> Time.toHour zone |> to12Hour

                Options.TwentyFour ->
                    time |> Time.toHour zone

        toParts d =
            { hh = hour, mm = Time.toMinute zone d, ss = Time.toSecond zone d }
    in
    time
        |> toParts
