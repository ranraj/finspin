module BoardDecoder exposing (boxListDecoder)

import Json.Decode as JD exposing (Error(..), string,field,decodeString,bool,Decoder)
import Model exposing (Note,Box,BoxSize)
import Array
import Model exposing (Position)

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