module Room exposing (..)

import Color
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input
import Lamdera exposing (sendToBackend)
import Types exposing (..)


type alias Model =
    RoomModel


type alias Msg =
    RoomMsg


init : RoomId -> Role -> ( RoomModel, Cmd msg )
init roomId role =
    ( { roomId = roomId
      , mode = Showing Nothing
      , constraintsDisplayed = False
      , role = role
      , blue = ""
      , yellow = ""
      , red = ""
      , green = ""
      }
    , RegisterToRoom roomId
        |> sendToBackend
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowAll ->
            ( { model | mode = ShowingAll }, Cmd.none )

        Unveil ->
            ( { model | mode = ShowingAll }
            , UnveilConstraints model.roomId { blue = model.blue, yellow = model.yellow, red = model.red, green = model.green }
                |> sendToBackend
            )

        Veil ->
            ( { model | mode = Editing }
            , HideConstraints model.roomId
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


setConstraints : { blue : String, yellow : String, red : String, green : String } -> Bool -> Model -> Model
setConstraints constraints constraintsDisplayed model =
    { model
        | blue = constraints.blue
        , yellow = constraints.yellow
        , red = constraints.red
        , green = constraints.green
        , constraintsDisplayed = constraintsDisplayed
    }


hideConstraints : Model -> Model
hideConstraints model =
    { model | constraintsDisplayed = False }


view : Model -> List (Element Msg)
view model =
    case model.role of
        UndecidedUserType ->
            viewRoleSelection

        Host ->
            viewHost model

        Player color ->
            viewPlayerConstraint color model


viewHost : Model -> List (Element Msg)
viewHost model =
    [ viewHostHeaderButtons
    , viewHostBoxes model
    ]


viewHostHeaderButtons : Element Msg
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


viewRoleSelection : List (Element Msg)
viewRoleSelection =
    [ header
        [ button { onPress = Just (ChangeRole Host), label = Element.text "Je suis hôte 🪄" }
        , Element.el [ Element.alignRight ] (Element.link [] { url = "/", label = Element.text "Sortir" })
        ]
    , Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        ]
        [ Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            ]
            [ viewPlayerSelectButton Blue
            , viewPlayerSelectButton Yellow
            ]
        , Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            ]
            [ viewPlayerSelectButton Red
            , viewPlayerSelectButton Green
            ]
        ]
    ]


viewPlayerSelectButton : Color -> Element Msg
viewPlayerSelectButton color =
    box color
        { onPress = Just (ChangeRole (Player color))
        , label = "Joueur"
        }


viewPlayerConstraint : Color -> Model -> List (Element Msg)
viewPlayerConstraint color model =
    [ box color
        { onPress = Just (ChangeRole UndecidedUserType)
        , label =
            if model.constraintsDisplayed then
                case color of
                    Blue ->
                        model.blue

                    Yellow ->
                        model.yellow

                    Red ->
                        model.red

                    Green ->
                        model.green

            else
                "En attente"
        }
    ]


viewHostBoxes : Model -> Element Msg
viewHostBoxes model =
    Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        ]
        [ Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            ]
            [ viewBox Blue model
            , viewBox Yellow model
            ]
        , Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            ]
            [ viewBox Red model
            , viewBox Green model
            ]
        ]


viewBox : Color -> { a | blue : String, yellow : String, red : String, green : String, mode : Mode } -> Element Msg
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
                [ Element.height Element.fill
                , Element.width Element.fill
                , Element.padding 40
                , Background.color (Color.backgroundColor color)
                ]
                (Element.Input.text
                    [ Element.height Element.fill
                    , Element.width Element.fill
                    , Element.centerX
                    , Element.centerY
                    , Background.color (Color.backgroundColor color)
                    , Font.color white
                    , Font.bold
                    , Font.center
                    ]
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
        , Background.color (Color.backgroundColor color)
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
            [ Font.color white
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


white : Element.Color
white =
    Element.rgb 1 1 1
