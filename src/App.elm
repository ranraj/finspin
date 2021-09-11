module App exposing (subscriptions,init,emptyBox)

import Draggable

import Model exposing (Model,MouseModel,Note,Box,BoxGroup)
import Msg exposing (Msg(..))
import Ports
import Config exposing (defaultNewTilePosition,defaultBoxSize)

subscriptionsDraggable : Model -> Sub Msg
subscriptionsDraggable { drag } = 
    Draggable.subscriptions DragMsg drag

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch [
                subscriptionsLocalStorage model,
                subscriptionsDraggable model,
                subscriptionsSvgDownload model]

------- Local Stroage --------------------------------
subscriptionsLocalStorage : Model -> Sub Msg
subscriptionsLocalStorage _ = 
        Ports.receiveData ReceivedDataFromJS    

subscriptionsSvgDownload : Model -> Sub Msg
subscriptionsSvgDownload _ = 
          Ports.gotSvg GotSvg   

initialMouseModel : MouseModel
initialMouseModel =
    { position = { x = 0, y = 0 }
    , down = False
    , svgPosition = { x = 0, y = 0 }
    , downSvgPosition = { x = 0, y = 0 }
    }
emptyNote : Note
emptyNote =
    { id = "" 
    , done = False
    , title = ""
    , description = ""    
    }


emptyBox : Box
emptyBox = Box "" defaultNewTilePosition False emptyNote Nothing defaultBoxSize

emptyGroup : BoxGroup
emptyGroup =
    BoxGroup 0 Nothing []

init : flags -> ( Model, Cmd Msg )
init _ =
    ( { boxGroup = emptyGroup
      , drag = Draggable.init
      , isPopUpActive = False
      , editNote = False
      , currentBox = emptyBox
      , saveDefault = True
      , localData = []
      , jsonError = Nothing
      , welcomeTour = True
      , position =  (160, 120)
      , hover = False
      , files = []
      , mouse = initialMouseModel
      }
    , Cmd.none
    )