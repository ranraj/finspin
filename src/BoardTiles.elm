module BoardTiles exposing (boxView,startDragging,stopDragging,dragActiveBy,allBoxes,toggleBoxClicked,dragConfig)

import Svg exposing (Svg,text_)
import Svg.Attributes exposing (dy,dx)
import Svg exposing (Svg,text_)
import Svg.Attributes as Attr
import Svg.Events exposing (onMouseUp)
import Html exposing (text)
import Html.Attributes exposing (value)
import Math.Vector2 as Vector2 exposing (Vec2, getX, getY)
import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)

import Types exposing (Box,Msg,getColor,Color(..), Msg(..),Id,BoxGroup)
import Config exposing (boxSize)

boxView : Box -> Svg Msg
boxView { id, position, clicked,note,color} =
    let
        newColor = case color of 
                    Just c -> c
                    Nothing -> getColor BoardGreen                
        isDone = if note.done then
                    "done"
                 else
                    ""                             
    in
        Svg.svg
            [Draggable.mouseTrigger id DragMsg
                , onMouseUp StopDragging
                ] 
            [
                Svg.rect
                [ convertToNum Attr.width <| getX boxSize
                , convertToNum Attr.height <| getY boxSize
                , convertToNum Attr.x (getX position)
                , convertToNum Attr.y (getY position)
                , Attr.fill newColor
                , Attr.stroke (getColor White)
                , Attr.cursor "move"                
                ]
                []
                ,text_
                [ convertToNum Attr.x ((getX (position)) + 20)
                , convertToNum Attr.y  ((getY (position)) + 20) 
                , Attr.stroke (getColor White)
                , Attr.fill (getColor White)
                , Attr.cursor "move"
                , Attr.class isDone             
                
                ]
                [text (String.slice 0 20 note.title) ]
                ,text_
                [ convertToNum Attr.x ((getX (position)) + 20)
                , convertToNum Attr.y  ((getY (position)) + 35) 
                , Attr.stroke (getColor White)
                , Attr.fill (getColor White)
                , Attr.cursor "move" 
                , Attr.class isDone                   
                        
                ]
                [text (String.append (String.slice 0 20 note.description)  "...")    ]        
            ]


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
        | idleBoxes = allBoxes group
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

allBoxes : BoxGroup -> List Box
allBoxes { movingBox, idleBoxes } =
    movingBox
        |> Maybe.map (\a -> a :: idleBoxes)
        |> Maybe.withDefault idleBoxes

dragBoxBy : Vec2 -> Box -> Box
dragBoxBy delta box =
    { box | position = box.position |> Vector2.add delta }


-- Drag functions starts --------------------------------