module GrahamsNbrClock exposing (..)

import Html exposing (Html, div, text, program)
import Html.Attributes exposing (id, class)
import Time exposing (Time, second)
import Task exposing (..)
import Date exposing (..)
import Options exposing (..)
import Values exposing (..)
import Dict exposing (Dict)
import Utils


--


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { time : Maybe Time
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


toTimeParts : HourMode -> Time -> TimeParts
toTimeParts mode time =
    let
        hour mode time =
            case mode of
                Twelve ->
                    time |> Date.hour |> to12Hour

                TwentyFour ->
                    time |> Date.hour

        toParts d =
            { hh = hour mode d, mm = Date.minute d, ss = Date.second d }
    in
        time
            |> Date.fromTime
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
            { time = Just flags.datetime
            , options = siteOptionsDefault
            , hhPositions = hhPos
            , mmPositions = mmssPos
            , ssPositions = mmssPos
            }
    in
        ( initModel, Cmd.none )



-- UPDATE


type Msg
    = RequestTime
    | ReceiveTime Time
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestTime ->
            ( model, Task.perform ReceiveTime Time.now )

        ReceiveTime time ->
            let
                nextmodel =
                    { model | time = Just time }
            in
                ( nextmodel, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every model.options.clockResolutionMillis ReceiveTime



-- VIEW


view : Model -> Html Msg
view model =
    let
        get tp dict =
            Dict.get (toString tp |> pad2) dict |> Maybe.withDefault [ 0 ]

        currPositions tp =
            { hh = get tp.hh model.hhPositions
            , mm = get tp.mm model.mmPositions
            , ss = get tp.ss model.ssPositions
            }

        timePos =
            (Maybe.withDefault 0 model.time)
                |> toTimeParts model.options.hourMode
                |> currPositions

        ellipses =
            div [ class "e" ] [ text "...." ]

        digits =
            Values.last500digits

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
        div [ id "clock" ]
            [ gnDiv timePos.hh
            , gnDiv timePos.mm
            , gnDiv timePos.ss
            ]


nbrLine : List ( Int, String ) -> List Int -> Int -> List (Html msg)
nbrLine nbrs match w =
    let
        nbrText =
            Tuple.second >> Html.text

        nbrId =
            Tuple.first >> toString >> id

        found n l =
            fst n l || snd n l

        fst n l =
            List.member n l && (n + 1) % w /= 0

        snd n l =
            List.member (n - 1) l && (n) % w /= 0

        getClass n =
            if found (Tuple.first n) match then
                class "h"
            else
                class "x"
    in
        nbrs
            |> List.map (\t -> Html.div [ getClass t, nbrId t ] [ nbrText t ])
