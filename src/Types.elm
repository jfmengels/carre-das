module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (ClientId, SessionId)
import Random
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
    | RandomPage RandomPageModel
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


type alias RandomPageModel =
    { input : String
    , drawn : List String
    , seed : Random.Seed
    , nothingLeftToDraw : Bool
    }


type alias AdminModel =
    { rooms : List RoomForAdmin
    , now : Posix
    , requiresAdminPassword : Bool
    , passwordWasInvalid : Bool
    , adminPassword : String
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
    | RandomPageMsg RandomPageMsg
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


type RandomPageMsg
    = UserChangedInput String
    | UserClickedDraw
    | UserClickedReset
    | GotTime Posix


type AdminMsg
    = GotRooms (List RoomForAdmin) Posix
    | UserChangedPassword String
    | UserSubmittedPassword
    | DeleteRoomClicked RoomId


type ToBackend
    = NoOpToBackend
    | RegisterToRoom RoomId
    | UnveilConstraints RoomId RoomConstraints
    | HideConstraints RoomId
    | RequestRooms (Maybe String)
    | DeleteRoom RoomId


type BackendMsg
    = NoOpBackendMsg
    | OnDisconnect ClientId
    | BackendGotTime SessionId ClientId ToBackend Posix


type ToFrontend
    = NoOpToFrontend
    | SendConstraintsToFrontend RoomConstraints Bool
    | HideConstraintsForClient
    | SendRoomsToClient (Result AdminFailureReason (List RoomForAdmin))


type AdminFailureReason
    = NotLoggedIn
    | InvalidPassword
