module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Lamdera
import Url


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


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , mode : Mode
    , role : Role
    , blue : String
    , yellow : String
    , red : String
    , green : String
    }


type alias BackendModel =
    { blue : String
    , yellow : String
    , red : String
    , green : String
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | ShowAll
    | HideAll
    | Edit
    | ChangedInput Color String
    | Show (Maybe Color)
    | ChangeRole Role
    | Unveil
    | Veil
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend
    | SetConstraints
        { blue : String
        , yellow : String
        , red : String
        , green : String
        }


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected Lamdera.ClientId


type ToFrontend
    = NoOpToFrontend
    | SendConstraintsToFrontend
        { blue : String
        , yellow : String
        , red : String
        , green : String
        }
