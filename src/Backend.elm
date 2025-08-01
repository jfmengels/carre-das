module Backend exposing (..)

import Constraints
import Env
import Lamdera exposing (ClientId, SessionId, sendToFrontend)
import SeqDict
import Set
import Task
import Time exposing (Posix)
import Types exposing (..)


type alias Model =
    BackendModel


type alias Msg =
    BackendMsg


app :
    { init : ( Model, Cmd Msg )
    , update : Msg -> Model -> ( Model, Cmd Msg )
    , updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd Msg )
    , subscriptions : Model -> Sub Msg
    }
app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { rooms = SeqDict.empty
      , authenticatedAdmins = SeqDict.empty
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
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

        BackendGotTime sessionId clientId toBackend time ->
            updateFromFrontendWithTime time sessionId clientId toBackend model


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd Msg )
updateFromFrontend sessionId clientId toBackend model =
    ( model
    , Task.perform (BackendGotTime sessionId clientId toBackend) Time.now
    )


updateFromFrontendWithTime : Posix -> SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd Msg )
updateFromFrontendWithTime now sessionId clientId toBackend model =
    case toBackend of
        NoOpToBackend ->
            ( model, Cmd.none )

        RegisterToRoom roomId ->
            case SeqDict.get roomId model.rooms of
                Nothing ->
                    ( { model
                        | rooms =
                            SeqDict.insert roomId
                                { constraints = Constraints.empty
                                , connectedPlayers = Set.singleton clientId
                                , constraintsDisplayed = False
                                , lastChangeDate = now
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
                                , lastChangeDate = now
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
                                , lastChangeDate = now
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

        RequestRooms maybePassword ->
            if SeqDict.member sessionId model.authenticatedAdmins then
                authenticateAndSendRooms sessionId clientId now model

            else
                case maybePassword of
                    Just pwd ->
                        if pwd == Env.adminPassword then
                            authenticateAndSendRooms sessionId clientId now model

                        else
                            ( model
                            , Err InvalidPassword
                                |> SendRoomsToClient
                                |> sendToFrontend clientId
                            )

                    Nothing ->
                        ( model
                        , Err NotLoggedIn
                            |> SendRoomsToClient
                            |> sendToFrontend clientId
                        )

        DeleteRoom roomId ->
            ( { model | rooms = SeqDict.remove roomId model.rooms }
            , Cmd.none
            )


authenticateAndSendRooms : SessionId -> ClientId -> Posix -> Model -> ( Model, Cmd Msg )
authenticateAndSendRooms sessionId clientId now model =
    ( { model | authenticatedAdmins = SeqDict.insert sessionId now model.authenticatedAdmins }
    , model.rooms
        |> SeqDict.foldl (\roomId room acc -> { id = roomId, lastChangeDate = room.lastChangeDate } :: acc) []
        |> Ok
        |> SendRoomsToClient
        |> sendToFrontend clientId
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Lamdera.onDisconnect (\_ clientId -> OnDisconnect clientId)
