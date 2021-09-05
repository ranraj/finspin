module Main exposing (..)

import Browser
import Draggable
import Svg exposing (Svg)
import Svg.Attributes as Attr
import BoardTiles exposing (..)

import Html exposing (Html, button, text,p, div, h4, li, ul, input, i,textarea,header,section,footer)
import Html.Attributes exposing ( class, style, type_, placeholder, value,id,attribute)
import Html.Events exposing (onInput, onClick)
import FontAwesome.Attributes as Icon
import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Layering as Icon
import FontAwesome.Solid as Icon
import FontAwesome.Styles as Icon
import Json.Decode as Decode exposing (Error(..))
import Svg.Events as Events
import Svg.Attributes as Attributes
import Tuple exposing (first,second)
import Math.Vector2 as Vector2

import BoardDecoder exposing (boxListDecoder)
import BoardEncoder exposing (boxListEncoder)
import Ports
import Types exposing (Model,Box,BoxGroup,Note,Color(..),Msg(..))
import Types exposing (buildNote,makeBox,emptyNote,emptyGroup,getColor,emptyBox,updateNoteBox)
import Config exposing (colorPallet)

boxesView : BoxGroup -> Svg Msg
boxesView boxGroup =
    boxGroup
        |> allBoxes
        |> List.reverse
        |> List.map boxView
        |> Svg.node "g" []

-- TODO : SVG foreign object
svgTextarea model =
    let
        textspace =
            Svg.foreignObject
             [Attr.x "100"
             , Attr.y "100"]
             [ textarea [ style "position" "fixed"] [text "helloklskhkjdsf skdfhdskfhdskfhdkfhdsk fh"] ]
    in  
        textspace

-- Notes View Html --

addNotePanel : Box -> Bool -> Html Msg
addNotePanel box isEdit =
    let 
        note = box.note
    in    
        div [class "add-to-panel"]
            [ div [ class "li-header"] [ viewInput "text" "Title" "form-input" note.title (ChangeTitle)]
            , div [ class "line-seperator"] []
            , div [] [ viewTextArea "Description" "form-input" note.description (ChangeDesc)]   
            , div [class "add-notes-ctrl"] 
                [
                button [ onClick ((if isEdit then UpdateNote else AddNote) note.title note.description), class "form-btn"] [text "Save"]
                ,button [ onClick CancelNoteForm, class "form-btn" ] [text "Clear"]            
                ] 
            ,colorPickerView           
            ]

colorPickerView : Html Msg
colorPickerView = 
            let                
                colorPicker = List.map (\color -> div [] [button [onClick (UpdateTitleColor color), class "color-picker", style "background-color" color] [text ""]]) colorPallet
            in
                div [class "color-picker-holder"] colorPicker                                                      
viewNoteComponent : Box -> Html Msg
viewNoteComponent box =
    let
         td = box.note
         --_ = Debug.log (if (box.note.id == addNote.id) then "yes" else "")
    in
        li [ class (if td.done then "done list-item" else "list-item"), onClick (CheckNote td.id)
            ]
            [ Icon.viewStyled [ Icon.sm, style "color" "gray" ] (if td.done then Icon.checkSquare else Icon.square)            
            , div [ class "li-header" ] [ text td.title]
            -- , div [] [
            --     div [] [div [class "li-preview"] [text td.description]]
            --     ]                
            , div [ onClick (ClearNote td.id)] [ Icon.viewStyled [ Icon.sm, style "color" "gray" ] Icon.trash]
            ]

viewInput : String -> String -> String -> String -> (String -> Msg) -> Html Msg
viewInput t ph c v msg = 
    input [ type_ t, placeholder ph, class c, value v, onInput msg ] []

viewTextArea : String -> String -> String -> (String -> Msg) -> Html Msg
viewTextArea ph c v msg = 
    textarea [ placeholder ph, class c, value v, onInput msg ] []

viewNotePopupModal : Model -> Html Msg
viewNotePopupModal model =
        let
            note = model.currentBox.note 
        in              
            div [ class "modal-core" ]
            [                                                             
                div [class "status-icon-close", onClick (CancelNoteForm)] [Icon.viewStyled [ Icon.lg, style "color" "gray" ] Icon.timesCircle]                                                                      
                ,addNotePanel model.currentBox model.editNote
                ,div [class "notes-status-ctrl"] [
                    div [class "status-icon-check", onClick (CheckNote model.currentBox.id)] [Icon.viewStyled [ Icon.sm, style "color" "gray" ] (if note.done then Icon.checkSquare else Icon.square)]
                    , div [class "status-icon-trash", onClick (ClearNote model.currentBox.id)] [ Icon.viewStyled [ Icon.sm, style "color" "gray" ] Icon.trash]
                ]                                    
            ]       

