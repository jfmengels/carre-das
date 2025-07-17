module Admin exposing (..)

import DateFormat.Relative
import Element exposing (Element)
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
    , Task.perform GotTime Time.now
    )


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        GotTime now ->
            ( { rooms = model.rooms, now = now }, Cmd.none )


view : Model -> List (Element msg)
view { rooms, now } =
    [ Element.table []
        { data = rooms
        , columns =
            [ { header = Element.text "ID"
              , width = Element.fill
              , view =
                    \room ->
                        let
                            (RoomId roomId) =
                                room.id
                        in
                        Element.text roomId
              }
            , { header = Element.text "Last activity"
              , width = Element.fill
              , view =
                    \room ->
                        DateFormat.Relative.relativeTimeWithOptions DateFormat.Relative.defaultRelativeOptions room.lastChange now
                            |> Element.text
              }
            ]
        }
    ]
