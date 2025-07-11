module Backend exposing (..)

import Dict
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Set
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
            ( { model | connectedPlayers = Dict.map (\_ clientIds -> Set.remove clientId clientIds) model.connectedPlayers }
            , Cmd.none
            )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        RegisterToRoom (RoomId roomId) ->
            ( { model
                | connectedPlayers =
                    Dict.update
                        roomId
                        (Maybe.withDefault Set.empty >> Set.insert clientId >> Just)
                        model.connectedPlayers
              }
            , Dict.get roomId model.rooms
                |> Maybe.withDefault emptyConstraints
                |> SendConstraintsToFrontend
                |> sendToFrontend clientId
            )

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
