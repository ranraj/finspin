module View exposing (..)

import Svg exposing (Svg)
import Svg.Attributes as Attr
import Svg.Events as Events

import BoardTiles exposing (..)
import Html exposing (Html, button, text, div, li, ul, input, textarea, span,form)
import Html.Attributes exposing ( class, style, type_, placeholder, value,id,autofocus,href)
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

import BoardEncoder exposing (boxGroupEncoder)
import Model exposing (Model,Box,BoxGroup)
import Msg exposing (Color(..),Msg,Msg(..),BoxAction(..),ContenxtMenuArea(..))
import Core exposing (getColor,boxSizePallet)
import Config exposing (colorPallet,svgWrapper)
import Json.Encode as Encode
import Json.Decode as Decode
import Config exposing (tileDefaultColor)
import Bootstrap.Navbar as Navbar exposing (DropdownToggle,DropdownItem)
import ContextMenu exposing (ContextMenu,Item)
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Html.Events exposing (onMouseOver)
import Html.Events exposing (onMouseLeave)


boxesView : Model -> Svg Msg
boxesView model =
    model.boxGroup
        |> allBoxes model.searchKeyword
        |> List.reverse        
        |> List.map (boxView model)
        |> Svg.node "g" [Attr.id "boxesView"]

downloadJson : String -> String -> Cmd msg
downloadJson content boardName =
  Download.string ("finspin-"++ boardName ++".json") "application/json" content

downloadSVG : String -> String -> Cmd msg
downloadSVG svgContent boardName =
  Download.string ("finspin-"++ boardName ++".svg") "image/svg" (svgContent |> svgWrapper)

readImportedBoard : File -> Cmd Msg
readImportedBoard file =
  Task.perform LoadImportedBoard (File.toString file)

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
    in
        li [ class (if td.done then "done list-item" else "list-item"), onClick (CheckNote td.id)
            ]
            [ Icon.viewStyled [ Icon.sm, style "color" "gray" ] (if td.done then Icon.checkSquare else Icon.square)            
            , div [ class "li-header" ] [ text td.title]
            -- , div [] [
            --     div [] [div [class "li-preview"] [text td.description]]
            --     ]                
            , div [ onClick (DeleteNote td.id)] [ Icon.viewStyled [ Icon.sm, style "color" "gray" ] Icon.trash]
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
                    , div [class "status-icon-trash", onClick (DeleteNote model.currentBox.id)] [ Icon.viewStyled [ Icon.sm, style "color" "gray" ] Icon.trash]
                ]                                    
            ]       

getNotes : BoxGroup -> Html Msg
getNotes boxGroup =
    ul [ class "note-list", style "color" "black" ] (List.map viewNoteComponent boxGroup.idleBoxes)

svgBox : Model -> Svg Msg
svgBox model = 
    let 
        radius = 4
        ( x, y ) = (model.position.x,model.position.y)
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
            -- , Events.on "svgclick" 
            --     <| Decode.map2 Position
            --     (Decode.at ["detail", "x"] Decode.int)
            --     (Decode.at ["detail", "y"] Decode.int)
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
        div [class "content-main"] [
            viewGrid model
            ,div [class "svg-board-container"] [
                svgBox model                
                ]             
            ]        
            ,viewController model
            
    ]

