module RandomPage exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input
import Random
import Task
import Time
import Types exposing (..)


type alias Model =
    RandomPageModel


type alias Msg =
    RandomPageMsg


init : ( Model, Cmd Msg )
init =
    ( { input = ""
      , drawn = []
      , seed = Random.initialSeed 0
      , nothingLeftToDraw = False
      }
    , Task.perform GotTime Time.now
    )


update : Msg -> Model -> Model
update msg model =
    case msg of
        GotTime time ->
            { model | seed = Random.initialSeed (Time.posixToMillis time) }

        UserChangedInput input ->
            { model | input = input, nothingLeftToDraw = False }

        UserClickedDraw ->
            case String.trim model.input |> String.lines |> List.filter (\x -> not (String.isEmpty x || List.member x model.drawn)) of
                "" :: [] ->
                    { model | nothingLeftToDraw = True }

                [] ->
                    { model | nothingLeftToDraw = True }

                x :: xs ->
                    let
                        ( newDraw, seed ) =
                            Random.step (Random.uniform x xs) model.seed
                    in
                    { model | seed = seed, drawn = newDraw :: model.drawn }

        UserClickedReset ->
            { model | drawn = [], nothingLeftToDraw = False }


view : Model -> List (Element Msg)
view model =
    [ Element.row
        [ Element.centerX
        , Element.centerY
        , Element.spacing 5
        ]
        [ viewRandomPasswordForm model.nothingLeftToDraw model.input
        , viewDrawn model.drawn
        ]
    ]


viewRandomPasswordForm : Bool -> String -> Element Msg
viewRandomPasswordForm nothingLeftToDraw input =
    Element.column
        [ Element.centerX
        , Element.centerY
        , Element.spacing 5
        ]
        [ Element.Input.multiline
            [ Element.height Element.fill
            , Element.width Element.fill
            , Element.Input.focusedOnLoad
            ]
            { onChange = UserChangedInput
            , text = input
            , placeholder = Nothing
            , label =
                Element.Input.labelAbove
                    [ Element.centerX
                    , Element.centerY
                    ]
                    (Element.text "À tirer")
            , spellcheck = False
            }
        , Element.row
            [ Element.centerX
            , Element.centerY
            , Element.spacing 5
            ]
            [ button
                { onPress = Just UserClickedDraw
                , label = Element.text "Tirer"
                }
            , button
                { onPress = Just UserClickedReset
                , label = Element.text "Ré-initialiser"
                }
            ]
        , if nothingLeftToDraw then
            Element.el
                [ Font.color (Element.rgb 1 0 0)
                , Element.centerX
                , Element.centerY
                ]
                (Element.text "Il n'y a plus rien à tirer")

          else
            Element.none
        ]


viewDrawn : List String -> Element Msg
viewDrawn drawn =
    drawn
        |> List.reverse
        |> List.map (\x -> Element.paragraph [] [ Element.text x ])
        |> Element.textColumn []


button : { onPress : Maybe msg, label : Element msg } -> Element msg
button =
    Element.Input.button
        [ Border.width 1
        , Border.rounded 3
        , Element.padding 5
        , Background.color (Element.rgb 0.95 0.95 0.95)
        ]
