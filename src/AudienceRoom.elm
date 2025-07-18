module AudienceRoom exposing
    ( Model
    , hideConstraints
    , init
    , setConstraints
    , view
    )

import Color
import Constraints
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Element.Input
import Lamdera exposing (sendToBackend)
import Types exposing (..)


type alias Model =
    AudienceRoomModel


init : RoomId -> ( Model, Cmd msg )
init roomId =
    ( { roomId = roomId
      , constraintsDisplayed = False
      , constraints = Constraints.empty
      }
    , RegisterToRoom roomId
        |> sendToBackend
    )


setConstraints : RoomConstraints -> Bool -> Model -> Model
setConstraints constraints constraintsDisplayed model =
    { model
        | constraints = constraints
        , constraintsDisplayed = constraintsDisplayed
    }


hideConstraints : Model -> Model
hideConstraints model =
    { model | constraintsDisplayed = False }


view : Model -> List (Element msg)
view model =
    [ Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        ]
        [ Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            ]
            [ viewBox Blue model.constraintsDisplayed model.constraints.blue
            , viewBox Yellow model.constraintsDisplayed model.constraints.yellow
            ]
        , Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            ]
            [ viewBox Red model.constraintsDisplayed model.constraints.red
            , viewBox Green model.constraintsDisplayed model.constraints.green
            ]
        ]
    ]


viewBox : Color -> Bool -> String -> Element msg
viewBox color constraintsDisplayed text =
    box color
        { onPress = Nothing
        , label =
            if constraintsDisplayed then
                text

            else
                "\u{00A0}"
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
