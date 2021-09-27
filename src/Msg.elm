module Msg exposing (..)

import Math.Vector2 exposing (Vec2)
import Draggable
import Json.Decode exposing (Error(..))
import File exposing (File)
import Date exposing (Date)
import Model exposing (Id,BoxSize)
import ContextMenu
import Time
import Bootstrap.Navbar as Navbar

-------------------------------Colour-----------------------------------
type Color = BoardGreen | White

-------------------------------Message-----------------------------------
type Msg
    = NoOp
    | DragMsg (Draggable.Msg Id)
    | OnDragBy Vec2
    | StartDragging String    
    | ViewNote String
    | DuplicateNote String
    | StopDragging
    | AddNote String String
    | CheckNote String
    | DeleteNote String
    | ChangeTitle String
    | ChangeDesc String
    | StartNoteForm
    | CancelNoteForm
    | ReceivedBoard String
    | UpdateNote String String
    | SaveBoard 
    | SetPosition Int Int
    | UpdateTitleColor String
    | ExportBoard String String    
    | Pick
    | DragEnter
    | DragLeave
    | ImportBoard File (List File)  
    | LoadImportedBoard String
    | ToggleAutoSave
    | UpdateBoxSize BoxSize
    | GetSvg
    | GotSvg String
    | ContextMenuMsg (ContextMenu.Msg String)
    | ContextAction String BoxAction
    | NewBoardGen Time.Posix
    | NewBoard 
    | LoadSelectedBoard String
    | ReceivedBoards String
    | CurrentDateTime 
    | CaptureDateTime Time.Posix
    | NavbarMsg Navbar.State
    | MenuHoverIn String
    | MenuHoverOut 
    | EditBoardTitle String
    | BoardTitleChange String
    | SaveBoardTitleChange
    | RemoveBoard String
    | Search String
    | SearchKeywordChange String
    | SearchClear
    | UndoAction
    

type BoxAction
    = Open
    | Completed
    | Duplicate
    | Delete
    | New
    | DeleteAll
    | Share
    | Undo


type ContenxtMenuArea = MainSVG | BoxSVG

