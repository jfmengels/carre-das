module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (ClientId)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , mode : Mode
    , role : Role
    , blue : String
    , yellow : String
    , red : String
    , green : String
    }


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
    | ShowAll
    | Edit
    | ChangedInput Color String
    | Show (Maybe Color)
    | ChangeRole Role
    | Unveil
    | Veil
    | NoOpFrontendMsg


type ToBackend
    = SetConstraints { blue : String, yellow : String, red : String, green : String }


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected ClientId


type ToFrontend
    = NoOpToFrontend
    | SendConstraintsToFrontend { blue : String, yellow : String, red : String, green : String }
