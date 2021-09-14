module View exposing (..)

import Svg exposing (Svg)
import Svg.Attributes as Attr
import Svg.Events as Events

import BoardTiles exposing (..)
import Html exposing (Html, button, text, div, li, ul, input, textarea, span)
import Html.Attributes exposing ( class, style, type_, placeholder, value,id,autofocus)
import Html.Events exposing (onInput, onClick,preventDefaultOn)
import FontAwesome.Attributes as Icon
import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Layering as Icon
import FontAwesome.Solid as Icon
import FontAwesome.Styles as Icon
import Json.Decode as Decode exposing (Error(..))

import File.Download as Download
import Task
import File exposing (File)

import BoardEncoder exposing (boxListEncoder)
import Model exposing (Model,Box,BoxGroup,ContenxtMenuArea(..))
import Msg exposing (Color(..),Msg,Msg(..),BoxAction(..))
import Core exposing (getColor,boxSizePallet)
import Config exposing (colorPallet,svgWrapper)
import Json.Encode as Encode
import Json.Decode as Decode
import ContextMenu exposing (ContextMenu,Item)
import Config exposing (tileDefaultColor)

boxesView : Model -> Svg Msg
boxesView model =
    model.boxGroup
        |> allBoxes
        |> List.reverse
        |> List.map (boxView model)
        |> Svg.node "g" [Attr.id "boxesView"]

downloadJson : String -> String -> Cmd msg
downloadJson content date =
  Download.string ("finspin-"++ date ++".json") "application/json" content

downloadSVG : String -> String -> Cmd msg
downloadSVG svgContent date =
  Download.string ("finspin-"++ date ++".svg") "image/svg" (svgContent |> svgWrapper)

read : File -> Cmd Msg
read file =
  Task.perform MarkdownLoaded (File.toString file)

-- Notes View Html --

addNotePanel : Box -> Bool -> Html Msg
addNotePanel box isEdit =
    let 
        note = box.note
    in    
        div [class "add-to-panel"]
            [ div [ class "li-header", autofocus True] [ viewInput "text" "Title" "form-input" note.title (ChangeTitle)]
            , div [ class "line-seperator"] []
            , div [] [ viewTextArea "Description" "form-input" note.description (ChangeDesc)]   
            , div [class "add-notes-ctrl"] 
                [
                button [ onClick ((if isEdit then UpdateNote else AddNote) note.title note.description), class "form-btn"] [text "Save"]
                ,button [ onClick CancelNoteForm, class "form-btn" ] [text "Clear"]            
                ] 
            , colorPickerView box  
            , titleSizePickerView      
            ]

colorPickerView : Box -> Html Msg
colorPickerView box = 
            let                
                colorPicker_ = 
                    List.map 
                    (\color -> 
                        div [] 
                            [
                            button [onClick (UpdateTitleColor color), class "color-picker", style "background-color" color]
                            []
                            ]
                         ) colorPallet    
                
                colorPicker = ( div [class "color-picker"] 
                            [
                            input
                                    [ 
                                    class "default-color-picker"                                       
                                    , type_ "color"
                                    , value (Maybe.withDefault tileDefaultColor box.color)                                            
                                    , onInput <| UpdateTitleColor
                                    ]
                                []
                            ])  :: colorPicker_                                                              
            in
                div [class "color-picker-holder"] colorPicker
                                              

titleSizePickerView : Html Msg
titleSizePickerView = 
            let                
                tileSizePicker = List.map (\tileSize -> div [] [button [onClick (UpdateBoxSize tileSize), class "tile-size-picker"] [text tileSize.title]]) boxSizePallet
            in
                div [class "tile-size-picker-holder"] tileSizePicker                                                      


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
    input [ class "add-note-text-input", type_ t, placeholder ph, class c, value v, onInput msg ] []

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
            [ Attr.id "svgBoard",
            Attr.x "0"
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
            , ContextMenu.open ContextMenuMsg "mainContextMenu"    
            ]
            
            [ Svg.rect [
                ]                
               []              
                , Svg.text_
                [ Attr.x "120"
                , Attr.y "20"
                , Attr.fill "white"                
                ]
                [ Svg.text "Finspin Board - Beta"
                ]
                , Svg.circle
                [ Attr.cx <| String.fromInt cx
                , Attr.cy <| String.fromInt cy
                , Attr.r <| String.fromInt radius
                , Attr.fill "white"
                , Attr.stroke "black"
                , Attr.strokeWidth "2"                
                ]
                []
                --, svgBoard 
                , boxesView model
            ]


