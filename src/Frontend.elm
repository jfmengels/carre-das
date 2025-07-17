module Frontend exposing (..)

import Admin
import AppUrl exposing (AppUrl)
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (Element)
import Html exposing (Html)
import Lamdera
import Room
import RoomSelect
import Types exposing (..)
import Url exposing (Url)


type alias Model =
    FrontendModel


app :
    { init : Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
    , view : Model -> Browser.Document FrontendMsg
    , update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
    , updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
    , subscriptions : Model -> Sub FrontendMsg
    , onUrlRequest : Browser.UrlRequest -> FrontendMsg
    , onUrlChange : Url.Url -> FrontendMsg
    }
app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    case parseUrl (AppUrl.fromUrl url) of
        Route_RoomSelect ->
            ( { key = key
              , state = RoomSelect RoomSelect.init
              }
            , Cmd.none
            )

        Route_Room roomId ->
            let
                ( room, cmd ) =
                    Room.init (RoomId roomId)
            in
            ( { key = key
              , state = InRoom room
              }
            , cmd
            )

        Route_Admin ->
            let
                ( admin, cmd ) =
                    Admin.init
            in
            ( { key = key
              , state = Admin admin
              }
            , Cmd.map AdminMsg cmd
            )


type Route
    = Route_RoomSelect
    | Route_Room String
    | Route_Admin


parseUrl : AppUrl -> Route
parseUrl url =
    case url.path of
        [] ->
            Route_RoomSelect

        [ "admin" ] ->
            Route_Admin

        [ "room", roomId ] ->
            Route_Room roomId

        -- TODO Make host a different Route
        [ "room", roomId, "host" ] ->
            Route_Room roomId

        _ ->
            Route_RoomSelect


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
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

                _ ->
                    ( model, Cmd.none )

        HideConstraintsForClient ->
            case model.state of
                InRoom room ->
                    ( { model | state = InRoom (Room.hideConstraints room) }
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


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        case model.state of
            InRoom room ->
                column RoomMsg (Room.view room)

            RoomSelect roomSelect ->
                column RoomSelectMsg (RoomSelect.view roomSelect)

            Admin admin ->
                column AdminMsg (Admin.view admin)
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
