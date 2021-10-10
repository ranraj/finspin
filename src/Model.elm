module Model exposing (..)

import Math.Vector2 exposing (Vec2)
import Draggable
import Json.Decode exposing (Error(..))
import File exposing (File)
import ContextMenu exposing (ContextMenu)
import Dict exposing (Dict)
import Bootstrap.Navbar as Navbar
import Time
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
type alias BoxInput = 
    {
        id : Id
        , position : Vec2
        , note : Note
        , color : Maybe String
        , size : BoxSize
    }

type alias Box =
    { id : Id
    , position : Vec2
    , clicked : Bool
    , note : Note
    , color : Maybe String
    , size : BoxSize
    , display : BoxDisplay
    , audit : AuditInfo
    }

type alias BoxDisplay = 
    {
     hidden : Bool
    , foundInSearch : Bool
    }
-------------------------------BoxGroup-----------------------------------
type alias BoxGroup =
    { uid : String
    , name : String
    , movingBox : Maybe Box
    , idleBoxes : List Box
    }

type alias AuditInfo =
    {
        createdAt : Time.Posix
        , updatedAt : Time.Posix
        , createdBy : String
        , updatedBy : String
    }
-------------------------------Model-----------------------------------
type alias Model =
    { boxGroup : BoxGroup       
    , isPopUpActive : Bool
    , welcomeTour : Bool
    , editNote : Bool
    , saveDefault : Bool
    , currentBox : Maybe BoxInput
    , drag : Draggable.State Id
    , boxGroups : List BoxGroup
    , localBoxGroup : Maybe BoxGroup
    , jsonError : Maybe Error
    , position :  Position
    , hover : Bool
    , files : List File
    , contextMenu : ContextMenu String
    , selectedShapeId : Maybe String   
    , timeNow : Int 
    , navbarState : Navbar.State
    , menuHover : Maybe String
    , boardTitleEdit : Maybe String    
    , searchKeyword : Maybe String
    , searchResult : Maybe BoxGroup 
    , activity : List Activity
    }


type alias LocalStore = 
    {
      welcomeTour : Bool
     ,boxGroups : List BoxGroup
    }

-------------------------------TileSize-----------------------------------
type alias BoxSize = 
        {
              title : String           
            , width : Float
            , height : Float
         }

type alias Position = {x: Int, y:Int}

type ActivityType = CreateNoteAction String -- Created Box Id
                | UpdateNoteAction Box -- Previous box status
                | DeleteNoteAction Box  -- Deleted Box Copy
                | MoveNoteAction Box -- Previous location of Box
                | DuplicateNoteAction String
                | NoAction

type alias Activity = 
    {
         action : ActivityType
    }