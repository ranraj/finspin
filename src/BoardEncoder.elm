module BoardEncoder exposing (boxListEncoder,shapesEncoder)

import Json.Encode as Encode exposing (..)

import Model exposing (Note,Box,BoxSize,Shape(..))
import Dict exposing (Dict)
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
    position = noteBox.position
    positionStr = String.fromFloat (position.x) ++ "," ++ String.fromFloat (position.y)
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

shapesEncoder : Dict Int Shape -> Encode.Value
shapesEncoder shapes =
    dictEncoder shapeEncoder shapes

dictEncoder : (a -> Encode.Value) -> Dict Int a -> Encode.Value
dictEncoder enc dict =
    Dict.toList dict
        |> List.map (\( k, v ) -> ( String.fromInt k, enc v ))
        |> (::) ( "ignoreme", bool False )
        |> object


shapeEncoder : Shape -> Encode.Value
shapeEncoder shape =
    case shape of
        Rect rectModel ->
            object <|
                [ ( "type", string "rect" )
                , ( "x", float rectModel.x )
                , ( "y", float rectModel.y )
                , ( "width", float rectModel.width )
                , ( "height", float rectModel.height )
                , ( "stroke", string rectModel.stroke )
                , ( "strokeWidth", float rectModel.strokeWidth )
                , ( "fill", string rectModel.fill )
                ]

        Circle circleModel ->
            object <|
                [ ( "type", string "circle" )
                , ( "cx", float circleModel.cx )
                , ( "cy", float circleModel.cy )
                , ( "r", float circleModel.r )
                , ( "stroke", string circleModel.stroke )
                , ( "strokeWidth", float circleModel.strokeWidth )
                , ( "fill", string circleModel.fill )
                ]

        Text textModel ->
            object <|
                [ ( "type", string "text" )
                , ( "x", float textModel.x )
                , ( "y", float textModel.y )
                , ( "content", string textModel.content )
                , ( "fontFamily", string textModel.fontFamily )
                , ( "fontSize", int textModel.fontSize )
                , ( "stroke", string textModel.stroke )
                , ( "strokeWidth", float textModel.strokeWidth )
                , ( "fill", string textModel.fill )
                ]

        Image imageModel ->
            object <|
                [ ( "type", string "image" )
                , ( "x", float imageModel.x )
                , ( "y", float imageModel.y )
                , ( "width", float imageModel.width )
                , ( "height", float imageModel.height )
                , ( "href", string imageModel.href )
                ]
