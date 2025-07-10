module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes as Attr
import Lamdera
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , blue = ""
      , yellow = ""
      , red = ""
      , green = ""
      }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ Html.div [ Attr.style "height" "100%" ] [ viewBody model ]
        ]
    }


viewBody : Model -> Html msg
viewBody model =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "flex-wrap" "wrap"
        , Attr.style "flex-direction" "row"
        , Attr.style "min-height" "400px"
        ]
        [ viewBox Blue model
        , viewBox Yellow model
        , viewBox Red model
        , viewBox Green model
        ]


type Color
    = Blue
    | Yellow
    | Red
    | Green


viewBox : Color -> Model -> Html msg
viewBox color model =
    let
        text : String
        text =
            case color of
                Blue ->
                    model.blue

                Yellow ->
                    model.yellow

                Red ->
                    model.red

                Green ->
                    model.green
    in
    Html.div
        [ backgroundColor color
        , Attr.style "color" "white"
        , Attr.style "font-weight" "bold"
        , Attr.style "display" "flex"
        , Attr.style "flex-basis" "calc(50% - 40px)"
        , Attr.style "justify-content" "center"
        , Attr.style "flex-direction" "column"
        , Attr.style "margin" "20px"
        ]
        [ Html.div
            [ Attr.style "display" "flex"
            , Attr.style "justify-content" "center"
            , Attr.style "flex-direction" "row"
            ]
            [ Html.text
                (if String.isEmpty text then
                    "Réserve"

                 else
                    text
                )
            ]
        ]


backgroundColor : Color -> Html.Attribute msg
backgroundColor color =
    Attr.style "background-color"
        (case color of
            Blue ->
                "blue"

            Yellow ->
                "yellow"

            Red ->
                "red"

            Green ->
                "green"
        )
