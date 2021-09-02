port module Ports exposing (receiveData,storeNotes)


import Json.Encode as Encode

port storeNotes : Encode.Value -> Cmd msg
port receiveData : (String -> msg) -> Sub msg