view : Model -> Html Msg
view model =    
   div [class "content-container", id "contentContainer"] [
        svgBox model        
        ,div [class "content-controller"]
        [ Icon.css  
        --, div [class "content-controller-item", onClick (CheckNote model.currentBox.id)] 
        --[Icon.viewStyled [ Icon.sm, style "color" "gray" ] (if model.saveDefault then Icon.toggleOn else Icon.toggleOff)]        
        , span [class "content-controller-label"] [text "Add note"]                             
        , button 
            [ onClick (if model.isPopUpActive then CancelNoteForm else StartNoteForm)             
             ,class "content-controller-item"
             ] [ Icon.viewStyled [ Icon.fa2x ] Icon.plusCircle]
        , span [class "content-controller-label"] [text "Save"]             
        , button 
            [ onClick (SaveBoard)
             ,class "content-controller-item"
             ] [ Icon.viewStyled [ Icon.fa2x ] Icon.save]
        , span [class "content-controller-label"] [text "Auto Save"]        
        , button 
            [ onClick ToggleAutoSave             
             ,class "content-controller-item"
             ] [ Icon.viewStyled [ Icon.fa2x ] (if model.saveDefault then Icon.toggleOn else Icon.toggleOff)]     
        , span [class "content-controller-label"] [text "Export"]             
        , button 
            [ onClick <| InitDownloadSVG <| Encode.encode 5 <| boxListEncoder model.boxGroup.idleBoxes
             ,class "content-controller-item"
             ] [ Icon.viewStyled [ Icon.fa2x ] Icon.fileExport]            
        , span [class "content-controller-label"] [text "Import"]                    
        , viewFileUpload model     
        , (if model.isPopUpActive then viewNotePopupModal model else div [ style "hidden" "true" ] [])        
        , span [class "content-controller-label"] [text "Download Svg"]
        , button 
            [ onClick GetSvg
             ,class "content-controller-item"
             ] [ Icon.viewStyled [ Icon.fa2x ] Icon.download]                    
        --, getNotes model.boxGroup        //TODO : Move this in next page Bookmark
        , div
        [ ContextMenu.open ContextMenuMsg "mainContextMenu"]
        [ ContextMenu.view
            ContextMenu.defaultConfig
                ContextMenuMsg 
                boxContextMenuItems
                model.contextMenu
        ]        
        ]        
    ]

boxContextMenuItems : String -> List (List (Item,Msg))
boxContextMenuItems context =  
    if context == "mainContextMenu" then
        [[
         (ContextMenu.item "New Note", SelectShape context New)
        , (ContextMenu.item "Delete All", SelectShape context DeleteAll)
        , (ContextMenu.item "Share", SelectShape context Share)
        ]]
    else[ [ (ContextMenu.item "Open", SelectShape context Open)
        , (ContextMenu.item "Mark toggle", SelectShape context Completed)
        , (ContextMenu.item "Delete", SelectShape context Delete)        
        ]
        ] 
        
 
viewFileUpload : Model -> Html Msg    
viewFileUpload model = div
    [ class "file-upload-holder"
    ,class (if model.hover then "file-upload-holder-on" else "file-upload-holder-off")    
    , hijackOn "dragenter" (Decode.succeed DragEnter)
    , hijackOn "dragover" (Decode.succeed DragEnter)
    , hijackOn "dragleave" (Decode.succeed DragLeave)
    , hijackOn "drop" dropDecoder
    ]
    [ button [ onClick Pick , class "content-controller-item" ] [ Icon.viewStyled [ Icon.fa2x ] Icon.fileImport]             
    , span [ style "color" "#ccc" ] [if not (List.isEmpty model.files) then Icon.viewStyled [ Icon.sm, style "color" "green" ] Icon.check else text ""]
    ]               

dropDecoder : Decode.Decoder Msg
dropDecoder =
  Decode.at ["dataTransfer","files"] (Decode.oneOrMore GotFiles File.decoder)


hijackOn : String -> Decode.Decoder msg -> Html.Attribute msg
hijackOn event decoder =
  preventDefaultOn event (Decode.map hijack decoder)


hijack : msg -> (msg, Bool)
hijack msg =
  (msg, True)