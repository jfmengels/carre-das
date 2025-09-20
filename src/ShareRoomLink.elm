module ShareRoomLink exposing (init, view)

import Element exposing (Element)
import Route exposing (Route(..))
import Types exposing (..)
import Url exposing (Url)


type alias Model =
    ShareRoomLinkModel


init : Url -> String -> Model
init url roomId =
    { roomId = RoomId roomId
    , baseUrl = Url.toString { url | path = Route.toUrl (Route_Room roomId), query = Nothing }
    }


view : Model -> List (Element msg)
view { roomId, baseUrl } =
    [ Element.text baseUrl
    ]
