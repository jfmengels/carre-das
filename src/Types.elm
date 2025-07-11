module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (ClientId)
import SeqDict exposing (SeqDict)
import Set exposing (Set)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , state : State
    }


type State
    = RoomSelect RoomSelectModel
    | InRoom RoomModel


type alias RoomSelectModel =
    { input : String
    , inputSubmitted : Bool
    }


type alias RoomModel =
    { roomId : RoomId
    , mode : Mode
    , role : Role
    , blue : String
    , yellow : String
    , red : String
    , green : String
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


type alias BackendModel =
    { rooms : SeqDict RoomId Room
    }


type alias Room =
    { constraints : RoomConstraints
    , connectedPlayers : Set ClientId
    , constraintsDisplayed : Bool
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
    | NoOpFrontendMsg


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


type ToBackend
    = RegisterToRoom RoomId
    | SetConstraints RoomId RoomConstraints


type BackendMsg
    = NoOpBackendMsg
    | OnDisconnect ClientId


type ToFrontend
    = NoOpToFrontend
    | SendConstraintsToFrontend RoomConstraints
