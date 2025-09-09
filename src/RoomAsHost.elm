module RoomAsHost exposing
    ( Model
    , Msg
    , init
    , setConstraints
    , update
    , view
    )

import Box
import Color
import Constraints
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input
import Lamdera exposing (sendToBackend)
import Route
import Types exposing (..)


type alias Model =
    RoomAsHostModel


type alias Msg =
    RoomAsHostMsg


init : RoomId -> ( Model, Cmd FrontendMsg )
init roomId =
    ( { roomId = roomId
      , mode = Showing Nothing
      , constraintsDisplayed = False
      , constraints = Constraints.empty
      }
    , RegisterToRoom roomId
        |> sendToBackend
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowAll ->
            ( { model | mode = ShowingAll }, Cmd.none )

        Unveil ->
            ( { model | mode = ShowingAll }
            , UnveilConstraints model.roomId model.constraints
                |> sendToBackend
            )

        Veil ->
            ( { model | mode = Editing }
            , HideConstraints model.roomId
                |> sendToBackend
            )

        Reset ->
            ( { model | constraints = Constraints.empty }, Cmd.none )

        Edit ->
            ( { model | mode = Editing }, Cmd.none )

        ChangedInput color text ->
            let
                constraints : RoomConstraints
                constraints =
                    model.constraints

                newConstraints : RoomConstraints
                newConstraints =
                    case color of
                        Blue ->
                            { constraints | blue = text }

                        Yellow ->
                            { constraints | yellow = text }

                        Red ->
                            { constraints | red = text }

                        Green ->
                            { constraints | green = text }
            in
            ( { model | constraints = newConstraints }
            , Cmd.none
            )

        Show maybeColor ->
            ( { model | mode = Showing maybeColor }, Cmd.none )


setConstraints : RoomConstraints -> Bool -> Model -> Model
setConstraints constraints constraintsDisplayed model =
    { model
        | constraints = constraints
        , constraintsDisplayed = constraintsDisplayed
    }


view : Model -> List (Element Msg)
view model =
    [ viewHostHeaderButtons model.roomId
    , viewHostBoxes model
    ]


viewHostHeaderButtons : RoomId -> Element Msg
viewHostHeaderButtons (RoomId roomId) =
    header
        [ Element.link [] { url = Route.toUrl (Route.Route_Room roomId), label = button { onPress = Nothing, label = Element.text "Changer de rôle" } }
        , button { onPress = Nothing, label = Element.el [ Element.alignRight ] (Element.link [] { url = Route.toUrl Route.Route_RoomSelect, label = Element.text "Sortir" }) }
        , button { onPress = Just Edit, label = Element.text "Editer" }
        , button { onPress = Just Reset, label = Element.text "Vider" }
        , button { onPress = Just ShowAll, label = Element.text "Tout voir" }
        , button { onPress = Just (Show Nothing), label = Element.text "Tout cacher" }
        , button { onPress = Just Veil, label = Element.text "Cacher" }
        , button { onPress = Just Unveil, label = Element.text "Dévoiler" }
        , Element.link [] { url = Route.toUrl (Route.Route_AudienceRoom roomId), label = button { onPress = Nothing, label = Element.text "Vers public" } }
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


viewHostBoxes : Model -> Element Msg
viewHostBoxes model =
    Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        ]
        [ Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            ]
            [ viewBox Blue model.mode model.constraints
            , viewBox Yellow model.mode model.constraints
            ]
        , Element.wrappedRow
            [ Element.height Element.fill
            , Element.width Element.fill
            ]
            [ viewBox Red model.mode model.constraints
            , viewBox Green model.mode model.constraints
            ]
        ]


viewBox : Color -> Mode -> RoomConstraints -> Element Msg
viewBox color mode constraints =
    let
        text : String
        text =
            case color of
                Blue ->
                    constraints.blue

                Yellow ->
                    constraints.yellow

                Red ->
                    constraints.red

                Green ->
                    constraints.green
    in
    case mode of
        Editing ->
            Element.el
                [ Element.height Element.fill
                , Element.width Element.fill
                , Element.padding 40
                , Background.color (Color.backgroundColor color)
                ]
                (Element.Input.text
                    [ Element.height Element.fill
                    , Element.width Element.fill
                    , Element.centerX
                    , Element.centerY
                    , Background.color (Color.backgroundColor color)
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
            Box.box color
                { onPress = Nothing
                , label = text
                }

        Showing Nothing ->
            Box.box color
                { onPress = Just (Show (Just color))
                , label = "Révéler"
                }

        Showing (Just showingColor) ->
            if color == showingColor then
                Box.box color
                    { onPress = Just (Show Nothing)
                    , label = text
                    }

            else
                Box.box color
                    { onPress = Nothing
                    , label = "\u{00A0}"
                    }


white : Element.Color
white =
    Element.rgb 1 1 1
