module BoardEncoder exposing (boxListEncoder,boxGroupEncoder,boxGroupsEncoder)

import Json.Encode as Encode
import Math.Vector2 exposing ( getX, getY)
import Model exposing (Note,Box,BoxSize,BoxGroup)
import Model exposing (AuditInfo)
import Time

noteEncoder : Note -> Encode.Value
noteEncoder note = Encode.object
        [ ("id", Encode.string note.id)
        , ("done", Encode.bool note.done)
        , ("title", Encode.string note.title)
        , ("description", Encode.string note.description)           
        ]
encodeTimePosix : Time.Posix -> Encode.Value
encodeTimePosix t =
    Encode.int (Time.posixToMillis t)

auditEncoder : AuditInfo -> Encode.Value
auditEncoder audit = Encode.object
        [ ("createdAt", encodeTimePosix audit.createdAt)
        , ("updatedAt", encodeTimePosix audit.updatedAt)
        , ("createdBy", Encode.string audit.createdBy)
        , ("updatedBy", Encode.string audit.updatedBy)           
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
        , ("audit", auditEncoder noteBox.audit)
        ]

boxListEncoder : List Box -> Encode.Value
boxListEncoder boxes = Encode.list noteBoxEncoder boxes

boxGroupEncoder : BoxGroup -> Encode.Value
boxGroupEncoder boxGroup = Encode.object
        [ ("uid", Encode.string boxGroup.uid)
        , ("name", Encode.string boxGroup.name)
        , ("idleBoxes", boxListEncoder boxGroup.idleBoxes)
        ]

boxGroupsEncoder : List BoxGroup -> Encode.Value
boxGroupsEncoder boxGroups = Encode.list boxGroupEncoder boxGroups
        