module Model exposing (..)

import Math.Vector2 exposing (Vec2)
import Draggable
import Json.Decode exposing (Error(..))
import File exposing (File)
import ContextMenu exposing (ContextMenu)
import Dict exposing (Dict)
import Bootstrap.Navbar as Navbar

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
    , position : Vec2
    , clicked : Bool
    , note : Note
    , color : Maybe String
    , size : BoxSize
    }

-------------------------------BoxGroup-----------------------------------
type alias BoxGroup =
    { uid : String
    , name : Maybe String
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
    , boxGroups : List BoxGroup
    , localBoxGroup : Maybe BoxGroup
    , jsonError : Maybe Error
    , position :  (Int, Int)
    , hover : Bool
    , files : List File
    , contextMenu : ContextMenu String
    , selectedShapeId : Maybe String   
    , timeNow : Int 
    , navbarState : Navbar.State
    }


type alias LocalStore = 
    {
      welcomeTour : Bool
     ,boxGroups : List BoxGroup
    }

-------------------------------TileSize-----------------------------------
type alias BoxSize = 
        {
            title : String,            
            width : Float,
            height : Float
         }
