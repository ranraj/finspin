module Types exposing (..)
import Math.Vector2 exposing (Vec2)
import Draggable
import Json.Decode exposing (Error(..))
import Math.Vector2 as Vector2 exposing (Vec2)
import Tuple exposing (first,second)

type alias Id =
    String

-------------------------------Note-----------------------------------    
type alias Note =
    { id : Id
    , done : Bool
    , title : String
    , description : String        
    , color : Maybe String
    }

welcomeNotes : List Note
welcomeNotes =  
    [
        { id = "0 - learn"
        , title = "You completed a Task"
        , description = "Simply click on the message to strick  out "
        , done = True
        , color = Nothing
        }
    ,   { id = "1 - start"
        , title = "Welcome to the Finspin"
        , description = "Easy planner board"
        , done = False   
        , color = Nothing               
        }
    ]

emptyNote : Note
emptyNote =
    { id = "" 
    , done = False
    , title = ""
    , description = ""
    , color = Nothing
    }

-------------------------------Box-----------------------------------
type alias Box =
    { id : Id
    , position : Vec2
    , clicked : Bool
    , note : Note
    }


makeBox : Id -> Note -> Vec2 -> Box
makeBox id note position =
    Box id position False note

-------------------------------BoxGroup-----------------------------------
type alias BoxGroup =
    { uid : Int
    , movingBox : Maybe Box
    , idleBoxes : List Box
    }

emptyGroup : BoxGroup
emptyGroup =
    BoxGroup 0 Nothing []

buildNote : Int -> String -> String -> Maybe String -> Note
buildNote length t d color = { 
            id = ((String.fromInt length ++ String.slice 0 5 t))
            , done = False
            , title = t
            , description = d 
            , color = color
            }

addBoxInBoxGroup : Note -> Vec2 -> BoxGroup -> BoxGroup
addBoxInBoxGroup note position ({ uid, idleBoxes } as group) =
    { group
        | idleBoxes = (makeBox (String.fromInt uid) note position) :: idleBoxes
        , uid = uid + 1
    }    

makeBoxGroup : List (Vec2,Note) -> BoxGroup
makeBoxGroup positions =
    positions
        |>  List.foldl (\position -> addBoxInBoxGroup (second position) (first position)) emptyGroup

defaultBoxGroup : BoxGroup
defaultBoxGroup =
    let
        indexToPosition =
            toFloat >> (*) 60 >> (+) 10 >> Vector2.vec2 10
        notes = welcomeNotes
    in
    notes |> List.indexedMap (\i x -> ((indexToPosition i),x)) |> makeBoxGroup

-------------------------------Model-----------------------------------
type alias Model =
    { boxGroup : BoxGroup
    , addingNote : Bool
    , welcomeTour : Bool
    , editNote : Bool
    , noteToAdd : Note
    , drag : Draggable.State Id
    , localData : List Box
    , jsonError : Maybe Error
    , position :  (Int, Int)
    }

-------------------------------Message-----------------------------------
type Msg
    = DragMsg (Draggable.Msg Id)
    | OnDragBy Vec2
    | StartDragging String
    | ToggleBoxClicked String
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

-------------------------------Colour-----------------------------------
type Color = BoardGreen | White
getColor : Color -> String
getColor color = 
    case color of 
        BoardGreen -> "#5F9A80"
        White -> "#FFF" 

type alias LocalStore = 
    {
      welcomeTour : Bool
     ,boxGroups : List BoxGroup
    }