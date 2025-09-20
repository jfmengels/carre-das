module Route exposing
    ( Route(..)
    , parseUrl
    , toUrl
    )

import AppUrl exposing (AppUrl)
import Url exposing (Url)


type Route
    = Route_RoomSelect
    | Route_Room String
    | Route_RoomAsHost String
    | Route_AudienceRoom String
    | Route_Share Url String
    | Route_Random
    | Route_Admin


parseUrl : Url -> Maybe ( Route, Bool )
parseUrl url =
    let
        appUrl : AppUrl
        appUrl =
            AppUrl.fromUrl url
    in
    case appUrl.path of
        [] ->
            Just ( Route_RoomSelect, False )

        [ "admin" ] ->
            Just ( Route_Admin, False )

        [ "random" ] ->
            Just ( Route_Random, False )

        [ "room", roomId ] ->
            lowerCaseRoomId Route_Room roomId

        [ "room", roomId, "host" ] ->
            lowerCaseRoomId Route_RoomAsHost roomId

        [ "room", roomId, "share" ] ->
            lowerCaseRoomId (Route_Share url) roomId

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

        Route_Share _ roomId ->
            "/room/" ++ roomId ++ "/share"

        Route_Random ->
            "/random"

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
