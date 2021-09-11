module Main exposing (..)

import Browser

import BoardTiles exposing (..)
import Model exposing (Model)
import Msg exposing (Color(..),Msg(..))
import Core exposing (init)
import View exposing (view)
import Update exposing (..)
import App

-- Elm Architecture --
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = App.subscriptions
        , view = view
        }

