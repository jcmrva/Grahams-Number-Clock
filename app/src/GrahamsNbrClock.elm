module GrahamsNbrClock exposing (..)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (id, class)
import Options exposing (..)
import Values exposing (..)
import Dict exposing (Dict)
import Time exposing (..)
import Task
import Utils


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { title : String
    , time : Time.Posix
    , zone : Time.Zone
    , options : SiteOptions
    , hhPositions : Dict String (List Int)
    , mmPositions : Dict String (List Int)
    , ssPositions : Dict String (List Int)
    }


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


toTimeParts : Time.Zone -> HourMode -> Time.Posix -> TimeParts
toTimeParts zone mode time =
    let
        hour =
            case mode of
                Twelve ->
                    time |> Time.toHour zone |> to12Hour

                TwentyFour ->
                    time |> Time.toHour zone

        toParts d =
            { hh = hour, mm = Time.toMinute zone d, ss = Time.toSecond zone d }
    in
        time
            |> toParts


type alias Flags =
    { datetime : Float }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        hhPos =
            (if siteOptionsDefault.hourMode == TwentyFour then
                hour24
             else
                hour12
            )
                |> toNbrPositions

        mmssPos =
            mmss |> toNbrPositions

        initModel =
            { title = "Graham's Number Clock ↑↑↑"
            , time = flags.datetime |> floor |> millisToPosix
            , zone = Time.utc
            , options = siteOptionsDefault
            , hhPositions = hhPos
            , mmPositions = mmssPos
            , ssPositions = mmssPos
            }
    in
        ( initModel, Task.perform AdjustTimeZone Time.here )



-- UPDATE


type Msg
    = ReceiveTime Time.Posix
    | AdjustTimeZone Time.Zone
    | ChangeTitle String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveTime time ->
            let
                nextmodel =
                    { model | time = time }
            in
                ( nextmodel, Cmd.none )

        AdjustTimeZone z ->
            ( { model | zone = z }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every model.options.clockResolutionMillis ReceiveTime



-- VIEW


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


view : Model -> Document Msg
view model =
    let
        get tp dict =
            Dict.get (String.fromInt tp |> pad2) dict |> Maybe.withDefault [ 0 ]

        currPositions tp =
            { hh = get tp.hh model.hhPositions
            , mm = get tp.mm model.mmPositions
            , ss = get tp.ss model.ssPositions
            }

        timePos =
            (model.time)
                |> toTimeParts model.zone model.options.hourMode
                |> currPositions

        w =
            model.options.numberGridWidth

        digitList =
            "...." ++ Values.last500digits |> Utils.toTupledList |> toGrid w

        lineDiv l p =
            div [] (nbrLine l p w)

        gnDiv p =
            div [ class "gn" ]
                (digitList
                    |> List.map
                        (\l -> lineDiv l p)
                )
    in
        { title = model.title
        , body =
            [ div [ id "clock" ]
                [ gnDiv timePos.hh
                , gnDiv timePos.mm
                , gnDiv timePos.ss
                ]
            ]
        }


nbrLine : List ( Int, String ) -> List Int -> Int -> List (Html msg)
nbrLine nbrs match w =
    let
        nbrText =
            Tuple.second >> Html.text

        nbrId =
            Tuple.first >> String.fromInt >> id

        found n l =
            fst n l || snd n l

        fst n l =
            List.member n l && (modBy w (n + 1) /= 0)

        snd n l =
            List.member (n - 1) l && (modBy w n /= 0)

        getClass n =
            if found (Tuple.first n) match then
                class "h"
            else
                class "x"
    in
        nbrs
            |> List.map (\t -> Html.div [ getClass t, nbrId t ] [ nbrText t ])
