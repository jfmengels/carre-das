module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Lamdera
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


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
    ( { key = key
      , mode = Showing Nothing
      , role = UndecidedUserType
      , blue = ""
      , yellow = ""
      , red = ""
      , green = ""
      }
    , Cmd.none
    )


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
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        ShowAll ->
            ( { model | mode = ShowingAll }, Cmd.none )

        Edit ->
            ( { model | mode = Editing }, Cmd.none )

        ChangedInput color text ->
            ( case color of
                Blue ->
                    { model | blue = text }

                Yellow ->
                    { model | yellow = text }

                Red ->
                    { model | red = text }

                Green ->
                    { model | green = text }
            , Cmd.none
            )

        HideAll ->
            ( { model | mode = Showing Nothing }, Cmd.none )

        Show maybeColor ->
            ( { model | mode = Showing maybeColor }, Cmd.none )

        ChangeRole role ->
            ( { model | role = role }, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ Html.div [ Attr.style "height" "100%" ]
            (case model.role of
                UndecidedUserType ->
                    [ viewRoleSelection ]

                Host ->
                    [ header
                        [ Html.button [ Events.onClick Edit, Attr.style "font-size" "20px" ] [ Html.text "Editer" ]
                        , Html.button [ Events.onClick ShowAll, Attr.style "font-size" "20px" ] [ Html.text "Tout voir" ]
                        , Html.button [ Events.onClick HideAll, Attr.style "font-size" "20px" ] [ Html.text "Tout cacher" ]
                        , Html.button [ Events.onClick (ChangeRole UndecidedUserType), Attr.style "font-size" "20px" ] [ Html.text "Changer de rôle" ]
                        ]
                    , viewBody model
                    ]

                Player color ->
                    let
                        text : String
                        text =
                            case color of
                                Blue ->
                                    model.blue

                                Yellow ->
                                    model.yellow

                                Red ->
                                    model.red

                                Green ->
                                    model.green
                    in
                    [ header
                        [ Html.button [ Events.onClick (ChangeRole UndecidedUserType), Attr.style "font-size" "20px" ] [ Html.text "Changer de rôle" ]
                        ]
                    , Html.div
                        [ Attr.style "display" "flex"
                        , Attr.style "flex-wrap" "wrap"
                        , Attr.style "flex-direction" "row"
                        , Attr.style "min-height" "1000px"
                        ]
                        [ Html.div
                            [ backgroundColor color
                            , Attr.style "color" "white"
                            , Attr.style "font-size" "50px"
                            , Attr.style "font-weight" "bold"
                            , Attr.style "display" "flex"
                            , Attr.style "flex" "1"
                            , Attr.style "justify-content" "center"
                            , Attr.style "flex-direction" "column"
                            , Attr.style "margin" "20px"
                            ]
                            [ Html.div []
                                [ if text == "" then
                                    Html.text "En attente"

                                  else
                                    Html.text text
                                ]
                            ]
                        ]
                    ]
            )
        ]
    }


header : List (Html msg) -> Html msg
header children =
    Html.div
        [ Attr.style "height" "100%"
        , Attr.style "padding" "20px 0 0 20px"
        , Attr.style "display" "flex"
        , Attr.style "gap" "20px"
        , Attr.style "height" "40px"
        ]
        children


viewRoleSelection : Html FrontendMsg
viewRoleSelection =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "flex-wrap" "wrap"
        , Attr.style "flex-direction" "row"
        , Attr.style "justify-content" "center"
        , Attr.style "align-items" "center"
        , Attr.style "height" "100%"
        , Attr.style "width" "100%"
        , Attr.style "max-width" "200px"
        , Attr.style "min-height" "1000px"
        ]
        [ header
            [ Html.button [ Events.onClick (ChangeRole Host), Attr.style "font-size" "20px" ] [ Html.text "Je suis hôte 🪄" ]
            ]
        , Html.div
            [ Attr.style "display" "flex"
            , Attr.style "flex-wrap" "wrap"
            , Attr.style "flex-direction" "row"
            , Attr.style "min-height" "1000px"
            ]
            [ viewPlayerSelectButton Blue
            , viewPlayerSelectButton Yellow
            , viewPlayerSelectButton Red
            , viewPlayerSelectButton Green
            ]
        ]


viewPlayerSelectButton : Color -> Html FrontendMsg
viewPlayerSelectButton color =
    Html.div
        (boxAttributes color (Events.onClick (ChangeRole (Player color))))
        [ viewBoxContent "Joueur"
        ]


viewBody : Model -> Html FrontendMsg
viewBody model =
    bodyWrapper
        [ viewBox Blue model
        , viewBox Yellow model
        , viewBox Red model
        , viewBox Green model
        ]


bodyWrapper : List (Html msg) -> Html msg
bodyWrapper children =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "flex-wrap" "wrap"
        , Attr.style "flex-direction" "row"
        , Attr.style "min-height" "1000px"
        ]
        children


viewBox : Color -> { a | blue : String, yellow : String, red : String, green : String, mode : Mode } -> Html FrontendMsg
viewBox color model =
    let
        text : String
        text =
            case color of
                Blue ->
                    model.blue

                Yellow ->
                    model.yellow

                Red ->
                    model.red

                Green ->
                    model.green
    in
    case model.mode of
        Editing ->
            Html.div
                (boxAttributes color (Attr.class ""))
                [ Html.textarea [ Events.onInput (ChangedInput color), Attr.value text ] [] ]

        ShowingAll ->
            Html.div
                (boxAttributes color (Attr.class ""))
                [ viewBoxContent text
                ]

        Showing Nothing ->
            Html.div
                (boxAttributes color (Events.onClick (Show (Just color))))
                [ viewBoxContent "Révéler" ]

        Showing (Just showingColor) ->
            if color == showingColor then
                Html.div
                    (boxAttributes color (Events.onClick (Show Nothing)))
                    [ viewBoxContent text ]

            else
                Html.div
                    (boxAttributes color (Attr.class ""))
                    [ Html.text "\u{00A0}" ]


boxAttributes : Color -> Html.Attribute msg -> List (Html.Attribute msg)
boxAttributes color eventHandler =
    [ backgroundColor color
    , Attr.style "color" "white"
    , Attr.style "font-size" "50px"
    , Attr.style "font-weight" "bold"
    , Attr.style "display" "flex"
    , Attr.style "flex-basis" "calc(50% - 40px)"
    , Attr.style "justify-content" "center"
    , Attr.style "flex-direction" "column"
    , Attr.style "margin" "20px"
    , eventHandler
    ]


viewBoxContent : String -> Html msg
viewBoxContent text =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "justify-content" "center"
        , Attr.style "flex-direction" "row"
        ]
        [ Html.text
            (if String.isEmpty text then
                "En réserve"

             else
                text
            )
        ]


backgroundColor : Color -> Html.Attribute msg
backgroundColor color =
    Attr.style "background-color"
        (case color of
            Blue ->
                "blue"

            Yellow ->
                "orange"

            Red ->
                "red"

            Green ->
                "green"
        )
