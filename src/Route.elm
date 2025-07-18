module Route exposing
    ( Route(..)
    , parseUrl
    , toUrl
    )

import AppUrl exposing (AppUrl)


type Route
    = Route_RoomSelect
    | Route_Room String
    | Route_RoomAsHost String
    | Route_AudienceRoom String
    | Route_Admin


parseUrl : AppUrl -> Maybe ( Route, Bool )
parseUrl url =
    case url.path of
        [] ->
            Just ( Route_RoomSelect, False )

        [ "admin" ] ->
            Just ( Route_Admin, False )

        [ "room", roomId ] ->
            lowerCaseRoomId Route_Room roomId

        [ "room", roomId, "host" ] ->
            lowerCaseRoomId Route_RoomAsHost roomId

        [ "room", roomId, "audience" ] ->
            lowerCaseRoomId Route_AudienceRoom roomId

        _ ->
            Nothing


toUrl : Route -> String
toUrl route =
    case route of
        Route_RoomSelect ->
            "/"

        Route_Room roomId ->
            "/room/" ++ roomId

        Route_RoomAsHost roomId ->
            "/room/" ++ roomId ++ "/host"

        Route_AudienceRoom roomId ->
            "/room/" ++ roomId ++ "/audience"

        Route_Admin ->
            "/admin"


lowerCaseRoomId : (String -> Route) -> String -> Maybe ( Route, Bool )
lowerCaseRoomId toRoute roomId =
    let
        lowerCased : String
        lowerCased =
            String.toLower roomId
    in
    Just ( toRoute lowerCased, roomId /= lowerCased )
