module Color exposing (backgroundColor, fromString)

import Element
import Types exposing (Color(..))


fromString : String -> Maybe Color
fromString string =
    case String.toLower string of
        "bleu" ->
            Just Blue

        "jaune" ->
            Just Yellow

        "rouge" ->
            Just Red

        "vert" ->
            Just Green

        _ ->
            Nothing


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
