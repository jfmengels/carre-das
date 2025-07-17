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


init : RoomId -> ( Model, Cmd msg )
init roomId =
    ( { roomId = roomId
      , constraintsDisplayed = False
      , color = Nothing
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
        ChangeColor color ->
            ( { model | color = color }, Cmd.none )


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
    case model.color of
        Nothing ->
            viewRoleSelection model.roomId

        Just color ->
            viewPlayerConstraint color model


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


viewRoleSelection : RoomId -> List (Element Msg)
viewRoleSelection (RoomId roomId) =
    [ header
        [ Element.link [] { url = "/room/" ++ roomId ++ "/host", label = button { onPress = Nothing, label = Element.text "Je suis hôte 🪄" } }
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
        { onPress = Just (ChangeColor (Just color))
        , label = "Joueur"
        }


viewPlayerConstraint : Color -> Model -> List (Element Msg)
viewPlayerConstraint color model =
    [ box color
        { onPress = Just (ChangeColor Nothing)
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
