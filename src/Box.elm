module Box exposing (box)

import Color
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Element.Input
import Types exposing (Color)


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
            (if String.isEmpty text then
                [ Element.text "En réserve" ]

             else
                [ Element.text text ]
            )
        ]


white : Element.Color
white =
    Element.rgb 1 1 1
