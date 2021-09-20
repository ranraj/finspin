module Main exposing (..)

import Browser

import BoardTiles exposing (..)
import Model exposing (Model)
import Msg exposing (Color(..),Msg(..))
import View
import Update
import App

-- Elm Architecture --
main : Program () Model Msg
main =
    Browser.element
        { init = App.init
        , update = Update.update
        , subscriptions = App.subscriptions
        , view = View.view
        }


