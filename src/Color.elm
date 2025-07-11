module Color exposing (..)

import Element
import Types exposing (Color(..))


backgroundColor : Color -> Element.Color
backgroundColor color =
    case color of
        Blue ->
            Element.rgb 0 0 1

        Yellow ->
            Element.rgb 1 0.64 0

        Red ->
            Element.rgb 1 0 0

        Green ->
            Element.rgb 0 0.5 0
