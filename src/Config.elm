module Config exposing (welcomeNotes,defaultNewTilePosition)
import Types exposing (..)
import Math.Vector2 as Vector2 exposing (Vec2)

defaultNewTilePosition : Vec2
defaultNewTilePosition = Vector2.vec2 10 10

welcomeNotes : List Note
welcomeNotes =  
    [
        { id = "0 - learn"
        , title = "You completed a Task"
        , description = "Simply click on the message to strick  out "
        , done = True
        }
    ,   { id = "1 - start"
        , title = "Welcome to the Finspin"
        , description = "Easy planner board"
        , done = False                  
        }
    ]