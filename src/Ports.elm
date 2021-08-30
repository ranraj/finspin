port module Ports exposing (receiveData,storeNotes)

import Types exposing (Box,Model)
import Json.Encode as E exposing (Value, int, object, string)

port storeNotes : Value -> Cmd msg
port receiveData : (String -> msg) -> Sub msg