getNotes : BoxGroup -> Html Msg
getNotes boxGroup =
    ul [ class "note-list", style "color" "black" ] (List.map viewNoteComponent boxGroup.idleBoxes)

svgBox : Model -> Svg Msg
svgBox model = 
    let 
        radius = 4
        ( x, y ) = model.position
        cx = x - radius // 2
        cy = y - radius // 2
    in
        Svg.svg
            [ Attr.x "0"
            , Attr.y "0"
            , Attr.width "100%"
            , Attr.height "100%"
            , Attr.fill (getColor BoardGreen)
            , Attr.class "svg-panel"        
            , Attr.class "content-display"   
            , Events.on "svgclick" 
                <| Decode.map2 Position
                (Decode.at ["detail", "x"] Decode.int)
                (Decode.at ["detail", "y"] Decode.int)
            ]
            
            [ Svg.rect [
                ]                
               []              
                , Svg.text_
                [ Attributes.x "120"
                , Attributes.y "20"
                , Attributes.fill "white"                
                ]
                [ Svg.text "Finspin Board"
                ]
                , Svg.circle
                [ Attributes.cx <| String.fromInt cx
                , Attributes.cy <| String.fromInt cy
                , Attributes.r <| String.fromInt radius
                , Attributes.fill "white"
                , Attributes.stroke "black"
                , Attributes.strokeWidth "2"
                ]
                []
                --, svgBoard 
                , boxesView (model.boxGroup)                     
            ]

-- Elm Architecture --
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \model -> Sub.batch [subscriptionsLocalStorage model,subscriptions model]
        , view = view
        }

init : flags -> ( Model, Cmd Msg )
init _ =
    ( { boxGroup = emptyGroup
      , drag = Draggable.init
      , isPopUpActive = False
      , editNote = False
      , currentBox = emptyBox
      , localData = []
      , jsonError = Nothing
      , welcomeTour = True
      , position =  (160, 120)
      }
    , Cmd.none
    )
         
view : Model -> Html Msg
view model =    
   div [class "content-container"] [
        svgBox model        
        ,div [class "content-controller"]
        [ Icon.css          
        , button 
            [ onClick (if model.isPopUpActive then CancelNoteForm else StartNoteForm)             
             ,class "content-controller-item"
             ] [ Icon.viewStyled [ Icon.fa2x ] Icon.plusCircle]
        , button 
            [ onClick (SaveBoard)
             ,class "content-controller-item"
             ] [ Icon.viewStyled [ Icon.fa2x ] Icon.save]
        , button 
            [ onClick (SaveBoard)
             ,class "content-controller-item"
             ] [ Icon.viewStyled [ Icon.fa2x ] Icon.pen]             
        , (if model.isPopUpActive then viewNotePopupModal model else div [ style "hidden" "true" ] [])        
        --, getNotes model.boxGroup        //TODO : Move this in next page Bookmark
        ]
    ]
    
               

