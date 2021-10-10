module Core exposing (..)

import Draggable
import Math.Vector2 as Vector2 exposing (Vec2)
import Tuple exposing (first,second)

import Model exposing (..)
import Config exposing (defaultNewTilePosition)
import ContextMenu exposing (ContextMenu)
import Dict exposing (Dict)
import Msg exposing (Color(..))
import UUID exposing (UUID,Representation(..))
import Strftime exposing (format)
import Random
import Config exposing (rndSeed)
import Random exposing (Seed, generate)
import Time
import Task

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


emptyBox : BoxInput
emptyBox = BoxInput "" defaultNewTilePosition emptyNote Nothing defaultBoxSize

buildBoxInput : Id -> Note -> Vec2 -> Maybe String -> BoxSize -> BoxInput
buildBoxInput id note position color size =
    BoxInput id position note color size

defaultBoxDisplay : BoxDisplay
defaultBoxDisplay = BoxDisplay False False
makeBox : BoxInput -> AuditInfo -> Box 
makeBox ({id,position,note,color,size}) auditInfo =
    Box id position False note color size defaultBoxDisplay auditInfo

getBox : BoxInput -> List Box -> Maybe Box
getBox ({id,position,note,color,size}) boxes = List.filter (\box -> box.id == id) boxes |> List.head

getBoxInput : Box -> BoxInput
getBoxInput ({id,position,note,color,size}) = BoxInput id position note color size 

-- makeBoxDefaultSize : Id -> Note -> Vec2 -> Maybe String -> Box 
-- makeBoxDefaultSize id note position color =
--     Box id position False note color defaultBoxSize False False

buidAudit : Time.Posix -> Time.Posix -> String -> String -> AuditInfo
buidAudit createdAt updatedAt createdBy updatedBy = AuditInfo createdAt updatedAt createdBy updatedBy

updateNoteBox : Model -> Box -> String -> String -> Box
updateNoteBox model box t d = 
    case model.currentBox of
        Just currentBox -> 
            if (box.id == currentBox.id) 
                then
                    let                        
                        newTitle = if String.isEmpty t then box.note.title else t
                        --newDescription = if String.isEmpty d then box.note.description else d
                        color = case currentBox.color of
                                    Just _ -> currentBox.color
                                    Nothing -> box.color
                        note = box.note             
                        newNote = {note | title = newTitle,description = d}
                    in    
                        { box | color = color, size = currentBox.size, note = newNote }
                else 
                    box
        Nothing -> box


rndUUID : Int -> String
rndUUID seedTime = Random.step UUID.generator (Random.initialSeed seedTime)
    |> Tuple.first
    |> UUID.toRepresentation Guid

-- TODO : Remove hardcode string
emptyGroup : BoxGroup
emptyGroup =
    BoxGroup "" "" Nothing []

buildBoxGroup : String -> String -> List Box -> BoxGroup 
buildBoxGroup uid name boxes = BoxGroup uid name Nothing boxes

emptyGroupWithId : Int -> String -> BoxGroup
emptyGroupWithId timeNow name =
    BoxGroup (rndUUID timeNow) name  Nothing []

buildNote : Int -> String -> String ->  Note
buildNote length t d  = { 
            id = ((String.fromInt length ++ String.slice 0 5 t))
            , done = False
            , title = t
            , description = d             
            }

-- addBoxInBoxGroup : Note -> Vec2 -> BoxGroup -> BoxGroup
-- addBoxInBoxGroup note position ({ uid, idleBoxes } as group) =
--     { group
--         | idleBoxes = (makeBox uid note position) Nothing defaultBoxSize :: idleBoxes
--         , uid = rndUUID
--     }    

-- makeBoxGroup : List (Vec2,Note) -> BoxGroup
-- makeBoxGroup positions =
--     positions
--         |>  List.foldl (\position -> addBoxInBoxGroup (second position) (first position)) emptyGroup

-- defaultBoxGroup : BoxGroup
-- defaultBoxGroup =
--     let
--         indexToPosition =
--             toFloat >> (*) 60 >> (+) 10 >> Vector2.vec2 10
--         notes = welcomeNotes
--     in
--     notes |> List.indexedMap (\i x -> ((indexToPosition i),x)) |> makeBoxGroup

getColor : Color -> String
getColor color = 
    case color of 
        BoardGreen -> "#5F9A80"
        White -> "#FFF" 


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

run : msg -> Cmd msg
run m =
    Task.perform (always m) (Task.succeed ())


searchBox : BoxGroup -> String -> BoxGroup
searchBox boxGroup keyword = 
        let
            search keyword_ = 
                    List.map 
                            (\box -> 
                                let
                                    display = box.display
                                in
                                if String.contains keyword_ (String.toLower box.note.title)  || String.contains keyword_ (String.toLower box.note.description) then
                                    {box | display = {display | foundInSearch = True}}
                                else 
                                    {box | display = {display | foundInSearch = False}}
                            ) 
                            boxGroup.idleBoxes
            searchResult_ = if String.isEmpty keyword  then 
                                boxGroup.idleBoxes 
                        else 
                                search (String.toLower keyword)
        in  
            {boxGroup | idleBoxes = searchResult_}


dateToString : Time.Posix -> String
dateToString date = format "%d-%b-%Y-%-I:%M" Time.utc date

cloneBox : Id -> Vec2 -> Box -> AuditInfo -> Box
cloneBox id position ({note, color, size}) audit = 
         makeBox (BoxInput id position note color size) audit
         