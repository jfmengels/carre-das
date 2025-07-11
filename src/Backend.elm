module Backend exposing (..)

import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import SeqDict
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
    ( { rooms = SeqDict.empty
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        OnDisconnect clientId ->
            ( { model
                | rooms =
                    SeqDict.map
                        (\_ room ->
                            { room | connectedPlayers = Set.remove clientId room.connectedPlayers }
                        )
                        model.rooms
              }
            , Cmd.none
            )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        RegisterToRoom roomId ->
            case SeqDict.get roomId model.rooms of
                Nothing ->
                    ( { model | rooms = SeqDict.insert roomId (emptyRoom clientId emptyConstraints) model.rooms }, Cmd.none )

                Just room ->
                    ( { model
                        | rooms =
                            SeqDict.insert
                                roomId
                                { room | connectedPlayers = Set.insert clientId room.connectedPlayers }
                                model.rooms
                      }
                    , SendConstraintsToFrontend room.constraints room.constraintsDisplayed
                        |> sendToFrontend clientId
                    )

        UnveilConstraints roomId constraints ->
            case SeqDict.get roomId model.rooms of
                Nothing ->
                    ( { model
                        | rooms =
                            SeqDict.insert roomId
                                { constraints = constraints
                                , connectedPlayers = Set.singleton clientId
                                , constraintsDisplayed = True
                                }
                                model.rooms
                      }
                    , Cmd.none
                    )

                Just room ->
                    ( { model
                        | rooms =
                            SeqDict.insert
                                roomId
                                { connectedPlayers = Set.insert clientId room.connectedPlayers
                                , constraints = constraints
                                , constraintsDisplayed = True
                                }
                                model.rooms
                      }
                    , room.connectedPlayers
                        |> Set.remove clientId
                        |> Set.toList
                        |> List.map
                            (\connectedPlayerId ->
                                SendConstraintsToFrontend constraints True
                                    |> sendToFrontend connectedPlayerId
                            )
                        |> Cmd.batch
                    )

        HideConstraints roomId ->
            case SeqDict.get roomId model.rooms of
                Nothing ->
                    ( model, Cmd.none )

                Just room ->
                    ( { model
                        | rooms =
                            SeqDict.insert
                                roomId
                                { room
                                    | connectedPlayers = Set.insert clientId room.connectedPlayers
                                    , constraintsDisplayed = False
                                }
                                model.rooms
                      }
                    , room.connectedPlayers
                        |> Set.remove clientId
                        |> Set.toList
                        |> List.map (\connectedPlayerId -> HideConstraintsForClient |> sendToFrontend connectedPlayerId)
                        |> Cmd.batch
                    )


emptyRoom : ClientId -> RoomConstraints -> Room
emptyRoom clientId constraints =
    { constraints = constraints
    , connectedPlayers = Set.singleton clientId
    , constraintsDisplayed = False
    }


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
