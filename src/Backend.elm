module Backend exposing (..)

import Dict
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
    ( { rooms = Dict.empty
      , connectedPlayers = Dict.empty
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        OnDisconnect clientId ->
            ( { model | connectedPlayers = Dict.remove clientId model.connectedPlayers }, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        SetConstraints (RoomId roomId) constraints ->
            ( { model
                | rooms =
                    Dict.update roomId
                        (Maybe.withDefault emptyConstraints
                            >> (\previous ->
                                    Just { previous | blue = constraints.blue, yellow = constraints.yellow, red = constraints.red, green = constraints.green }
                               )
                        )
                        model.rooms
              }
            , SendConstraintsToFrontend constraints
                |> broadcast
            )


emptyConstraints : RoomConstraints
emptyConstraints =
    { blue = ""
    , yellow = ""
    , red = ""
    , green = ""
    }


subscriptions : Model -> Sub BackendMsg
subscriptions _ =
    Lamdera.onDisconnect (\_ clientId -> OnDisconnect clientId)
