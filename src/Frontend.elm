module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Lamdera exposing (sendToBackend)
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
      , mode = Showing Nothing
      , role = UndecidedUserType
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

        ShowAll ->
            ( { model | mode = ShowingAll }, Cmd.none )

        Unveil ->
            ( { model | mode = ShowingAll }
            , SetConstraints { blue = model.blue, yellow = model.yellow, red = model.red, green = model.green }
                |> sendToBackend
            )

        Veil ->
            ( { model | mode = Editing }
            , SetConstraints { blue = "", yellow = "", red = "", green = "" }
                |> sendToBackend
            )

        Edit ->
            ( { model | mode = Editing }, Cmd.none )

        ChangedInput color text ->
            ( case color of
                Blue ->
                    { model | blue = text }

                Yellow ->
                    { model | yellow = text }

                Red ->
                    { model | red = text }

                Green ->
                    { model | green = text }
            , Cmd.none
            )

        Show maybeColor ->
            ( { model | mode = Showing maybeColor }, Cmd.none )

        ChangeRole role ->
            ( { model | role = role }, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        SendConstraintsToFrontend constraints ->
            case model.role of
                Host ->
                    ( model, Cmd.none )

                _ ->
                    ( { model
                        | blue = constraints.blue
                        , yellow = constraints.yellow
                        , red = constraints.red
                        , green = constraints.green
                      }
                    , Cmd.none
                    )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ Html.div [ Attr.style "height" "100%" ]
            (case model.role of
                UndecidedUserType ->
                    viewRoleSelection

                Host ->
                    [ header
                        [ button { onPress = Just Edit, label = Element.text "Editer" }
                            |> Element.layout []
                        , button { onPress = Just ShowAll, label = Element.text "Tout voir" }
                            |> Element.layout []
                        , button { onPress = Just (Show Nothing), label = Element.text "Tout cacher" }
                            |> Element.layout []
                        , button { onPress = Just (ChangeRole UndecidedUserType), label = Element.text "Changer de rôle" }
                            |> Element.layout []
                        , button { onPress = Just Veil, label = Element.text "Cacher" }
                            |> Element.layout []
                        , button { onPress = Just Unveil, label = Element.text "Dévoiler" }
                            |> Element.layout []
                        ]
                    , viewBody model
                    ]

                Player color ->
                    viewPlayerConstraint color model
            )
        ]
    }


button : { onPress : Maybe msg, label : Element msg } -> Element msg
button =
    Element.Input.button
        [ Border.width 1
        , Border.rounded 3
        , Element.padding 5
        , Background.color (Element.rgb 0.95 0.95 0.95)
        ]


header : List (Html msg) -> Html msg
header children =
    Html.div
        [ Attr.style "height" "100%"
        , Attr.style "padding" "20px 0 0 20px"
        , Attr.style "display" "flex"
        , Attr.style "gap" "20px"
        , Attr.style "height" "40px"
        , Attr.style "flex-wrap" "wrap"
        ]
        children


viewRoleSelection : List (Html FrontendMsg)
viewRoleSelection =
    [ header
        [ Html.button [ Events.onClick (ChangeRole Host), Attr.style "font-size" "20px" ] [ Html.text "Je suis hôte 🪄" ]
        ]
    , bodyWrapper
        [ viewPlayerSelectButton Blue
        , viewPlayerSelectButton Yellow
        , viewPlayerSelectButton Red
        , viewPlayerSelectButton Green
        ]
    ]


viewPlayerSelectButton : Color -> Html FrontendMsg
viewPlayerSelectButton color =
    Html.div
        (boxAttributes color (Events.onClick (ChangeRole (Player color))))
        [ viewBoxContent "Joueur" |> Element.layout []
        ]


viewPlayerConstraint : Color -> Model -> List (Html FrontendMsg)
viewPlayerConstraint color model =
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
    [ header
        [ Html.button [ Events.onClick (ChangeRole UndecidedUserType), Attr.style "font-size" "20px" ] [ Html.text "Changer de rôle" ]
        ]
    , bodyWrapper
        [ Html.div
            (fullPageBoxAttributes color (Events.onClick (ChangeRole (Player color))))
            [ viewBoxContent
                (if text == "" then
                    "En attente"

                 else
                    text
                )
                |> Element.layout []
            ]
        ]
    ]


viewBody : Model -> Html FrontendMsg
viewBody model =
    bodyWrapper
        [ viewBox Blue model
        , viewBox Yellow model
        , viewBox Red model
        , viewBox Green model
        ]


bodyWrapper : List (Html msg) -> Html msg
bodyWrapper children =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "flex-wrap" "wrap"
        , Attr.style "flex-direction" "row"
        , Attr.style "min-height" "1000px"
        ]
        children


viewBox : Color -> { a | blue : String, yellow : String, red : String, green : String, mode : Mode } -> Html FrontendMsg
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
    case model.mode of
        Editing ->
            Html.div
                (boxAttributes color (Attr.class ""))
                [ Html.textarea [ Events.onInput (ChangedInput color), Attr.value text ] [] ]

        ShowingAll ->
            Html.div
                (boxAttributes color (Attr.class ""))
                [ viewBoxContent text |> Element.layout []
                ]

        Showing Nothing ->
            Html.div
                (boxAttributes color (Events.onClick (Show (Just color))))
                [ viewBoxContent "Révéler" |> Element.layout [] ]

        Showing (Just showingColor) ->
            if color == showingColor then
                Html.div
                    (boxAttributes color (Events.onClick (Show Nothing)))
                    [ viewBoxContent text |> Element.layout [] ]

            else
                Html.div
                    (boxAttributes color (Attr.class ""))
                    [ Html.text "\u{00A0}" ]


fullPageBoxAttributes : Color -> Html.Attribute msg -> List (Html.Attribute msg)
fullPageBoxAttributes color eventHandler =
    Attr.style "width" "100%"
        :: Attr.style "flex" "1"
        :: sharedBoxAttributes color eventHandler


boxAttributes : Color -> Html.Attribute msg -> List (Html.Attribute msg)
boxAttributes color eventHandler =
    Attr.style "flex-basis" "calc(50% - 40px)"
        :: sharedBoxAttributes color eventHandler


sharedBoxAttributes : Color -> Html.Attribute msg -> List (Html.Attribute msg)
sharedBoxAttributes color eventHandler =
    [ backgroundColor color
    , Attr.style "color" "white"
    , Attr.style "font-size" "50px"
    , Attr.style "font-weight" "bold"
    , Attr.style "display" "flex"
    , Attr.style "justify-content" "center"
    , Attr.style "flex-direction" "column"
    , Attr.style "margin" "20px"
    , eventHandler
    ]


viewBoxContent : String -> Element msg
viewBoxContent text =
    Element.column
        [ Element.centerX
        , Element.centerY
        ]
        [ Element.paragraph
            [ Font.color (Element.rgb 1 1 1)
            , Font.size 50
            , Font.bold
            , Font.center
            ]
            [ Element.text
                (if String.isEmpty text then
                    "En réserve"

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
                "orange"

            Red ->
                "red"

            Green ->
                "green"
        )
