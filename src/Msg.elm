module Msg exposing (..)

import Draggable
import Model exposing (..)
import Date exposing (Date)
import File exposing (File)

-------------------------------Message-----------------------------------
type Msg
    = DragMsg (Draggable.Msg Id)
    | OnDragBy Position
    | StartDragging String    
    | StopDragging
    | ViewNote String
    | AddNote String String
    | UpdateNote String String
    | CheckNote String
    | ClearNote String
    | ChangeTitle String
    | ChangeDesc String
    | StartNoteForm
    | CancelNoteForm
    | ReceivedDataFromJS String   
    | SaveBoard 
    | PointSelection Int Int
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