module App exposing (subscriptions,init,emptyBox)

import Draggable

import Model exposing (Model,MouseModel,Note,Box,BoxGroup,Shape(..),Tool(..))
import Msg exposing (Msg(..))
import Ports
import Config exposing (defaultNewTilePosition,defaultBoxSize)
import Dict exposing (Dict)

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

initialShapes : Dict Int Shape
initialShapes =
    Dict.empty
        |> Dict.insert 1
            (Rect
                { x = 200
                , y = 200
                , width = 200
                , height = 200
                , stroke = "#000000"
                , strokeWidth = 10
                , fill = "#ffffff"
                }
            )
        |> Dict.insert 2
            (Circle
                { cx = 500
                , cy = 200
                , r = 50
                , stroke = "#ff0000"
                , strokeWidth = 10
                , fill = "#00ffff"
                }
            )


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
      , dragAction = Nothing
      , comparedShape = Nothing
      , shapes = initialShapes
      , selectedShapeId = Nothing
      , selectedTool = PointerTool
      }
    , Cmd.none
    )