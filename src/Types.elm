module Types exposing (..)
import Math.Vector2 as Vector2 exposing (Vec2, getX, getY)
import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)
import Json.Decode exposing (Error(..), Value, decodeValue, string)

type alias Id =
    String
    
type alias Note =
    { id : Id
    , done : Bool
    , title : String
    , description : String        
    }

emptyNote : Note
emptyNote =
    { id = "" 
    , done = False
    , title = ""
    , description = ""
    }

type alias Box =
    { id : Id
    , position : Vec2
    , clicked : Bool
    , note : Note
    }

type alias BoxGroup =
    { uid : Int
    , movingBox : Maybe Box
    , idleBoxes : List Box
    }

emptyGroup : BoxGroup
emptyGroup =
    BoxGroup 0 Nothing []


type alias Model =
    { boxGroup : BoxGroup
    , addingNote : Bool
    , noteToAdd : Note
    , drag : Draggable.State Id
    , localData : List Box
    , jsonError : Maybe Error
    }

type Msg
    = DragMsg (Draggable.Msg Id)
    | OnDragBy Vec2
    | StartDragging String
    | ToggleBoxClicked String
    | StopDragging
    | AddNote String String
    | CheckNote String
    | ClearNote String
    | ChangeTitle String
    | ChangeDesc String
    | StartNoteForm
    | CancelNoteForm
    | ReceivedDataFromJS String

type Color = BoardGreen | White
getColor : Color -> String
getColor color = 
    case color of 
        BoardGreen -> "#5F9A80"
        White -> "#FFF" 
