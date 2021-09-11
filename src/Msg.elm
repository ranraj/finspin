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
    | NoOp
    | MouseMove Position
    | MouseDown Position
    | MouseUp Position

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

