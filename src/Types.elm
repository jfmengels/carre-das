module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
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
    = SetConstraints { blue : String, yellow : String, red : String, green : String }


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | SendConstraintsToFrontend { blue : String, yellow : String, red : String, green : String }
