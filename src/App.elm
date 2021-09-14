module App exposing (..)

import Draggable

import BoardTiles exposing (..)
import BoardEncoder exposing (boxListEncoder)
import Model exposing (Model,Box)
import Msg exposing (Color(..),Msg(..))
import Ports
import View exposing (..)
import ContextMenu exposing (ContextMenu)
import Core

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


init : flags -> ( Model, Cmd Msg )
init _ =
    let
        ( contextMenu, contextMsg ) =
            ContextMenu.init
    in
    
    ( { boxGroup = Core.emptyGroup
      , drag = Draggable.init
      , isPopUpActive = False
      , editNote = False
      , currentBox = Core.emptyBox
      , saveDefault = True
      , localData = []
      , jsonError = Nothing
      , welcomeTour = True
      , position =  (160, 120)
      , hover = False
      , files = []
      , contextMenu = contextMenu
      , selectedShapeId = Nothing
      }
    , Cmd.map ContextMenuMsg contextMsg
    )
