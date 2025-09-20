module ShareRoomLink exposing (init, view)

import Element exposing (Element)
import Element.Font as Font
import Element.Lazy
import QRCode
import Route exposing (Route(..))
import Svg.Attributes
import Types exposing (..)
import Url exposing (Url)


type alias Model =
    ShareRoomLinkModel


init : Url -> String -> Model
init url roomId =
    ShareRoomLinkModel (Url.toString { url | path = Route.toUrl (Route_Room roomId), query = Nothing })


view : Model -> List (Element msg)
view (ShareRoomLinkModel url) =
    [ Element.column
        [ Element.centerX
        , Element.centerY
        ]
        [ Element.paragraph
            [ Font.center
            , Font.size 30
            ]
            [ Element.text url ]
        , Element.Lazy.lazy viewQrCode url
        ]
    ]


viewQrCode : String -> Element msg
viewQrCode url =
    case QRCode.fromString url of
        Ok qrCode ->
            QRCode.toSvg
                [ Svg.Attributes.width "500px"
                , Svg.Attributes.height "500px"
                ]
                qrCode
                |> Element.html

        Err _ ->
            Element.none
