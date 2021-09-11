port module Ports exposing (..)

import Json.Encode as Encode exposing (Value)
import Model exposing (SvgPosition)

port storeNotes : Encode.Value -> Cmd msg
port receiveData : (String -> msg) -> Sub msg
port getSvg : String -> Cmd msg
port gotSvg : (String -> msg) -> Sub msg
port receiveSvgMouseCoordinates : (SvgPosition -> msg) -> Sub msg


port receiveShapes : (Value -> msg) -> Sub msg


port receiveUser : (Value -> msg) -> Sub msg


port receiveFileStorageUpdate : (Value -> msg) -> Sub msg

-- OUTBOUND PORTS


port persistShapes : Value -> Cmd msg


port requestAuthentication : () -> Cmd msg


port logOut : () -> Cmd msg


port storeFile : String -> Cmd msg