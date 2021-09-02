module Config exposing (defaultNewTilePosition,boxSize)
import Types exposing (..)
import Math.Vector2 as Vector2 exposing (Vec2)

defaultNewTilePosition : Vec2
defaultNewTilePosition = Vector2.vec2 10 10

boxSize : Vec2
boxSize =
    Vector2.vec2 199 50

