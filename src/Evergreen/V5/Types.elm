module Evergreen.V5.Types exposing (..)

import Browser
import Browser.Navigation
import Lamdera
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


type Mode
    = Editing
    | ShowingAll
    | Showing (Maybe Color)


type Role
    = UndecidedUserType
    | Host
    | Player Color


type alias RoomModel =
    { roomId : RoomId
    , mode : Mode
    , constraintsDisplayed : Bool
    , role : Role
    , blue : String
    , yellow : String
    , red : String
    , green : String
    }


type alias RoomForAdmin =
    { id : RoomId
    , lastChangeDate : Time.Posix
    }


type alias AdminModel =
    { rooms : List RoomForAdmin
    , now : Time.Posix
    }


type State
    = RoomSelect RoomSelectModel
    | InRoom RoomModel
    | Admin AdminModel


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , state : State
    }


type alias RoomConstraints =
    { blue : String
    , yellow : String
    , red : String
    , green : String
    }


type alias Room =
    { constraints : RoomConstraints
    , connectedPlayers : Set.Set Lamdera.ClientId
    , constraintsDisplayed : Bool
    , lastChangeDate : Time.Posix
    }


type alias BackendModel =
    { rooms : SeqDict.SeqDict RoomId Room
    }


type RoomSelectMsg
    = ChangedRoomSelectInput String
    | Submit


type RoomMsg
    = ShowAll
    | Edit
    | ChangedInput Color String
    | Show (Maybe Color)
    | ChangeRole Role
    | Unveil
    | Veil


type AdminMsg
    = GotTime Time.Posix
    | DeleteRoomClicked RoomId


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | RoomSelectMsg RoomSelectMsg
    | RoomMsg RoomMsg
    | AdminMsg AdminMsg
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend
    | RegisterToRoom RoomId
    | UnveilConstraints RoomId RoomConstraints
    | HideConstraints RoomId
    | RequestRooms
    | DeleteRoom RoomId


type BackendMsg
    = NoOpBackendMsg
    | OnDisconnect Lamdera.ClientId
    | BackendGotTime Lamdera.ClientId ToBackend Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendConstraintsToFrontend RoomConstraints Bool
    | HideConstraintsForClient
    | SendRoomsToClient (List RoomForAdmin)
