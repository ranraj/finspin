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
    | StopDragging
    | AddNote String String
    | CheckNote String
    | ClearNote String
    | ChangeTitle String
    | ChangeDesc String
    | StartNoteForm
    | CancelNoteForm
    | ReceivedBoard String
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
    | ContextMenuMsg (ContextMenu.Msg String)
    | SelectShape String BoxAction
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
    

type BoxAction
    = Open
    | Completed
    | Delete
    | New
    | DeleteAll
    | Share


type ContenxtMenuArea = MainSVG | BoxSVG

