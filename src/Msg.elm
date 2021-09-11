module Msg exposing (..)

import Draggable
import Model exposing (..)
import Date exposing (Date)
import File exposing (File)
import Json.Encode as Encode
import ContextMenu

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
    | NoOp
    | MouseMove Position
    | MouseDown Position
    | MouseUp Position
    | DeselectShape
    | SelectShape Int
    | AddShape Shape
    | SelectTool Tool
    | MouseSvgMove SvgPosition
    | BeginDrag DragAction
    | EndDrag
    | SelectedShapeAction ShapeAction
    | ReceiveShapes Encode.Value
    | RequestAuthentication
    --| ReceiveUser Encode.Value
    --| LogOut
    | BeginImageUpload SvgPosition
    | CancelImageUpload
    | StoreFile String
    | ReceiveFileStorageUpdate Encode.Value
    | ContextMenuMsg (ContextMenu.Msg Int)

-------------------------------Colour-----------------------------------
type Color = BoardGreen | White

-------------------------------Svg Shapes Action-----------------------------------
type ShapeAction
    = SendToBack
    | SendBackward
    | BringForward
    | BringToFront
    | UpdateText TextAction
    | UpdateRect RectAction


type TextAction
    = SetContent String

type RectAction
    = SetRectX Float
    | SetRectY Float
    | SetRectWidth Float
    | SetRectHeight Float
    | SetRectFill String
    | SetRectStroke String


type ModifyShapeMsg
    = IncreaseWidth Float

