module Evergreen.V7.Types exposing (..)

import Browser
import Browser.Navigation
import Lamdera
import Random
import SeqDict
import Set
import Time
import Url


type alias RoomSelectModel =
    { input : String
    , inputSubmitted : Bool
    }


type RoomId
    = RoomId String


type Color
    = Blue
    | Yellow
    | Red
    | Green


type alias RoomConstraints =
    { blue : String
    , yellow : String
    , red : String
    , green : String
    }


type alias RoomModel =
    { roomId : RoomId
    , constraintsDisplayed : Bool
    , color : Maybe Color
    , constraints : RoomConstraints
    }


type Mode
    = Editing
    | ShowingAll
    | Showing (Maybe Color)


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


type alias RoomForAdmin =
    { id : RoomId
    , lastChangeDate : Time.Posix
    }


type alias AdminModel =
    { rooms : List RoomForAdmin
    , now : Time.Posix
    , requiresAdminPassword : Bool
    , passwordWasInvalid : Bool
    , adminPassword : String
    }


type State
    = RoomSelect RoomSelectModel
    | InRoom RoomModel
    | InRoomAsHost RoomAsHostModel
    | InAudienceRoom AudienceRoomModel
    | RandomPage RandomPageModel
    | Admin AdminModel
    | RouteError


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , state : State
    }


type alias Room =
    { constraints : RoomConstraints
    , connectedPlayers : Set.Set Lamdera.ClientId
    , constraintsDisplayed : Bool
    , lastChangeDate : Time.Posix
    }


type alias BackendModel =
    { rooms : SeqDict.SeqDict RoomId Room
    , authenticatedAdmins : SeqDict.SeqDict Lamdera.SessionId Time.Posix
    }


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
    | GotTime Time.Posix


type AdminMsg
    = GotRooms (List RoomForAdmin) Time.Posix
    | UserChangedPassword String
    | UserSubmittedPassword
    | DeleteRoomClicked RoomId


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | RoomSelectMsg RoomSelectMsg
    | RoomMsg RoomMsg
    | RoomAsHostMsg RoomAsHostMsg
    | RandomPageMsg RandomPageMsg
    | AdminMsg AdminMsg
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend
    | RegisterToRoom RoomId
    | UnveilConstraints RoomId RoomConstraints
    | HideConstraints RoomId
    | RequestRooms (Maybe String)
    | DeleteRoom RoomId


type BackendMsg
    = NoOpBackendMsg
    | OnDisconnect Lamdera.ClientId
    | BackendGotTime Lamdera.SessionId Lamdera.ClientId ToBackend Time.Posix


type AdminFailureReason
    = NotLoggedIn
    | InvalidPassword


type ToFrontend
    = NoOpToFrontend
    | SendConstraintsToFrontend RoomConstraints Bool
    | HideConstraintsForClient
    | SendRoomsToClient (Result AdminFailureReason (List RoomForAdmin))
