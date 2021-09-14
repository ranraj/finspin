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
import Random
import Config exposing (rndSeed)

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


emptyBox : Box
emptyBox = Box "" defaultNewTilePosition False emptyNote Nothing defaultBoxSize

makeBox : Id -> Note -> Vec2 -> Maybe String -> BoxSize -> Box 
makeBox id note position color size =
    Box id position False note color size


makeBoxDefaultSize : Id -> Note -> Vec2 -> Maybe String -> Box 
makeBoxDefaultSize id note position color =
    Box id position False note color defaultBoxSize

updateNoteBox : Model -> Box -> String -> String -> Box
updateNoteBox model box t d = if (box.id == model.currentBox.id) then
                                        let
                                            currentBox = model.currentBox
                                            newTitle = if String.isEmpty t then box.note.title else t
                                            newDescription = if String.isEmpty d then box.note.description else d
                                            color = case currentBox.color of
                                                        Just _ -> currentBox.color
                                                        Nothing -> box.color
                                            note = box.note             
                                            newNote = {note | title = newTitle,description = newDescription}
                                        in    
                                            {box | color = color, size = currentBox.size, note = newNote}
                                    else 
                                        box


rndUUID : String
rndUUID = Random.step UUID.generator (Random.initialSeed Config.rndSeed)
            |> Tuple.first
            |> UUID.toRepresentation Guid

emptyGroup : BoxGroup
emptyGroup =
    BoxGroup rndUUID Nothing []

buildNote : Int -> String -> String ->  Note
buildNote length t d  = { 
            id = ((String.fromInt length ++ String.slice 0 5 t))
            , done = False
            , title = t
            , description = d             
            }

addBoxInBoxGroup : Note -> Vec2 -> BoxGroup -> BoxGroup
addBoxInBoxGroup note position ({ uid, idleBoxes } as group) =
    { group
        | idleBoxes = (makeBox uid note position) Nothing defaultBoxSize :: idleBoxes
        , uid = rndUUID
    }    

makeBoxGroup : List (Vec2,Note) -> BoxGroup
makeBoxGroup positions =
    positions
        |>  List.foldl (\position -> addBoxInBoxGroup (second position) (first position)) emptyGroup

defaultBoxGroup : BoxGroup
defaultBoxGroup =
    let
        indexToPosition =
            toFloat >> (*) 60 >> (+) 10 >> Vector2.vec2 10
        notes = welcomeNotes
    in
    notes |> List.indexedMap (\i x -> ((indexToPosition i),x)) |> makeBoxGroup

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

