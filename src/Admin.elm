module Admin exposing
    ( Model
    , Msg
    , gotRooms
    , init
    , update
    , view
    )

import DateFormat.Relative
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Input
import Lamdera exposing (sendToBackend)
import Route
import Task
import Time
import Types exposing (..)


type alias Model =
    AdminModel


type alias Msg =
    AdminMsg


init : ( Model, Cmd Msg )
init =
    ( { rooms = []
      , now = Time.millisToPosix 0
      }
    , Cmd.batch
        [ Task.perform GotTime Time.now
        , sendToBackend RequestRooms
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTime now ->
            ( { rooms = model.rooms, now = now }, Cmd.none )

        DeleteRoomClicked roomId ->
            ( { now = model.now
              , rooms = List.filter (\{ id } -> id /= roomId) model.rooms
              }
            , DeleteRoom roomId
                |> sendToBackend
            )


gotRooms : List RoomForAdmin -> Model -> Model
gotRooms rooms model =
    { rooms = rooms, now = model.now }


view : Model -> List (Element Msg)
view { rooms, now } =
    [ Element.table []
        { data = rooms
        , columns =
            [ { header = Element.text "ID"
              , width = Element.fill
              , view =
                    .id
                        >> unwrapRoomId
                        >> (\roomId ->
                                Element.link []
                                    { url = Route.toUrl (Route.Route_Room roomId)
                                    , label =
                                        Element.text roomId
                                    }
                           )
              }
            , { header = Element.text "Last activity"
              , width = Element.fill
              , view =
                    \room ->
                        DateFormat.Relative.relativeTimeWithOptions DateFormat.Relative.defaultRelativeOptions now room.lastChangeDate
                            |> Element.text
              }
            , { header = Element.text "Last activity"
              , width = Element.shrink
              , view = \room -> button { onPress = Just (DeleteRoomClicked room.id), label = Element.text "Supprimer" }
              }
            ]
        }
    ]


unwrapRoomId : RoomId -> String
unwrapRoomId (RoomId roomId) =
    roomId


button : { onPress : Maybe msg, label : Element msg } -> Element msg
button =
    Element.Input.button
        [ Border.width 1
        , Border.rounded 3
        , Element.padding 5
        , Background.color (Element.rgb 0.95 0.95 0.95)
        ]
