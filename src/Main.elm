module Main exposing (..)

import Browser

import BoardTiles exposing (..)
import Model exposing (Model,Color(..),Msg(..))
import Core exposing (init)
import View exposing (..)
import Update exposing (..)
import App exposing (..)

-- Elm Architecture --
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \model -> Sub.batch [subscriptionsLocalStorage model,subscriptions model,subscriptionsSvgDownload model]
        , view = view
        }

