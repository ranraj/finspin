module Config exposing (..)
import Math.Vector2 as Vector2 exposing (Vec2)
import Msg exposing (Msg(..))

defaultNewTilePosition : Vec2
defaultNewTilePosition = Vector2.vec2 10 10

tileDefaultColor = "#5F9A80"
colorPallet : List String
colorPallet = ["#c2d421","#91b1fd","#fdb9fd","#fec685",tileDefaultColor]

svgWrapper: String ->  String
svgWrapper board = 
    """
    <svg xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="0" width="100%" height="100%" fill="#5F9A80" stroke="#FFF"></rect>
    <rect></rect><text x="120" y="20" fill="white">Finspin Board - Beta</text>
    """      
    ++
    board
    ++
    "</svg>"

headerNoteHeight = 30

rndSeed = 23121