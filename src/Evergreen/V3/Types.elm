module Evergreen.V3.Types exposing (..)

import Browser
import Browser.Navigation
import Lamdera
import SeqDict
import Set
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


type State
    = RoomSelect RoomSelectModel
    | InRoom RoomModel


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


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | RoomSelectMsg RoomSelectMsg
    | RoomMsg RoomMsg
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend
    | RegisterToRoom RoomId
    | UnveilConstraints RoomId RoomConstraints
    | HideConstraints RoomId


type BackendMsg
    = NoOpBackendMsg
    | OnDisconnect Lamdera.ClientId


type ToFrontend
    = NoOpToFrontend
    | SendConstraintsToFrontend RoomConstraints Bool
    | HideConstraintsForClient
