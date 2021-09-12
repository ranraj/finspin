module App exposing (..)

import Draggable

import BoardTiles exposing (..)
import BoardEncoder exposing (boxListEncoder)
import Model exposing (Model,Box,Color(..),Msg(..))
import Ports
import View exposing (..)
import ContextMenu exposing (ContextMenu)

subscriptions : Model -> Sub Msg
subscriptions model =
     Sub.batch [
                subscriptionsLocalStorage model,
                subscriptionsDrag model,
                subscriptionsSvgDownload model,
                subscriptionsContextMenu model
                ]

subscriptionsDrag : Model -> Sub Msg
subscriptionsDrag { drag } = 
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

subscriptionsContextMenu : Model -> Sub Msg
subscriptionsContextMenu model =
        Sub.map ContextMenuMsg (ContextMenu.subscriptions model.contextMenu)