module Frontend exposing (..)

import Admin
import AppUrl
import AudienceRoom
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (Element)
import Html exposing (Html)
import Lamdera
import Room
import RoomAsHost
import RoomSelect
import Route exposing (Route(..))
import Types exposing (..)
import Url exposing (Url)


type alias Model =
    FrontendModel


type alias Msg =
    FrontendMsg


app :
    { init : Url -> Nav.Key -> ( Model, Cmd Msg )
    , view : Model -> Browser.Document Msg
    , update : Msg -> Model -> ( Model, Cmd Msg )
    , updateFromBackend : ToFrontend -> Model -> ( Model, Cmd Msg )
    , subscriptions : Model -> Sub Msg
    , onUrlRequest : Browser.UrlRequest -> Msg
    , onUrlChange : Url.Url -> Msg
    }
app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \_ -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init url key =
    case Route.parseUrl (AppUrl.fromUrl url) of
        Just ( route, needsUrlReplacing ) ->
            let
                ( state, cmd ) =
                    initFromRoute route
            in
            ( { key = key
              , state = state
              }
            , Cmd.batch
                [ cmd
                , if needsUrlReplacing then
                    Nav.replaceUrl key (Route.toUrl route)

                  else
                    Cmd.none
                ]
            )

        Nothing ->
            ( { key = key
              , state = RouteError
              }
            , Nav.replaceUrl key (Route.toUrl Route.Route_RoomSelect)
            )


initFromRoute : Route -> ( State, Cmd Msg )
initFromRoute route =
    case route of
        Route_RoomSelect ->
            ( RoomSelect RoomSelect.init
            , Cmd.none
            )

        Route_Room roomId ->
            let
                ( room, cmd ) =
                    Room.init (RoomId roomId)
            in
            ( InRoom room
            , cmd
            )

        Route_AudienceRoom roomId ->
            let
                ( room, cmd ) =
                    AudienceRoom.init (RoomId roomId)
            in
            ( InAudienceRoom room
            , cmd
            )

        Route_RoomAsHost roomId ->
            let
                room : RoomAsHost.Model
                room =
                    RoomAsHost.init (RoomId roomId)
            in
            ( InRoomAsHost room
            , Cmd.none
            )

        Route_Admin ->
            let
                ( admin, cmd ) =
                    Admin.init
            in
            ( Admin admin
            , Cmd.map AdminMsg cmd
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            init url model.key

        RoomMsg roomMsg ->
            case model.state of
                InRoom roomModel ->
                    let
                        ( room, cmd ) =
                            Room.update roomMsg roomModel
                    in
                    ( { model | state = InRoom room }
                    , Cmd.map RoomMsg cmd
                    )

                _ ->
                    ( model, Cmd.none )

        RoomAsHostMsg roomMsg ->
            case model.state of
                InRoomAsHost roomModel ->
                    let
                        ( room, cmd ) =
                            RoomAsHost.update roomMsg roomModel
                    in
                    ( { model | state = InRoomAsHost room }
                    , Cmd.map RoomAsHostMsg cmd
                    )

                _ ->
                    ( model, Cmd.none )

        RoomSelectMsg roomSelectMsg ->
            case model.state of
                RoomSelect roomSelectModel ->
                    let
                        ( roomSelect, cmd ) =
                            RoomSelect.update model.key roomSelectMsg roomSelectModel
                    in
                    ( { model | state = RoomSelect roomSelect }
                    , cmd
                    )

                _ ->
                    ( model, Cmd.none )

        AdminMsg adminMsg ->
            case model.state of
                Admin adminModel ->
                    let
                        ( admin, cmd ) =
                            Admin.update adminMsg adminModel
                    in
                    ( { model | state = Admin admin }
                    , cmd
                    )

                _ ->
                    ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd msg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        SendConstraintsToFrontend constraints constraintsDisplayed ->
            case model.state of
                InRoom room ->
                    ( { model | state = InRoom (Room.setConstraints constraints constraintsDisplayed room) }
                    , Cmd.none
                    )

                InAudienceRoom room ->
                    ( { model | state = InAudienceRoom (AudienceRoom.setConstraints constraints constraintsDisplayed room) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        HideConstraintsForClient ->
            case model.state of
                InRoom room ->
                    ( { model | state = InRoom (Room.hideConstraints room) }
                    , Cmd.none
                    )

                InAudienceRoom room ->
                    ( { model | state = InAudienceRoom (AudienceRoom.hideConstraints room) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SendRoomsToClient rooms ->
            case model.state of
                Admin adminModel ->
                    ( { model | state = Admin (Admin.gotRooms rooms adminModel) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = ""
    , body =
        case model.state of
            RoomSelect roomSelect ->
                column RoomSelectMsg (RoomSelect.view roomSelect)

            InRoom room ->
                column RoomMsg (Room.view room)

            InAudienceRoom room ->
                column identity (AudienceRoom.view room)

            InRoomAsHost room ->
                column RoomAsHostMsg (RoomAsHost.view room)

            Admin admin ->
                column AdminMsg (Admin.view admin)

            RouteError ->
                []
    }


column : (msg -> a) -> List (Element msg) -> List (Html a)
column mapper body =
    [ Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        ]
        body
        |> Element.map mapper
        |> Element.layout []
    ]
