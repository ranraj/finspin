port module Ports exposing (receiveData,storeNotes,getSvg,gotSvg)


import Json.Encode as Encode

port storeNotes : Encode.Value -> Cmd msg
port receiveData : (String -> msg) -> Sub msg

port getSvg : String -> Cmd msg
port gotSvg : (String -> msg) -> Sub msg