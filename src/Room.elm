module Room exposing
    ( Model
    , Msg
    , hideConstraints
    , init
    , onReconnect
    , setConstraints
    , update
    , view
    )

import Box
import Constraints
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Input
import Lamdera exposing (sendToBackend)
import Route
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
      , constraints = Constraints.empty
      , waitingForConstraints = True
      }
    , RegisterToRoom roomId
        |> sendToBackend
    )


onReconnect : Model -> ( Model, Cmd msg )
onReconnect model =
    if model.waitingForConstraints then
        ( model, Cmd.none )

    else
        ( { model | waitingForConstraints = True }
        , RegisterToRoom model.roomId
            |> sendToBackend
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeColor color ->
            ( { model | color = color }, Cmd.none )


setConstraints : RoomConstraints -> Bool -> Model -> Model
setConstraints constraints constraintsDisplayed model =
    { model
        | constraints = constraints
        , constraintsDisplayed = constraintsDisplayed
        , waitingForConstraints = False
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
        [ Element.link [] { url = Route.toUrl (Route.Route_RoomAsHost roomId), label = button { onPress = Nothing, label = Element.text "Je suis hôte 🪄" } }
        , Element.el [ Element.alignRight ] (Element.link [] { url = Route.toUrl Route.Route_RoomSelect, label = Element.text "Sortir" })
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
    Box.box color
        { onPress = Just (ChangeColor (Just color))
        , label = "Joueur"
        }


viewPlayerConstraint : Color -> Model -> List (Element Msg)
viewPlayerConstraint color model =
    [ Box.box color
        { onPress = Just (ChangeColor Nothing)
        , label =
            if model.constraintsDisplayed then
                case color of
                    Blue ->
                        model.constraints.blue

                    Yellow ->
                        model.constraints.yellow

                    Red ->
                        model.constraints.red

                    Green ->
                        model.constraints.green

            else
                "En attente"
        }
    ]
