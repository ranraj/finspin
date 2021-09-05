module BoardDecoder exposing (boxListDecoder)

import Json.Decode as JD exposing (Error(..), string,field,decodeString,bool,Decoder)
import Types exposing (Note,Box)
import Tuple exposing (first,second)
import Math.Vector2 as Vector2
import Array

notePositionDecoder : Maybe Float -> Maybe Float -> (Float, Float)
notePositionDecoder x y = 
        let         
            xFloat = case x of
                Just a -> a
                _ -> 0
            yFloat = case y of
                Just a -> a
                _ -> 0        
        in
            (xFloat,yFloat)    

noteDecoder : Decoder Note
noteDecoder =
  JD.map4 Note
    (field "id" string)
    (field "done" bool)
    (field "title" string)
    (field "description" string)
    


positionDecoder : String -> (Float, Float)
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
        
boxDecoder:  Decoder Box
boxDecoder =
  JD.map5 Box
    (field "id" string)
    (field "position" string |>  JD.map ( \pos -> positionDecoder pos |> (\vec -> Vector2.vec2 (first vec) (second vec))))
    (field "clicked" bool )
    (field "note" noteDecoder)
    (JD.maybe (field "color" string))

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