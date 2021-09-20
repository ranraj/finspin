module App exposing (..)

import Draggable

import BoardTiles exposing (..)
import BoardEncoder exposing (boxGroupEncoder,boxGroupsEncoder)
import Model exposing (Model,Box,BoxGroup)
import Msg exposing (Color(..),Msg(..))
import Ports
import View exposing (..)
import ContextMenu exposing (ContextMenu)
import Core
import Dict
import Task
subscriptions : Model -> Sub Msg
subscriptions model =
     Sub.batch [
                subscriptionsLocalStorage model,
                subscriptionsDrag model,
                subscriptionsSvgDownload model,
                subscriptionsContextMenu model,
                subscriptionsSaveBoards model
                ]

subscriptionsDrag : Model -> Sub Msg
subscriptionsDrag { drag } = 
    Draggable.subscriptions DragMsg drag

------- Local Stroage --------------------------------
saveNotes : BoxGroup -> Cmd msg
saveNotes boxGroup = boxGroupEncoder boxGroup |> Ports.storeNotes            

saveBoards : List BoxGroup -> Cmd msg
saveBoards boxGroups = boxGroupsEncoder boxGroups |> Ports.storeBoards            

subscriptionsLocalStorage : Model -> Sub Msg
subscriptionsLocalStorage _ = 
        Ports.receiveData ReceivedDataFromJS    

subscriptionsSvgDownload : Model -> Sub Msg
subscriptionsSvgDownload _ = 
          Ports.gotSvg GotSvg

subscriptionsSaveBoards : Model -> Sub Msg
subscriptionsSaveBoards _ = 
          Ports.receiveBoards GotSvg          

subscriptionsContextMenu : Model -> Sub Msg
subscriptionsContextMenu model =
        Sub.map ContextMenuMsg (ContextMenu.subscriptions model.contextMenu)


init : flags -> ( Model, Cmd Msg )
init _ =
    let
        ( contextMenu, contextMsg ) =
            ContextMenu.init
        initBoxGroup = Core.emptyGroup    
    in
    
    ( { boxGroup = initBoxGroup
      , drag = Draggable.init
      , isPopUpActive = False
      , editNote = False
      , currentBox = Core.emptyBox
      , saveDefault = True
      , boxGroups = [initBoxGroup]
      , localBoxGroup = Nothing
      , jsonError = Nothing
      , welcomeTour = True
      , position =  (160, 120)
      , hover = False
      , files = []
      , contextMenu = contextMenu
      , selectedShapeId = Nothing 
      , timeNow = 0     
      }
    , Cmd.batch [(Cmd.map ContextMenuMsg contextMsg),Task.perform (always CurrentDateTime) (Task.succeed ())]
    )
