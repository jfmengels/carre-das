module RoomSelect exposing (..)

import Browser.Navigation
import Color
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input
import Html.Events
import Json.Decode as Decode
import Types exposing (..)


type alias Model =
    RoomSelectModel


type alias Msg =
    RoomSelectMsg


init : Model
init =
    { input = ""
    , inputSubmitted = False
    }


update : Browser.Navigation.Key -> Msg -> Model -> ( Model, Cmd msg )
update navKey msg model =
    case msg of
        ChangedRoomSelectInput input ->
            ( { input = input
              , inputSubmitted = False
              }
            , Cmd.none
            )

        Submit ->
            if String.isEmpty model.input then
                ( { input = model.input
                  , inputSubmitted = True
                  }
                , Cmd.none
                )

            else
                ( model, Browser.Navigation.pushUrl navKey ("/room/" ++ String.toLower model.input) )


view : Model -> List (Element Msg)
view { input, inputSubmitted } =
    [ Element.column
        [ Element.centerX
        , Element.centerY
        , Element.spacing 5
        ]
        [ icon
        , if inputSubmitted && String.isEmpty input then
            Element.el
                [ Font.color (Element.rgb 1 0 0)
                , Element.centerX
                , Element.centerY
                ]
                (Element.text "ne doit pas être vide")

          else
            Element.none
        , Element.Input.text
            [ Element.height Element.fill
            , Element.width Element.fill
            , onEnter Submit
            , Element.Input.focusedOnLoad
            ]
            { onChange = ChangedRoomSelectInput
            , text = input
            , placeholder = Just (Element.Input.placeholder [] (Element.text "ex: 1234, groupe de potes, ..."))
            , label =
                Element.Input.labelAbove
                    [ Element.centerX
                    , Element.centerY
                    ]
                    (Element.text "Nom de chambre")
            }
        , Element.el
            [ Element.centerX
            , Element.centerY
            ]
            (button
                { onPress = Just Submit
                , label = Element.text "Valider"
                }
            )
        ]
    ]


icon : Element msg
icon =
    Element.column [ Element.centerX, Element.centerY ]
        [ Element.wrappedRow []
            [ viewBox Blue
            , viewBox Yellow
            ]
        , Element.wrappedRow []
            [ viewBox Red
            , viewBox Green
            ]
        ]


viewBox : Color -> Element msg
viewBox color =
    Element.el
        [ Element.height (Element.px 40)
        , Element.width (Element.px 40)
        , Background.color (Color.backgroundColor color)
        ]
        Element.none


onEnter : msg -> Element.Attribute msg
onEnter msg =
    Element.htmlAttribute
        (Html.Events.on "keyup"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the enter key"
                    )
            )
        )


button : { onPress : Maybe msg, label : Element msg } -> Element msg
button =
    Element.Input.button
        [ Border.width 1
        , Border.rounded 3
        , Element.padding 5
        , Background.color (Element.rgb 0.95 0.95 0.95)
        ]
