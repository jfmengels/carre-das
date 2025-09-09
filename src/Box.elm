module Box exposing (box)

import Color
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Element.Input
import Regex exposing (Regex)
import Types exposing (Color(..))


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
        , label = viewBoxContent (String.trim label)
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
                wordToElement text
            )
        ]


wordToElement : String -> List (Element msg)
wordToElement inputStr =
    case Regex.find colorWordsRegex inputStr of
        [] ->
            [ Element.text inputStr ]

        matches ->
            List.foldl
                (\match ( lastIndex, res ) ->
                    ( match.index + String.length match.match
                    , highlight match.match :: Element.text (String.slice lastIndex match.index inputStr) :: res
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


highlight : String -> Element msg
highlight color =
    Element.el [ Font.color (Color.backgroundColor (Color.fromString color |> Maybe.withDefault Blue)) ] (Element.text color)


colors : List String
colors =
    [ "bleu", "vert", "rouge", "jaune" ]


white : Element.Color
white =
    Element.rgb 1 1 1
