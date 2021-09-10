module BoardEncoder exposing (boxListEncoder)

import Json.Encode as Encode
import Math.Vector2 exposing ( getX, getY)
import Types exposing (Note,Box,BoxSize)

noteEncoder : Note -> Encode.Value
noteEncoder note = Encode.object
        [ ("id", Encode.string note.id)
        , ("done", Encode.bool note.done)
        , ("title", Encode.string note.title)
        , ("description", Encode.string note.description)           
        ]

boxSizeEncoder : BoxSize -> Encode.Value
boxSizeEncoder box = Encode.object
        [ ("title", Encode.string box.title)
        , ("width", Encode.float box.width)
        , ("height", Encode.float box.height)        
        ]

noteBoxEncoder : Box -> Encode.Value
noteBoxEncoder noteBox =
  let 
    positionStr = String.fromFloat (getX noteBox.position) ++ "," ++ String.fromFloat (getY noteBox.position)
  in
    Encode.object
        [ ("id", Encode.string noteBox.id)
        , ("position", Encode.string positionStr)
        , ("note", noteEncoder noteBox.note)
        , ("clicked", Encode.bool noteBox.clicked)        
        , ("color", noteBox.color|> Maybe.map Encode.string |> Maybe.withDefault Encode.null)
        , ("size", boxSizeEncoder noteBox.size)
        ]

boxListEncoder : List Box -> Encode.Value
boxListEncoder noteBoxes = Encode.list noteBoxEncoder noteBoxes