update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ boxGroup } as model) =
    case msg of
        OnDragBy delta ->
            ( { model | boxGroup = boxGroup |> dragActiveBy delta }, Cmd.none )

        StartDragging id ->
                let
                   newBoxGroup = model.boxGroup |> startDragging  id
                   savePostsCmd = saveNotes newBoxGroup.idleBoxes  
                in 
                    ( { model | boxGroup = newBoxGroup }, savePostsCmd )

        StopDragging ->            
                let
                   newBoxGroup = model.boxGroup |> stopDragging 
                   savePostsCmd = saveNotes newBoxGroup.idleBoxes  
                in    
                    ({ model | boxGroup = newBoxGroup }, savePostsCmd )

        DragMsg dragMsg ->
            Draggable.update dragConfig dragMsg model

        AddNote t d ->                     
            let 
                currentBox = model.currentBox
                
                note  = buildNote (List.length model.boxGroup.idleBoxes) t d                             
                isEmpty = String.isEmpty t && String.isEmpty d
                savePostsCmd = if isEmpty then Cmd.none else saveNotes idleBoxes
                tilePosition = Vector2.vec2 (toFloat (first model.position)) (toFloat (second model.position))
                idleBoxes = 
                    if isEmpty then 
                        boxGroup.idleBoxes
                    else 
                        makeBox note.id note tilePosition currentBox.color:: boxGroup.idleBoxes
            in
                 ({ model | welcomeTour = False,currentBox = emptyBox,boxGroup = {boxGroup | idleBoxes = idleBoxes}}
                , savePostsCmd)  

        UpdateNote t d ->                     
            let                  
                edit = model.editNote                                
                isEmpty = String.isEmpty t && String.isEmpty d                

                newIdleBoxes = if edit && isEmpty then boxGroup.idleBoxes else List.map (\box -> updateNoteBox model box t d) boxGroup.idleBoxes                                                                                    
                savePostsCmd = if isEmpty then Cmd.none else saveNotes newIdleBoxes
                
            in
                 ({ model | editNote = False,boxGroup = { boxGroup | idleBoxes = newIdleBoxes}}
                , savePostsCmd)

        CheckNote i ->
            let
                newBoxGroup = {boxGroup | idleBoxes = 
                                List.map 
                                    (\box -> 
                                        if box.note.id == i
                                        then 
                                            { box | note = 
                                                    { id = box.note.id
                                                    , done = not box.note.done
                                                    , title = box.note.title
                                                    , description = box.note.description                                                    
                                                     }
                                            }
                                        else box) boxGroup.idleBoxes 
                    }
                savePostsCmd = saveNotes newBoxGroup.idleBoxes 
            in
            ({ model | boxGroup = newBoxGroup}, savePostsCmd)

        ClearNote i ->
            let
                idleBoxesFiltered = List.filter (\box -> box.note.id /= i) model.boxGroup.idleBoxes 
                savePostsCmd = saveNotes idleBoxesFiltered
            in
            ({ model | isPopUpActive = False, boxGroup = { boxGroup | idleBoxes = idleBoxesFiltered }}, savePostsCmd)

        StartNoteForm ->
            ({ model | isPopUpActive = True }, Cmd.none)
        
        CancelNoteForm ->
            ({ model | isPopUpActive = False,editNote=False, currentBox = emptyBox }, Cmd.none)
        
        ChangeTitle t ->
                let
                    box = model.currentBox
                    note = box.note                                        
                    newBox = {box | note = {note | title = t} }
                in    
                    ({ model | currentBox = newBox}, Cmd.none)
        ChangeDesc d ->
                let
                    box = model.currentBox
                    note = box.note                                        
                    newBox = {box | note = {note | description = d} }
                in
                ({ model | currentBox = newBox}, Cmd.none)
        ReceivedDataFromJS value ->              
            let                 
                localData = boxListDecoder value
                newBoxGroup = if List.isEmpty localData 
                                then boxGroup 
                                else {boxGroup | idleBoxes = localData}                                
            in    
             ( { model | localData = localData, boxGroup = newBoxGroup }, Cmd.none )

        ViewNote id -> let            
                            boxOpt = boxGroup.idleBoxes |> List.filter (\b -> b.id == id) |> List.head
                            viewBox = case boxOpt of
                                        Just b -> b
                                        Nothing -> emptyBox
                        in    
                            ( {model | isPopUpActive = True,currentBox = viewBox, editNote = True} , Cmd.none)
        SaveBoard -> (model,saveNotes model.boxGroup.idleBoxes)
        Position x y -> ({ model | position = (x, y) },Cmd.none)
        UpdateTitleColor tileColor -> 
                        let
                            box = model.currentBox
                            note = box.note                                                                                    
                            newBox = {box | color = Just tileColor}                            
                        in
                            ({model | currentBox = newBox} , Cmd.none)
            
subscriptions : Model -> Sub Msg
subscriptions { drag } = 
    Draggable.subscriptions DragMsg drag

------- Local Stroage --------------------------------
saveNotes : List Box -> Cmd msg
saveNotes noteBoxes = boxListEncoder noteBoxes |> Ports.storeNotes            

subscriptionsLocalStorage : Model -> Sub Msg
subscriptionsLocalStorage _ = 
        Ports.receiveData ReceivedDataFromJS    