viewController : Model -> Html Msg
viewController model = 
        div [class "content-controller"]
            [ Icon.css  
            --, div [class "content-controller-item", onClick (CheckNote model.currentBox.id)] 
            --[Icon.viewStyled [ Icon.sm, style "color" "gray" ] (if model.saveDefault then Icon.toggleOn else Icon.toggleOff)]        
            , span [class "content-controller-label"] [text "Add Board"]                             
            , button 
                [ onClick (NewBoard)             
                ,class "content-controller-item"
                ] [ Icon.viewStyled [ Icon.fa2x ] Icon.folderPlus]
            , span [class "content-controller-label"] [text "Add Note"]                             
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
                [ onClick ((ExportBoard <| Encode.encode 5 <| boxGroupEncoder model.boxGroup) model.boxGroup.name)
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
boxContextMenuItems : String -> List (List (Item,Msg))
boxContextMenuItems context =  
    if context == "mainContextMenu" then
        [[
         (ContextMenu.item "New Note", ContextAction context New)
        , (ContextMenu.item "Undo", ContextAction context Undo)
        , (ContextMenu.item "Delete All", ContextAction context DeleteAll)
        , (ContextMenu.item "Share", ContextAction context Share)
        ]]
    else[ [ (ContextMenu.item "Open", ContextAction context Open)
        , (ContextMenu.item "Mark toggle", ContextAction context Completed)
        , (ContextMenu.item "Delete", ContextAction context Delete)        
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
  Decode.at ["dataTransfer","files"] (Decode.oneOrMore ImportBoard File.decoder)


hijackOn : String -> Decode.Decoder msg -> Html.Attribute msg
hijackOn event decoder =
  preventDefaultOn event (Decode.map hijack decoder)


hijack : msg -> (msg, Bool)
hijack msg =
  (msg, True)

viewNavBarControl : Maybe String -> Maybe String -> String -> String -> List (Html Msg)
viewNavBarControl titleEdit hoverMenu uid name = 
            let        
                penHolder = div [class "nav-bar-item-pen"][]        
                label = 
                    [
                        div [class "nav-bar-item-text"] 
                        [
                            text (String.slice 0 10 name)                        
                        ]
                        ,hoverPen
                        ,hoverTimes
                    ]    

                hoverItem : Html Msg -> Html Msg
                hoverItem  hoverControl = case hoverMenu of
                                Just hoverId ->  
                                    if hoverId == uid then                                        
                                        hoverControl
                                    else    
                                        penHolder
                                Nothing -> penHolder                   
                hoverPen = hoverItem (div [class "nav-bar-item-pen", onClick (EditBoardTitle uid)] [Icon.viewStyled [ Icon.sm ] Icon.pen])                                                                                        
                                 
                hoverTimes =  hoverItem (div [class "nav-bar-item-pen", onClick (RemoveBoard uid)] [Icon.viewStyled [ Icon.sm ] Icon.times])                                                
                                             
            in
                case titleEdit of
                        Just boardId ->  
                            if boardId == uid then
                                [
                                input [value name, class "nav-bar-item-input", onInput BoardTitleChange] []
                                ,div [class "nav-bar-item-pen", onClick (SaveBoardTitleChange)] [Icon.viewStyled [ Icon.sm ] Icon.checkCircle]
                                ]
                            else    
                                label
                        Nothing -> label

viewNavBar : Model -> Html Msg
viewNavBar model =
            let                
                activeMenuClass uid = if model.boxGroup.uid == uid then (class "active") else (class "")                           
                navBarItems = List.map 
                                (\board -> 
                                    Navbar.itemLink 
                                    [ onClick (LoadSelectedBoard board.uid), activeMenuClass board.uid  ] 
                                    [ 
                                        div [class "nav-menu-item" , onMouseOver (MenuHoverIn board.uid),onMouseLeave MenuHoverOut ]
                                        (viewNavBarControl model.boardTitleEdit model.menuHover board.uid board.name)                                        
                                    ]                                    
                                )
                                model.boxGroups
                navBarItems_ = Navbar.itemLink [ onClick NewBoard] [ Icon.viewStyled [ Icon.lg ] Icon.plus] :: navBarItems                
            in
                Navbar.config NavbarMsg
                    |> Navbar.dark                    
                    |> Navbar.withAnimation        
                    |> Navbar.items navBarItems_                                            
                    |> Navbar.customItems [Navbar.textItem [] [viewSearchFrom model]]
                    |> Navbar.view model.navbarState  
                    

viewSearchFrom : Model -> Html Msg
viewSearchFrom model = 
                        let
                            searchKeyMsg = case model.searchKeyword of 
                                            Just data -> Search data  
                                            Nothing ->  NoOp                       
                        in
                        div [class "form-inline",class "my-2", class"my-lg-0"]
                        [
                            input [ onInput SearchKeywordChange, class "form-control", class "mr-sm-2", value (Maybe.withDefault "" model.searchKeyword)][]
                            ,button [onClick searchKeyMsg, class "btn btn-outline-success my-2 my-sm-0 btn-board-search", type_ "button"][Icon.viewStyled [ Icon.lg ] Icon.search] 
                            ,button [onClick SearchClear, class "btn btn-outline-success my-2 my-sm-0 btn-board-search", type_ "button"][Icon.viewStyled [ Icon.lg ] Icon.times] 
                        ]
                       
viewGrid : Model -> Html Msg
viewGrid model = Grid.container []
            [ CDN.stylesheet
            , Grid.row []
                [ Grid.col []
                    [ viewNavBar model]
                ]            
            ]

viewNavBarDropDown : Model -> Html Msg
viewNavBarDropDown model = li [][]
type alias BoardNavDropDown = 
    { id : String
    , toggle : DropdownToggle Msg
    , items : List (DropdownItem Msg)
    }

-- dropdown :  BoardNavDropDown  -> Item msg

-- <li class="nav-item dropdown">
--         <a class="nav-link dropdown-toggle" href="#" id="navbarDropdownMenuLink" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
--           Dropdown link
--         </a>
--         <div class="dropdown-menu" aria-labelledby="navbarDropdownMenuLink">
--           <a class="dropdown-item" href="#">Action</a>
--           <a class="dropdown-item" href="#">Another action</a>
--           <a class="dropdown-item" href="#">Something else here</a>
--         </div>
--       </li>