module Config exposing (defaultNewTilePosition,boxSize,colorPallet)
import Types exposing (..)
import Math.Vector2 as Vector2 exposing (Vec2)

defaultNewTilePosition : Vec2
defaultNewTilePosition = Vector2.vec2 10 10

boxSize : Vec2
boxSize =
    Vector2.vec2 199 50

colorPallet : List String
colorPallet = ["#c2d421","#91b1fd","#fdb9fd","#fec685","#5F9A80"]