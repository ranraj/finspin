module BoardTiles exposing (boxView,startDragging,stopDragging,dragActiveBy,allBoxes,toggleBoxClicked,dragConfig)

import Svg exposing (Svg,text_)
import Svg exposing (Svg,text_)
import Svg.Attributes as Attr
import Svg.Events exposing (onMouseUp)
import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)
import ContextMenu
import Math.Vector2 as Vector2 exposing (Vec2,getX,getY)
import Html exposing (text)
import Model exposing (Model,Box,Id,BoxGroup)
import Msg exposing (Msg,Color(..), Msg(..),ContenxtMenuArea(..))
import Core exposing (getColor)
import Config exposing (headerNoteHeight)   

boxView : Model -> Box -> Svg Msg
boxView model { id, position, note,color,size}  =
    let
        newColor = case color of 
                    Just c -> c
                    Nothing -> getColor BoardGreen                
        isDone = if note.done then
                    "done"
                 else
                    ""                                     
        labelNote = if String.isEmpty note.description && (not (String.isEmpty note.title)) then True else False                     
                
        height_ = if labelNote then headerNoteHeight else size.height               
        svgNoteBox = Svg.rect
                [ convertToNum Attr.width <| size.width
                , convertToNum Attr.height <| height_
                , convertToNum Attr.x (getX position)
                , convertToNum Attr.y (getY position)
                , Attr.fill newColor
                , Attr.stroke (getColor White)
                , Attr.cursor "move"   
                , ContextMenu.open ContextMenuMsg id                
                ]
                []          
        svgTitle = text_
                [ convertToNum Attr.x ((getX (position)) + 20)
                , convertToNum Attr.y  ((getY (position)) + 20) 
                , Attr.stroke (getColor White)
                , Attr.fill (getColor White)
                , Attr.cursor "move"
                , Attr.class isDone             
                , ContextMenu.open ContextMenuMsg id
                ]
                [text (String.slice 0 20 note.title) ]
        svgDescription = text_
                [ convertToNum Attr.x ((getX (position)) + 20)
                , convertToNum Attr.y  ((getY (position)) + 35) 
                , Attr.stroke (getColor White)
                , Attr.fill (getColor White)
                , Attr.cursor "move" 
                , Attr.class isDone                   
                , ContextMenu.open ContextMenuMsg id
                ]
                [text (String.append (String.slice 0 20 note.description)  "...")]
        svgsBoxItems = if labelNote then [ svgNoteBox , svgTitle]  else [ svgNoteBox , svgTitle , svgDescription]        
    in
        Svg.svg
            [Draggable.mouseTrigger id DragMsg
                , onMouseUp StopDragging
                ] 
            svgsBoxItems



convertToNum : (String -> Svg.Attribute msg) -> Float -> Svg.Attribute msg
convertToNum attr value = attr (String.fromFloat value)

-- Drag functions starts --------------------------------
startDragging : Id -> BoxGroup -> BoxGroup
startDragging id ({ idleBoxes } as group) =
    let
        ( targetAsList, others ) =
            List.partition (.id >> (==) id) idleBoxes
    in
    { group
        | idleBoxes = others
        , movingBox = targetAsList |> List.head
    }


stopDragging : BoxGroup -> BoxGroup
stopDragging group =
    { group
        | idleBoxes = allBoxes Nothing group
        , movingBox = Nothing
    }
dragActiveBy : Vec2 -> BoxGroup -> BoxGroup
dragActiveBy delta group =
    { group | movingBox = group.movingBox |> Maybe.map (dragBoxBy delta) }

toggleClicked : Box -> Box
toggleClicked box =
    { box | clicked = not box.clicked }

toggleBoxClicked : Id -> BoxGroup -> BoxGroup
toggleBoxClicked id group =
    let
        possiblyToggleBox box =
            if box.id == id then
                toggleClicked box
            else
                box
    in
        { group | idleBoxes = group.idleBoxes |> List.map possiblyToggleBox }

dragConfig : Draggable.Config Id Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy (\( dx, dy ) -> Vector2.vec2 dx dy |> OnDragBy)
        , onDragStart StartDragging
        , Draggable.Events.onClick ViewNote
        ]

allBoxes : Maybe String -> BoxGroup -> List Box
allBoxes searchKey { movingBox, idleBoxes } =
    movingBox        
        |> Maybe.map (\a -> a :: idleBoxes)        
        |> Maybe.withDefault idleBoxes
        |> (\boxes -> if not (searchKey == Nothing) then List.filter (\box -> box.foundInSearch == True) boxes else boxes)

dragBoxBy : Vec2 -> Box -> Box
dragBoxBy delta box =
    { box | position = box.position |> Vector2.add delta }


-- Drag functions starts --------------------------------