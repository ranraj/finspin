module BoardDecoder exposing (boxGroupDecoderString,boxListDecoderString,boxGroupsDecoderString)

import Json.Decode as JD exposing (Error(..), string,field,decodeString,bool,Decoder)
import Model exposing (Note,Box,BoxSize,BoxGroup)
import Tuple exposing (first,second)
import Math.Vector2 as Vector2
import Array
import Core exposing (emptyBox)
import Maybe exposing (withDefault)

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
    (field "id" JD.string)
    (field "done" JD.bool)
    (field "title" JD.string)
    (field "description" JD.string)
    


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
    (field "position" string |>  JD.map ( \pos -> positionDecoder pos |> (\vec -> Vector2.vec2 (first vec) (second vec))))
    (field "clicked" bool )
    (field "note" noteDecoder)
    (JD.maybe (field "color" string))
    (field "size" boxSizeDecoder)

boxListDecoder : Decoder (List Box)
boxListDecoder = JD.list boxDecoder 

boxListDecoderString : String -> List Box
boxListDecoderString value = 
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

boxGroupDecoderString : String -> Maybe BoxGroup
boxGroupDecoderString value = 
            let
              res = decodeString (field "idleBoxes" boxListDecoder) value              
              uidDecoder = (field "uid" string)
              
              uid = Result.withDefault "default_id" (decodeString uidDecoder value)
              boxGroup = case res of
                            Result.Ok data -> Just (Core.buildBoxGroup uid data)
                            Result.Err _ -> Nothing              
            in
              boxGroup

boxGroupDecoder : Decoder BoxGroup
boxGroupDecoder  = JD.map4 BoxGroup 
                  (field "uid" string) 
                  (JD.maybe (field "name" string)) 
                  (JD.maybe (field "movingBox" boxDecoder)) 
                  (field "idleBoxes" boxListDecoder) 
                                         
         
boxGroupsDecoder : Decoder (List BoxGroup)
boxGroupsDecoder = JD.list boxGroupDecoder

boxGroupsDecoderString : String -> List BoxGroup
boxGroupsDecoderString value = case (decodeString boxGroupsDecoder value) of
                                  Result.Ok data -> data
                                  Result.Err _ -> []            
        