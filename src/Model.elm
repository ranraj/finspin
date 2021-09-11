module Model exposing (..)

import Math.Vector2 exposing (Vec2)
import Draggable
import Json.Decode exposing (Error(..))
import File exposing (File)
import Date exposing (Date)

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
    }

-------------------------------Message-----------------------------------
type Msg
    = DragMsg (Draggable.Msg Id)
    | OnDragBy Vec2
    | StartDragging String    
    | ViewNote String
    | StopDragging
    | AddNote String String
    | CheckNote String
    | ClearNote String
    | ChangeTitle String
    | ChangeDesc String
    | StartNoteForm
    | CancelNoteForm
    | ReceivedDataFromJS String
    | UpdateNote String String
    | SaveBoard 
    | Position Int Int
    | UpdateTitleColor String
    | InitDownloadSVG String
    | DownloadSVG String Date
    | Pick
    | DragEnter
    | DragLeave
    | GotFiles File (List File)  
    | MarkdownLoaded String
    | ToggleAutoSave
    | UpdateBoxSize BoxSize
    | GetSvg
    | GotSvg String


-------------------------------Colour-----------------------------------
type Color = BoardGreen | White

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
