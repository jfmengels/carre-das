module Frontend exposing (..)

import AppUrl exposing (AppUrl)
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (Element)
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


type Route
    = Route_RoomSelect
    | Route_Room String


parseUrl : AppUrl -> Route
parseUrl url =
    case url.path of
        [] ->
            Route_RoomSelect

        [ "room", roomId ] ->
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

                RoomSelect _ ->
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

                InRoom _ ->
                    ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd msg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        SendConstraintsToFrontend constraints ->
            case model.state of
                InRoom room ->
                    ( { model | state = InRoom (Room.setConstraints constraints room) }
                    , Cmd.none
                    )

                RoomSelect _ ->
                    ( model, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        case model.state of
            InRoom room ->
                [ Element.column
                    [ Element.height Element.fill
                    , Element.width Element.fill
                    ]
                    (Room.view room)
                    |> Element.map RoomMsg
                    |> Element.layout []
                ]

            RoomSelect roomSelect ->
                [ Element.column
                    [ Element.height Element.fill
                    , Element.width Element.fill
                    ]
                    (RoomSelect.view roomSelect)
                    |> Element.map RoomSelectMsg
                    |> Element.layout []
                ]
    }
