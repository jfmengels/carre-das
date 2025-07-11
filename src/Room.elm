module Room exposing (..)

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input
import Lamdera exposing (sendToBackend)
import Types exposing (..)


init : RoomId -> ( RoomModel, Cmd FrontendMsg )
init roomId =
    ( { roomId = roomId
      , mode = Showing Nothing
      , role = UndecidedUserType
      , blue = ""
      , yellow = ""
      , red = ""
      , green = ""
      }
    , RegisterToRoom roomId
        |> sendToBackend
    )


update : RoomMsg -> RoomModel -> ( RoomModel, Cmd RoomMsg )
update msg model =
    case msg of
        ShowAll ->
            ( { model | mode = ShowingAll }, Cmd.none )

        Unveil ->
            ( { model | mode = ShowingAll }
            , SetConstraints model.roomId { blue = model.blue, yellow = model.yellow, red = model.red, green = model.green }
                |> sendToBackend
            )

        Veil ->
            ( { model | mode = Editing }
            , SetConstraints model.roomId { blue = "", yellow = "", red = "", green = "" }
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


setConstraints : { blue : String, yellow : String, red : String, green : String } -> RoomModel -> RoomModel
setConstraints constraints model =
    case model.role of
        Host ->
            model

        _ ->
            { model
                | blue = constraints.blue
                , yellow = constraints.yellow
                , red = constraints.red
                , green = constraints.green
            }


view : RoomModel -> List (Element RoomMsg)
view model =
    case model.role of
        UndecidedUserType ->
            viewRoleSelection

        Host ->
            viewHost model

        Player color ->
            viewPlayerConstraint color model


viewHost : RoomModel -> List (Element RoomMsg)
viewHost model =
    [ viewHostHeaderButtons
    , viewHostBoxes model
    ]


viewHostHeaderButtons : Element RoomMsg
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


viewRoleSelection : List (Element RoomMsg)
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


viewPlayerSelectButton : Color -> Element RoomMsg
viewPlayerSelectButton color =
    box color
        { onPress = Just (ChangeRole (Player color))
        , label = "Joueur"
        }


viewPlayerConstraint : Color -> RoomModel -> List (Element RoomMsg)
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


viewHostBoxes : RoomModel -> Element RoomMsg
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


viewBox : Color -> { a | blue : String, yellow : String, red : String, green : String, mode : Mode } -> Element RoomMsg
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
                , Background.color (backgroundColor color)
                ]
                (Element.Input.text
                    [ Element.height Element.fill
                    , Element.width Element.fill
                    , Element.centerX
                    , Element.centerY
                    , Background.color (backgroundColor color)
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


backgroundColor : Color -> Element.Color
backgroundColor color =
    let
        ( r, g, b ) =
            rgb color
    in
    Element.rgb r g b


rgb : Color -> ( number, Float, number )
rgb color =
    case color of
        Blue ->
            ( 0, 0, 1 )

        Yellow ->
            ( 1, 0.64, 0 )

        Red ->
            ( 1, 0, 0 )

        Green ->
            ( 0, 0.5, 0 )
