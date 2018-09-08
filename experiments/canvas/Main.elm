module Main exposing (main)

import Html exposing (..)


type Msg
    = NoOp


type alias Model =
    { name : String
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : ( { name : String }, Cmd msg )
init =
    ( { name = "canvas test" }, Cmd.none )


view : a -> Html msg
view model =
    div [] []


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
