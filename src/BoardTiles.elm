module BoardTiles exposing (..)

import Svg exposing (Svg,rect,circle,svg,style,text_,clipPath,view)
import Svg.Attributes exposing (width,height,x,y,viewBox,r,cy,cx,ry,rx,fill,dy,dx,fontSize,pointerEvents,stroke)
import Types exposing (..)
import Tuple exposing (first,second)
import Svg exposing (Svg,text_)
import Svg.Attributes as Attr
import Svg.Events exposing (onMouseUp)
import Svg.Keyed
import Svg.Lazy exposing (lazy)
import Html exposing (Html, button, text, div, h1, img, li, ul, input, i,textarea)
import Html.Attributes exposing ( class, src, style, type_, placeholder, value, checked)
import Math.Vector2 as Vector2 exposing (Vec2, getX, getY)
import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)

boxSize : Vec2
boxSize =
    Vector2.vec2 199 50

num : (String -> Svg.Attribute msg) -> Float -> Svg.Attribute msg
num attr value =
    attr (String.fromFloat value)

boxView : Box -> Svg Msg
boxView { id, position, clicked,note } =
    let
        color =
            if clicked then
                "gray"
            else
                getColor BoardGreen
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
        [ num Attr.width <| getX boxSize
        , num Attr.height <| getY boxSize
        , num Attr.x (getX position)
        , num Attr.y (getY position)
        , Attr.fill color
        , Attr.stroke (getColor White)
        , Attr.cursor "move"
        ]
        []
        ,text_
        [ num Attr.x ((getX (position)) + 20)
        , num Attr.y  ((getY (position)) + 20) 
        , Attr.stroke (getColor White)
        , Attr.fill (getColor White)
        , Attr.cursor "move"
        , Attr.class isDone             
        ]
        [text (String.slice 0 20 note.title) ]
        ,text_
        [ num Attr.x ((getX (position)) + 20)
        , num Attr.y  ((getY (position)) + 35) 
        , Attr.stroke (getColor White)
        , Attr.fill (getColor White)
        , Attr.cursor "move" 
        , Attr.class isDone                           
        ]
        [text (String.append (String.slice 0 20 note.description)  "...")    ]        
    ]

-- Drag functions starts --------------------------------
startDragging : Id -> BoxGroup -> BoxGroup
startDragging id ({ idleBoxes, movingBox } as group) =
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
        , Draggable.Events.onClick ToggleBoxClicked
        ]

allBoxes : BoxGroup -> List Box
allBoxes { movingBox, idleBoxes } =
    movingBox
        |> Maybe.map (\a -> a :: idleBoxes)
        |> Maybe.withDefault idleBoxes

dragBoxBy : Vec2 -> Box -> Box
dragBoxBy delta box =
    { box | position = box.position |> Vector2.add delta }


toggleClicked : Box -> Box
toggleClicked box =
    { box | clicked = not box.clicked }

-- Drag functions starts --------------------------------