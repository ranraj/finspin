module BoardTiles exposing (boxView,startDragging,stopDragging,dragActiveBy,allBoxes,dragConfig)

import Svg exposing (Svg,text_)
import Svg.Attributes exposing (dy,dx)
import Svg exposing (Svg,text_)
import Svg.Attributes as Attr
import Svg.Events exposing (onMouseUp)
import Html exposing (text)
import Html.Attributes exposing (value)
import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)

import Model exposing (Box,Id,BoxGroup)
import Msg exposing (Color(..), Msg(..))
import Model exposing (Position)
import Core exposing (getColor,addPosition)

boxView : Box -> Svg Msg
boxView { id, position, note,color,size} =
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
                [ convertToNum Attr.width <| size.width
                , convertToNum Attr.height <| size.height
                , convertToNum Attr.x (position.x)
                , convertToNum Attr.y (position.y)
                , Attr.fill newColor
                , Attr.stroke (getColor White)
                , Attr.cursor "move"                
                ]
                []
                ,text_
                [ convertToNum Attr.x ((position.x) + 20)
                , convertToNum Attr.y  ((position.y) + 20) 
                , Attr.stroke (getColor White)
                , Attr.fill (getColor White)
                , Attr.cursor "move"
                , Attr.class isDone             
                
                ]
                [text (String.slice 0 20 note.title) ]
                ,text_
                [ convertToNum Attr.x ((position.x) + 20)
                , convertToNum Attr.y ((position.y) + 35) 
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
dragActiveBy : Position -> BoxGroup -> BoxGroup
dragActiveBy delta group =
    { group | movingBox = group.movingBox |> Maybe.map (dragBoxBy delta) }


dragConfig : Draggable.Config Id Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy (\( dx, dy ) -> Position dx dy |> OnDragBy)
        , onDragStart StartDragging
        , Draggable.Events.onClick ViewNote
        ]

allBoxes : BoxGroup -> List Box
allBoxes { movingBox, idleBoxes } =
    movingBox
        |> Maybe.map (\a -> a :: idleBoxes)
        |> Maybe.withDefault idleBoxes

dragBoxBy : Position -> Box -> Box
dragBoxBy delta box =
    { box | position = box.position |> addPosition delta }
