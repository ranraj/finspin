module Types exposing (..)
import Math.Vector2 exposing (Vec2)
import Draggable
import Json.Decode exposing (Error(..))
import Math.Vector2 as Vector2 exposing (Vec2)
import Tuple exposing (first,second)
import Config exposing (defaultNewTilePosition)
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

welcomeNotes : List Note
welcomeNotes =  
    [
        { id = "0 - learn"
        , title = "You completed a Task"
        , description = "Simply click on the message to strick  out "
        , done = True        
        }
    ,   { id = "1 - start"
        , title = "Welcome to the Finspin"
        , description = "Easy planner board"
        , done = False              
        }
    ]

emptyNote : Note
emptyNote =
    { id = "" 
    , done = False
    , title = ""
    , description = ""    
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

emptyBox : Box
emptyBox = Box "" defaultNewTilePosition False emptyNote Nothing defaultBoxSize

makeBox : Id -> Note -> Vec2 -> Maybe String -> BoxSize -> Box 
makeBox id note position color size =
    Box id position False note color size


makeBoxDefaultSize : Id -> Note -> Vec2 -> Maybe String -> Box 
makeBoxDefaultSize id note position color =
    Box id position False note color defaultBoxSize

updateNoteBox : Model -> Box -> String -> String -> Box
updateNoteBox model box t d = if (box.id == model.currentBox.id) then
                                        let
                                            currentBox = model.currentBox
                                            newTitle = if String.isEmpty t then box.note.title else t
                                            newDescription = if String.isEmpty d then box.note.description else d
                                            color = case currentBox.color of
                                                        Just _ -> currentBox.color
                                                        Nothing -> box.color
                                            note = box.note             
                                            newNote = {note | title = newTitle,description = newDescription}
                                        in    
                                            {box | color = color, size = currentBox.size, note = newNote}
                                    else 
                                        box
-------------------------------BoxGroup-----------------------------------
type alias BoxGroup =
    { uid : Int
    , movingBox : Maybe Box
    , idleBoxes : List Box
    }

emptyGroup : BoxGroup
emptyGroup =
    BoxGroup 0 Nothing []

buildNote : Int -> String -> String ->  Note
buildNote length t d  = { 
            id = ((String.fromInt length ++ String.slice 0 5 t))
            , done = False
            , title = t
            , description = d             
            }

addBoxInBoxGroup : Note -> Vec2 -> BoxGroup -> BoxGroup
addBoxInBoxGroup note position ({ uid, idleBoxes } as group) =
    { group
        | idleBoxes = (makeBox (String.fromInt uid) note position) Nothing defaultBoxSize :: idleBoxes
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

-------------------------------TileSize-----------------------------------
type alias BoxSize = 
        {
            title : String,            
            width : Float,
            height : Float
         }

boxSize : Vec2
boxSize =
    Vector2.vec2 defaultBoxSize.width defaultBoxSize.height

defaultBoxSize : BoxSize         
defaultBoxSize = BoxSize "1x" 210.0 50.0   

boxSizePallet : List BoxSize
boxSizePallet = [
                defaultBoxSize,
                {defaultBoxSize | title = "2x", height=defaultBoxSize.height + 20},
                {defaultBoxSize | title = "3x", height=defaultBoxSize.height + 40},
                {defaultBoxSize | title = "4x", height=defaultBoxSize.height + 60}
                ]

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
      }
    , Cmd.none
    )