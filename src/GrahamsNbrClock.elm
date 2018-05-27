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


-- programWithFlags ?


main : Program Never Model Msg
main =
    Html.program
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


init : ( Model, Cmd Msg )
init =
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
            { time = Just 0
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


view : Model -> Html Msg
view model =
    let
        get x dict =
            Dict.get (toString x |> pad2) dict |> Maybe.withDefault [ 0 ]

        currPositions tp =
            { hhCurr = get tp.hh model.hhPositions
            , mmCurr = get tp.mm model.mmPositions
            , ssCurr = get tp.ss model.ssPositions
            }

        time =
            (Maybe.withDefault 0 model.time)
                |> toTimeParts model.options.hourMode
                |> currPositions

        ellipses =
            div [ class "e" ] [ text "...." ]
    in
        div []
            [ div []
                (time
                    |> (\c -> nbrLine Values.last500digits c.hhCurr 499)
                )
            , div []
                (time
                    |> (\c -> nbrLine Values.last500digits c.mmCurr 499)
                )
            , div []
                (time
                    |> (\c -> nbrLine Values.last500digits c.ssCurr 499)
                )
            ]


nbrLine : String -> List Int -> number -> List (Html msg)
nbrLine nbr match w =
    let
        nbrText =
            Tuple.second >> Html.text

        nbrId =
            Tuple.first >> toString >> id

        found m l =
            (List.member m l || List.member (m - 1) l) && m /= w

        getClass n match =
            if found (Tuple.first n) match then
                class "h"
            else
                class "x"
    in
        nbr
            |> Utils.toStringList
            |> List.indexedMap (,)
            |> List.map (\t -> Html.div [ (getClass t match), nbrId t ] [ nbrText t ])
