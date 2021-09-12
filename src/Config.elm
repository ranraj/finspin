module Config exposing (defaultNewTilePosition,colorPallet,svgWrapper,headerNoteHeight)
import Math.Vector2 as Vector2 exposing (Vec2)
import Model exposing (Msg(..))

defaultNewTilePosition : Vec2
defaultNewTilePosition = Vector2.vec2 10 10


colorPallet : List String
colorPallet = ["#c2d421","#91b1fd","#fdb9fd","#fec685","#5F9A80"]

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