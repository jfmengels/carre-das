module Admin exposing
    ( Model
    , Msg
    , gotRooms
    , init
    , update
    , view
    )

import DateFormat.Relative
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Extra
import Element.Input
import Lamdera exposing (sendToBackend)
import Route
import Task
import Time
import Types exposing (..)


type alias Model =
    AdminModel


type alias Msg =
    AdminMsg


init : ( Model, Cmd Msg )
init =
    ( { rooms = []
      , now = Time.millisToPosix 0
      , requiresAdminPassword = False
      , adminPassword = ""
      }
    , sendToBackend (RequestRooms Nothing)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotRooms rooms now ->
            ( { model
                | rooms = rooms
                , now = now
                , requiresAdminPassword = False
              }
            , Cmd.none
            )

        UserChangedPassword adminPassword ->
            ( { model | adminPassword = adminPassword }
            , Cmd.none
            )

        UserSubmittedPassword ->
            ( model
            , sendToBackend (RequestRooms (Just model.adminPassword))
            )

        DeleteRoomClicked roomId ->
            ( { model
                | now = model.now
                , rooms = List.filter (\{ id } -> id /= roomId) model.rooms
              }
            , DeleteRoom roomId
                |> sendToBackend
            )


gotRooms : Result () (List RoomForAdmin) -> Model -> ( Model, Cmd AdminMsg )
gotRooms result model =
    case result of
        Ok rooms ->
            ( model
            , Time.now
                |> Task.perform (\now -> GotRooms rooms now)
            )

        Err () ->
            ( { model | requiresAdminPassword = True }, Cmd.none )


view : Model -> List (Element Msg)
view model =
    if model.requiresAdminPassword then
        [ viewAdminPasswordForm model.adminPassword ]

    else
        [ viewRoomList model.rooms model.now ]


viewAdminPasswordForm : String -> Element Msg
viewAdminPasswordForm adminPassword =
    Element.column
        [ Element.centerX
        , Element.centerY
        , Element.spacing 5
        ]
        [ Element.Input.text
            [ Element.height Element.fill
            , Element.width Element.fill
            , Element.Extra.onEnter UserSubmittedPassword
            , Element.Input.focusedOnLoad
            ]
            { onChange = UserChangedPassword
            , text = adminPassword
            , placeholder = Nothing
            , label =
                Element.Input.labelAbove
                    [ Element.centerX
                    , Element.centerY
                    ]
                    (Element.text "Mot de passe administrateur")
            }
        , Element.el
            [ Element.centerX
            , Element.centerY
            ]
            (button
                { onPress = Just UserSubmittedPassword
                , label = Element.text "Valider"
                }
            )
        ]


viewRoomList : List RoomForAdmin -> Time.Posix -> Element AdminMsg
viewRoomList rooms now =
    Element.table []
        { data = rooms
        , columns =
            [ { header = Element.text "ID"
              , width = Element.fill
              , view =
                    .id
                        >> unwrapRoomId
                        >> (\roomId ->
                                Element.link []
                                    { url = Route.toUrl (Route.Route_Room roomId)
                                    , label =
                                        Element.text roomId
                                    }
                           )
              }
            , { header = Element.text "Last activity"
              , width = Element.fill
              , view =
                    \room ->
                        DateFormat.Relative.relativeTimeWithOptions DateFormat.Relative.defaultRelativeOptions now room.lastChangeDate
                            |> Element.text
              }
            , { header = Element.text "Last activity"
              , width = Element.shrink
              , view = \room -> button { onPress = Just (DeleteRoomClicked room.id), label = Element.text "Supprimer" }
              }
            ]
        }


unwrapRoomId : RoomId -> String
unwrapRoomId (RoomId roomId) =
    roomId


button : { onPress : Maybe msg, label : Element msg } -> Element msg
button =
    Element.Input.button
        [ Border.width 1
        , Border.rounded 3
        , Element.padding 5
        , Background.color (Element.rgb 0.95 0.95 0.95)
        ]
