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
        , subscriptions = App.subscriptions
        , view = view
        }

