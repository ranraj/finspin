module BoardDecoder exposing (boxListDecoder,shapesDecoder,uploadDecoder)

import Json.Decode as JD exposing (Error(..), string,field,decodeString,bool,Decoder,andThen,float,int)
import Json.Decode.Pipeline
    exposing
        ( required
        , custom
        )
import Model exposing (..)
import Array
import Model exposing (Position)
import Dict exposing (Dict)
notePositionDecoder : Maybe Float -> Maybe Float -> Position
notePositionDecoder x y = 
        let         
            xFloat = case x of
                Just a -> a
                _ -> 0
            yFloat = case y of
                Just a -> a
                _ -> 0        
        in
            Position xFloat yFloat

noteDecoder : Decoder Note
noteDecoder =
  JD.map4 Note
    (field "id" JD.string)
    (field "done" JD.bool)
    (field "title" JD.string)
    (field "description" JD.string)
    


positionDecoder : String -> Position
positionDecoder pos = 
        let
            posSplit = Array.fromList (String.split "," pos)
            x = case (Array.get 0 posSplit) of
                Just a -> String.toFloat a
                _ -> Nothing
            y = case (Array.get 1 posSplit) of
                Just a -> String.toFloat a
                _ -> Nothing
        in
           notePositionDecoder  x y

boxSizeDecoder : Decoder BoxSize
boxSizeDecoder =
  JD.map3 BoxSize
    (field "title" JD.string)
    (field "width" JD.float)
    (field "height" JD.float)    

boxDecoder:  Decoder Box
boxDecoder =
  JD.map6 Box
    (field "id" string)
    (field "position" string |>  JD.map ( \pos -> positionDecoder pos |> (\position -> Position position.x position.y)))
    (field "clicked" bool )
    (field "note" noteDecoder)
    (JD.maybe (field "color" string))
    (field "size" boxSizeDecoder)

boxListDecoder : String -> List Box
boxListDecoder value = 
  let
    res =  decodeString (JD.list boxDecoder) value    
    
  in
    case res of
        Result.Ok data -> data
        Result.Err e -> 
            let        
               --_ = Debug.log "BoxList Decoder" e        
               emptyArray = []
            in
                emptyArray

shapesDecoder : Decoder (Dict Int Shape)
shapesDecoder =
    JD.dict shapeDecoder
        |> JD.map parseIntKeys


parseIntKeys : Dict String Shape -> Dict Int Shape
parseIntKeys stringShapes =
    stringShapes
        |> Dict.toList
        |> List.map
            (\( k, v ) ->
                ( k |> String.toInt |> (\a -> 
                    case a of 
                      Just d -> d 
                      Nothing -> 0
                    )
                , v
                )
            )
        |> Dict.fromList


shapeDecoder : Decoder Shape
shapeDecoder =
    field "type" string
        |> andThen specificShapeDecoder


specificShapeDecoder : String -> Decoder Shape
specificShapeDecoder typeStr =
    case typeStr of
        "rect" ->
            JD.succeed Rect
                |> custom rectModelDecoder

        "circle" ->
            JD.succeed Circle
                |> custom circleModelDecoder

        "text" ->
            JD.succeed Text
                |> custom textModelDecoder

        "image" ->
            JD.succeed Image
                |> custom imageModelDecoder

        _ ->
            JD.fail "unknown shape type"


imageModelDecoder : Decoder ImageModel
imageModelDecoder =
    JD.succeed ImageModel
        |> required "x" float
        |> required "y" float
        |> required "width" float
        |> required "height" float
        |> required "href" string


rectModelDecoder : Decoder RectModel
rectModelDecoder =
    JD.succeed RectModel
        |> required "x" float
        |> required "y" float
        |> required "width" float
        |> required "height" float
        |> required "stroke" string
        |> required "strokeWidth" float
        |> required "fill" string


circleModelDecoder : Decoder CircleModel
circleModelDecoder =
    JD.succeed CircleModel
        |> required "cx" float
        |> required "cy" float
        |> required "r" float
        |> required "stroke" string
        |> required "strokeWidth" float
        |> required "fill" string


textModelDecoder : Decoder TextModel
textModelDecoder =
    JD.succeed TextModel
        |> required "x" float
        |> required "y" float
        |> required "content" string
        |> required "fontFamily" string
        |> required "fontSize" int
        |> required "stroke" string
        |> required "strokeWidth" float
        |> required "fill" string


userDecoder : Decoder User
userDecoder =
    JD.succeed User
        |> required "displayName" string
        |> required "email" string
        |> required "photoURL" string


uploadDecoder : Decoder Upload
uploadDecoder =
    -- We'll use `oneOf`, which will try different decoders until it finds a
    -- successful decoder.
    JD.oneOf <|
        -- Then we'll look at each possible shape and decode them appropriately
        [ field "running" <| JD.map Running float
        , field "error" <| JD.map Errored string
        , field "paused" <| JD.map Paused float
        , field "complete" <| JD.map Completed string
        ]
