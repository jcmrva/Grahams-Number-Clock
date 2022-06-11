module GrahamsNbrClock exposing (main)

import Browser
import Clock
import Dict exposing (Dict)
import Html exposing (Html, div, span, label, input, text)
import Html.Attributes exposing (class, id, type_, checked)
import Html.Events exposing (onClick)
import Options exposing (..)
import Task
import Time exposing (..)
import Utils
import Values exposing (..)


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
    { time : Time.Posix
    , zone : Time.Zone
    , options : SiteOptions
    , hhPositions : Dict String (List Int)
    , mmPositions : Dict String (List Int)
    , ssPositions : Dict String (List Int)
    }


type alias Flags =
    Float


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
            { time = flags |> floor |> millisToPosix
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
    | Set12Hour
    | Set24Hour


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveTime time ->
            ( { model | time = time }, Cmd.none )

        AdjustTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        Set12Hour ->
            let
                options = model.options |> set12hour
            in
            ( { model | options = options, hhPositions = hour12 |> toNbrPositions }
            , Cmd.none )

        Set24Hour ->
            let
                options = model.options |> set24hour
            in
            ( { model | options = options, hhPositions = hour24 |> toNbrPositions }
            , Cmd.none )



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
        toggleMsg =
            if model.options.hourMode == TwentyFour then
                Set12Hour
            else
                Set24Hour

        get tpart dict =
            Dict.get (String.fromInt tpart |> pad2) dict
                |> Maybe.withDefault [ 0 ]

        currPositions tp =
            { hh = get tp.hh model.hhPositions
            , mm = get tp.mm model.mmPositions
            , ss = get tp.ss model.ssPositions
            }

        timePosn =
            model.time
                |> Clock.toTimeParts model.zone model.options.hourMode
                |> currPositions

        width =
            model.options.numberGridWidth

        digitList =
            "...." ++ Values.last500digits |> Utils.toTupledList |> toGrid width

        lineDiv line positions =
            div [] (nbrLine line positions width)

        gnDiv positions =
            div [ class "gn" ]
                (digitList
                    |> List.map
                        (\line -> lineDiv line positions)
                )
    in
    { title = "Graham's Number Clock ↑↑↑"
    , body =
        [ div [ class "hour-toggle-text"]
            [ text "HOUR: 12 / 24"]
        , div [ class "hour-toggle" ]
            [ label [ class "switch" ]
                [ input [ type_ "checkbox", checked (model.options.hourMode == TwentyFour) ]
                    []
                , span [ class "toggle" , onClick toggleMsg ]
                    []
                ]
            ]
        , div [ id "clock" ]
            [ gnDiv timePosn.hh
            , gnDiv timePosn.mm
            , gnDiv timePosn.ss
            ]
        ]
    }


nbrLine : List ( Int, String ) -> List Int -> Int -> List (Html msg)
nbrLine nbrs positions width =
    let
        nbrText =
            Tuple.second >> Html.text

        nbrId =
            Tuple.first >> String.fromInt >> id

        fst n l =
            List.member n l && (modBy width (n + 1) /= 0)

        snd n l =
            List.member (n - 1) l && (modBy width n /= 0)

        found n l =
            fst n l || snd n l

        cssClass n =
            if found (Tuple.first n) positions then
                class "h"

            else
                class "x"
    in
    nbrs
        |> List.map (\t -> Html.div [ cssClass t, nbrId t ] [ nbrText t ])
