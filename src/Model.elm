module Model exposing (..)

import Draggable
import Json.Decode exposing (Error(..))
import File exposing (File)
import Dict exposing (Dict)

type alias Id =
    String

-------------------------------Note-----------------------------------    
type alias Note =
    { id : Id
    , done : Bool
    , title : String
    , description : String            
    }

-------------------------------Box-----------------------------------
type alias Box =
    { id : Id
    , position : Position
    , clicked : Bool
    , note : Note
    , color : Maybe String
    , size : BoxSize
    }

-------------------------------BoxGroup-----------------------------------
type alias BoxGroup =
    { uid : Int
    , movingBox : Maybe Box
    , idleBoxes : List Box
    }

-------------------------------Model-----------------------------------
type alias Model =
    { boxGroup : BoxGroup
    , isPopUpActive : Bool
    , welcomeTour : Bool
    , editNote : Bool
    , saveDefault : Bool
    , currentBox : Box
    , drag : Draggable.State Id
    , localData : List Box
    , jsonError : Maybe Error
    , position :  (Int, Int)
    , hover : Bool
    , files : List File
    , mouse : MouseModel
    , dragAction : Maybe DragAction    
    , comparedShape : Maybe Shape
    , shapes : Dict Int Shape    
    , selectedShapeId : Maybe Int
    , selectedTool : Tool
    }



type alias LocalStore = 
    {
      welcomeTour : Bool,
      boxGroups : List BoxGroup
    }

-------------------------------TileSize-----------------------------------
type alias BoxSize = 
    {
        title : String,            
        width : Float,
        height : Float
    }

-------------------------------Position-----------------------------------
type alias Position = 
    {
        x : Float,
        y : Float        
    }

------------------------------ Svg tool ----------------------------------
type alias User =
    { displayName : String
    , email : String
    , photoUrl : String
    }


type Tool
    = PointerTool
    | RectTool
    | CircleTool
    | TextTool
    | ImageTool


type alias MouseModel =
    { position : Position
    , down : Bool
    , svgPosition : SvgPosition
    , downSvgPosition : SvgPosition
    }

type alias SvgPosition =
    { x : Float
    , y : Float
    }

type Shape
    = Rect RectModel
    | Circle CircleModel
    | Text TextModel
    | Image ImageModel


type alias RectModel =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , stroke : String
    , strokeWidth : Float
    , fill : String
    }


type alias CircleModel =
    { cx : Float
    , cy : Float
    , r : Float
    , stroke : String
    , strokeWidth : Float
    , fill : String
    }


type alias TextModel =
    { x : Float
    , y : Float
    , content : String
    , fontFamily : String
    , fontSize : Int
    , stroke : String
    , strokeWidth : Float
    , fill : String
    }


type alias ImageModel =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , href : String
    }

type DragAction
    = DragMove
    | DragResize