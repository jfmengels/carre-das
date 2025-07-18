module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (ClientId, SessionId)
import SeqDict exposing (SeqDict)
import Set exposing (Set)
import Time exposing (Posix)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , state : State
    }


type State
    = RoomSelect RoomSelectModel
    | InRoom RoomModel
    | InRoomAsHost RoomAsHostModel
    | InAudienceRoom AudienceRoomModel
    | Admin AdminModel
    | RouteError


type alias RoomSelectModel =
    { input : String
    , inputSubmitted : Bool
    }


type alias RoomModel =
    { roomId : RoomId
    , constraintsDisplayed : Bool
    , color : Maybe Color
    , constraints : RoomConstraints
    }


type alias RoomAsHostModel =
    { roomId : RoomId
    , mode : Mode
    , constraintsDisplayed : Bool
    , constraints : RoomConstraints
    }


type alias AudienceRoomModel =
    { roomId : RoomId
    , constraintsDisplayed : Bool
    , constraints : RoomConstraints
    }


type alias AdminModel =
    { rooms : List RoomForAdmin
    , now : Posix
    }


type alias RoomForAdmin =
    { id : RoomId
    , lastChangeDate : Posix
    }


type RoomId
    = RoomId String


type Color
    = Blue
    | Yellow
    | Red
    | Green


type Mode
    = Editing
    | ShowingAll
    | Showing (Maybe Color)


type alias BackendModel =
    { rooms : SeqDict RoomId Room
    , authenticatedAdmins : SeqDict SessionId Posix
    }


type alias Room =
    { constraints : RoomConstraints
    , connectedPlayers : Set ClientId
    , constraintsDisplayed : Bool
    , lastChangeDate : Posix
    }


type alias RoomConstraints =
    { blue : String
    , yellow : String
    , red : String
    , green : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | RoomSelectMsg RoomSelectMsg
    | RoomMsg RoomMsg
    | RoomAsHostMsg RoomAsHostMsg
    | AdminMsg AdminMsg
    | NoOpFrontendMsg


type RoomSelectMsg
    = ChangedRoomSelectInput String
    | Submit


type RoomMsg
    = ChangeColor (Maybe Color)


type RoomAsHostMsg
    = ShowAll
    | Edit
    | ChangedInput Color String
    | Show (Maybe Color)
    | Unveil
    | Veil


type AdminMsg
    = GotTime Posix
    | DeleteRoomClicked RoomId


type ToBackend
    = NoOpToBackend
    | RegisterToRoom RoomId
    | UnveilConstraints RoomId RoomConstraints
    | HideConstraints RoomId
    | RequestRooms
    | DeleteRoom RoomId


type BackendMsg
    = NoOpBackendMsg
    | OnDisconnect ClientId
    | BackendGotTime SessionId ClientId ToBackend Posix


type ToFrontend
    = NoOpToFrontend
    | SendConstraintsToFrontend RoomConstraints Bool
    | HideConstraintsForClient
    | SendRoomsToClient (List RoomForAdmin)
