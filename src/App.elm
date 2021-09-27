module App exposing (..)

import Draggable

import BoardTiles exposing (..)
import BoardEncoder exposing (boxGroupEncoder,boxGroupsEncoder)
import Model exposing (Model,BoxGroup,Position)
import Msg exposing (Color(..),Msg(..))
import Ports
import View exposing (..)
import ContextMenu
import Core
import Task
import Bootstrap.Navbar as Navbar


subscriptions : Model -> Sub Msg
subscriptions model =
     Sub.batch [
                subscriptionsLocalStorage model,
                subscriptionsDrag model,
                subscriptionsSvgDownload model,
                subscriptionsContextMenu model,
                subscriptionsSaveBoards model,
                subscriptionsNavBar model
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
        Ports.receiveData ReceivedBoard    

subscriptionsSvgDownload : Model -> Sub Msg
subscriptionsSvgDownload _ = 
          Ports.gotSvg GotSvg

subscriptionsSaveBoards : Model -> Sub Msg
subscriptionsSaveBoards _ = 
          Ports.receiveBoards ReceivedBoards          

subscriptionsContextMenu : Model -> Sub Msg
subscriptionsContextMenu model =
        Sub.map ContextMenuMsg (ContextMenu.subscriptions model.contextMenu)

subscriptionsNavBar : Model -> Sub Msg
subscriptionsNavBar model =
    Navbar.subscriptions model.navbarState NavbarMsg

init : flags -> ( Model, Cmd Msg )
init _ =
    let
        ( contextMenu, contextMsg ) =
            ContextMenu.init
        initBoxGroup = Core.emptyGroup    
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg 
    in
    
    ( { boxGroup = initBoxGroup
      , drag = Draggable.init
      , isPopUpActive = False
      , editNote = False
      , currentBox = Core.emptyBox
      , saveDefault = True
      , boxGroups = []
      , localBoxGroup = Nothing
      , jsonError = Nothing
      , welcomeTour = True
      , position =  Position 160 120
      , hover = False
      , files = []
      , contextMenu = contextMenu
      , selectedShapeId = Nothing 
      , timeNow = 0    
      , navbarState = navbarState 
      , menuHover = Nothing
      , boardTitleEdit = Nothing
      , searchKeyword = Nothing
      , searchResult = Nothing
      , activity = []
      }
    , Cmd.batch [(Cmd.map ContextMenuMsg contextMsg),Core.run CurrentDateTime, navbarCmd]
    )