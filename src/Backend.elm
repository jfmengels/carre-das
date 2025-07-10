module Backend exposing (..)

import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { blue = "", yellow = "", red = "", green = "" }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        ClientConnected clientId ->
            ( model
            , SendConstraintsToFrontend model
                |> sendToFrontend clientId
            )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        SetConstraints constraints ->
            ( constraints
            , SendConstraintsToFrontend constraints
                |> broadcast
            )


subscriptions : Model -> Sub BackendMsg
subscriptions _ =
    Lamdera.onConnect
        (\_ clientId -> ClientConnected clientId)
