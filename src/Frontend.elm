module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input
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
        [ Element.column
            [ Element.height Element.fill
            , Element.width Element.fill
            ]
            (viewBody model)
            |> Element.layout []
        ]
    }


viewBody : Model -> List (Element FrontendMsg)
viewBody model =
    case model.role of
        UndecidedUserType ->
            viewRoleSelection

        Host ->
            [ viewHostHeaderButtons
            , viewHostBoxes model
            ]

        Player color ->
            viewPlayerConstraint color model


viewHostHeaderButtons : Element FrontendMsg
viewHostHeaderButtons =
    header
        [ button { onPress = Just Edit, label = Element.text "Editer" }
        , button { onPress = Just ShowAll, label = Element.text "Tout voir" }
        , button { onPress = Just (Show Nothing), label = Element.text "Tout cacher" }
        , button { onPress = Just (ChangeRole UndecidedUserType), label = Element.text "Changer de rôle" }
        , button { onPress = Just Veil, label = Element.text "Cacher" }
        , button { onPress = Just Unveil, label = Element.text "Dévoiler" }
        ]


button : { onPress : Maybe msg, label : Element msg } -> Element msg
button =
    Element.Input.button
        [ Border.width 1
        , Border.rounded 3
        , Element.padding 5
        , Background.color (Element.rgb 0.95 0.95 0.95)
        ]


header : List (Element msg) -> Element msg
header =
    Element.wrappedRow
        [ Element.spacing 20
        , Element.padding 20
        ]


viewRoleSelection : List (Element FrontendMsg)
viewRoleSelection =
    [ header
        [ button { onPress = Just (ChangeRole Host), label = Element.text "Je suis hôte 🪄" }
        ]
    , Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        , Element.spacing 20
        ]
        [ Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            , Element.spacing 20
            ]
            [ viewPlayerSelectButton Blue
            , viewPlayerSelectButton Yellow
            ]
        , Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            , Element.spacing 20
            ]
            [ viewPlayerSelectButton Red
            , viewPlayerSelectButton Green
            ]
        ]
    ]


viewPlayerSelectButton : Color -> Element FrontendMsg
viewPlayerSelectButton color =
    box color
        { onPress = Just (ChangeRole (Player color))
        , label = "Joueur"
        }


viewPlayerConstraint : Color -> Model -> List (Element FrontendMsg)
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
        [ button
            { onPress = Just (ChangeRole UndecidedUserType)
            , label = Element.text "Changer de rôle"
            }
        ]
    , box color
        { onPress = Just (ChangeRole (Player color))
        , label =
            if text == "" then
                "En attente"

            else
                text
        }
    ]


viewHostBoxes : Model -> Element FrontendMsg
viewHostBoxes model =
    Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        , Element.spacing 20
        ]
        [ Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            , Element.spacing 20
            ]
            [ viewBox Blue model
            , viewBox Yellow model
            ]
        , Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            , Element.spacing 20
            ]
            [ viewBox Red model
            , viewBox Green model
            ]
        ]


viewBox : Color -> { a | blue : String, yellow : String, red : String, green : String, mode : Mode } -> Element FrontendMsg
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
            Element.el
                [ Element.centerX
                , Element.centerY
                , Element.height Element.fill
                , Element.width Element.fill
                , Background.color (backgroundColor color)
                ]
                (Element.Input.text []
                    { onChange = ChangedInput color
                    , text = text
                    , placeholder = Nothing
                    , label = Element.Input.labelHidden "Constraint"
                    }
                )

        ShowingAll ->
            box color
                { onPress = Nothing
                , label = text
                }

        Showing Nothing ->
            box color
                { onPress = Just (Show (Just color))
                , label = "Révéler"
                }

        Showing (Just showingColor) ->
            if color == showingColor then
                box color
                    { onPress = Just (Show Nothing)
                    , label = text
                    }

            else
                box color
                    { onPress = Nothing
                    , label = "\u{00A0}"
                    }


box : Color -> { onPress : Maybe msg, label : String } -> Element msg
box color { onPress, label } =
    Element.Input.button
        [ Element.centerX
        , Element.centerY
        , Element.height Element.fill
        , Element.width Element.fill
        , Background.color (backgroundColor color)
        ]
        { onPress = onPress
        , label = viewBoxContent label
        }


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


backgroundColor : Color -> Element.Color
backgroundColor color =
    case color of
        Blue ->
            Element.rgb 0 0 1

        Yellow ->
            Element.rgb255 255 165 0

        Red ->
            Element.rgb 1 0 0

        Green ->
            Element.rgb 0 0.5 0
