port module Ports exposing (storeNotes,receiveData,getSvg,gotSvg,storeBoards,receiveBoards)

import Json.Encode as Encode

port storeNotes : Encode.Value -> Cmd msg
port receiveData : (String -> msg) -> Sub msg
port getSvg : String -> Cmd msg
port gotSvg : (String -> msg) -> Sub msg

port storeBoards : Encode.Value -> Cmd msg
port receiveBoards : (String -> msg) -> Sub msg