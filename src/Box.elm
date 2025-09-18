module Box exposing (box)

import Color
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Element.Input
import Regex exposing (Regex)
import Types exposing (Color(..))


box : Color -> { onPress : Maybe msg, label : String } -> Element msg
box backgroundColor { onPress, label } =
    Element.Input.button
        [ Element.centerX
        , Element.centerY
        , Element.height Element.fill
        , Element.width Element.fill
        , Background.color (Color.backgroundColor backgroundColor)
        ]
        { onPress = onPress
        , label = viewBoxContent backgroundColor (String.trim label)
        }


viewBoxContent : Color -> String -> Element msg
viewBoxContent backgroundColor text =
    Element.column
        [ Element.centerX
        , Element.centerY
        , Element.padding 30
        ]
        (if String.isEmpty text then
            [ paragraph [ Element.text "En réserve" ] ]

         else
            text
                |> String.lines
                |> List.map (wordToElement backgroundColor >> paragraph)
        )


paragraph : List (Element msg) -> Element msg
paragraph =
    Element.paragraph
        [ Font.color white
        , Font.size 50
        , Font.bold
        , Font.center
        ]


wordToElement : Color -> String -> List (Element msg)
wordToElement backgroundColor inputStr =
    case Regex.find colorWordsRegex inputStr of
        [] ->
            [ Element.text inputStr ]

        matches ->
            List.foldl
                (\match ( lastIndex, res ) ->
                    ( match.index + String.length match.match
                    , highlight backgroundColor match.match :: Element.text (String.slice lastIndex match.index inputStr) :: res
                    )
                )
                ( 0, [] )
                matches
                |> (\( lastIndex, res ) -> Element.text (String.slice lastIndex (String.length inputStr) inputStr) :: res)
                |> List.reverse


colorWordsRegex : Regex
colorWordsRegex =
    Regex.fromStringWith { caseInsensitive = True, multiline = False } ("\\b(" ++ String.join "|" colors ++ ")\\b")
        |> Maybe.withDefault Regex.never


highlight : Color -> String -> Element msg
highlight backgroundColor colorStr =
    case Color.fromString colorStr of
        Nothing ->
            Element.text colorStr

        Just color ->
            if color == backgroundColor then
                Element.text colorStr

            else
                Element.el [ Font.color (Color.backgroundColor color) ] (Element.text (String.toUpper colorStr))


colors : List String
colors =
    [ "bleu", "vert", "rouge", "jaune" ]


white : Element.Color
white =
    Element.rgb 1 1 1
