module Route exposing (..)

import AppUrl exposing (AppUrl)


type Route
    = Route_RoomSelect
    | Route_Room String
    | Route_RoomAsHost String
    | Route_AudienceRoom String
    | Route_Admin


parseUrl : AppUrl -> Maybe Route
parseUrl url =
    case url.path of
        [] ->
            Just Route_RoomSelect

        [ "admin" ] ->
            Just Route_Admin

        [ "room", roomId ] ->
            Just (Route_Room roomId)

        [ "room", roomId, "host" ] ->
            Just (Route_RoomAsHost roomId)

        [ "room", roomId, "audience" ] ->
            Just (Route_AudienceRoom roomId)

        _ ->
            Nothing
