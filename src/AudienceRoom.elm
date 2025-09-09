module AudienceRoom exposing
    ( Model
    , hideConstraints
    , init
    , onReconnect
    , setConstraints
    , view
    )

import Box
import Constraints
import Element exposing (Element)
import Lamdera exposing (sendToBackend)
import Types exposing (..)


type alias Model =
    AudienceRoomModel


init : RoomId -> ( Model, Cmd msg )
init roomId =
    ( { roomId = roomId
      , constraintsDisplayed = False
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
    Box.box color
        { onPress = Nothing
        , label =
            if constraintsDisplayed then
                text

            else
                "\u{00A0}"
        }
