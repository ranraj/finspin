module App exposing (..)

import Draggable

import BoardTiles exposing (..)
import BoardEncoder exposing (boxListEncoder)
import Model exposing (Model,Box,Color(..),Msg(..))
import Ports
import View exposing (..)

subscriptions : Model -> Sub Msg
subscriptions { drag } = 
    Draggable.subscriptions DragMsg drag

------- Local Stroage --------------------------------
saveNotes : List Box -> Cmd msg
saveNotes noteBoxes = boxListEncoder noteBoxes |> Ports.storeNotes            

subscriptionsLocalStorage : Model -> Sub Msg
subscriptionsLocalStorage _ = 
        Ports.receiveData ReceivedDataFromJS    

subscriptionsSvgDownload : Model -> Sub Msg
subscriptionsSvgDownload _ = 
          Ports.gotSvg GotSvg