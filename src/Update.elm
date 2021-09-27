module Update exposing (..)

import Draggable

import Tuple exposing (first,second)
import Math.Vector2 as Vector2
import File.Select as Select
import Task
import Model exposing (Model,BoxGroup,Position)
import Core exposing (buildNote,makeBox,emptyBox,updateNoteBox)
import Ports
import View exposing (..)
import App exposing (saveNotes,saveBoards)
import BoardTiles exposing (..)
import BoardDecoder exposing (boxListDecoderString,boxGroupDecoderString,boxGroupsDecoderString,positionDecoderContextMenu)
import Msg exposing (BoxAction(..),Color(..),Msg(..))
import Core exposing (emptyGroup)
import Time
import Core exposing (emptyGroupWithId)
import ContextMenu exposing (ContextMenu)
import Html.Attributes exposing (contextmenu)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ boxGroup } as model) =
    case msg of
        NoOp ->
            ( model, Cmd.none )
        OnDragBy delta ->
            ( { model | boxGroup = boxGroup |> dragActiveBy delta }, Cmd.none )

        StartDragging id ->
                let                   
                   newBoxGroup = model.boxGroup |> startDragging  id                  
                in 
                    ( { model | boxGroup = newBoxGroup }, Cmd.none )

        StopDragging ->            
                let
                   newBoxGroup = model.boxGroup |> stopDragging                      
                   savePostsCmd = if model.saveDefault then saveNotes newBoxGroup else Cmd.none  
                   
                in    
                    ({ model | boxGroup = newBoxGroup }, savePostsCmd )

        DragMsg dragMsg ->
            Draggable.update dragConfig dragMsg model

        AddNote t d ->                     
            let 
                currentBox = model.currentBox
                
                note  = buildNote (List.length model.boxGroup.idleBoxes) t d                             
                isEmpty = String.isEmpty t && String.isEmpty d
                newBoxGroup = {boxGroup | idleBoxes = idleBoxes}
                savePostsCmd = if isEmpty || not model.saveDefault then Cmd.none else saveNotes newBoxGroup
                tilePosition = Vector2.vec2 (toFloat model.position.x) (toFloat model.position.y)
                _ = Debug.log "postion1" model.position
                _ = Debug.log "postion" tilePosition
                idleBoxes = 
                    if isEmpty then 
                        boxGroup.idleBoxes
                    else 
                        makeBox note.id note tilePosition currentBox.color currentBox.size :: boxGroup.idleBoxes
                                
                y_= model.position.y + 60                                    
                x_ = model.position.x
                position_ = Position x_ y_
                _ = Debug.log "sd" position_
            in
                 ({ model | position = position_, isPopUpActive = False,welcomeTour = False,currentBox = emptyBox,boxGroup = newBoxGroup}
                , savePostsCmd)  

        UpdateNote t d ->                     
                let                  
                    edit = model.editNote                                
                    isEmpty = String.isEmpty t && String.isEmpty d                
                    
                    newIdleBoxes = if edit && isEmpty then boxGroup.idleBoxes else List.map (\box -> updateNoteBox model box t d) boxGroup.idleBoxes                                                                                    
                    newBoxGroup = { boxGroup | idleBoxes = newIdleBoxes}
                    savePostsCmd = if isEmpty || not model.saveDefault then Cmd.none else saveNotes newBoxGroup
                    
                in
                    ({ model | isPopUpActive = False,editNote = False,boxGroup = newBoxGroup }
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
                    savePostsCmd = if model.saveDefault then saveNotes newBoxGroup else Cmd.none
                in
                ({ model | boxGroup = newBoxGroup}, savePostsCmd)

        ClearNote i ->
                let
                    idleBoxesFiltered = List.filter (\box -> box.note.id /= i) model.boxGroup.idleBoxes 
                    newBoxGroup = { boxGroup | idleBoxes = idleBoxesFiltered }
                    savePostsCmd = if model.saveDefault then saveNotes newBoxGroup else Cmd.none
                in
                ({ model | isPopUpActive = False, boxGroup =newBoxGroup}, savePostsCmd)

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
        ReceivedBoard value ->              
                let                 
                    boxGroupMaybe = boxGroupDecoderString value                
                    newBoxGroup = case boxGroupMaybe of                                
                                    Just data -> data
                                    Nothing -> boxGroup
                in    
                ( { model | localBoxGroup = boxGroupMaybe, boxGroup = newBoxGroup }, Cmd.none )

        ViewNote id -> 
                let       
                    boxOpt = boxGroup.idleBoxes |> List.filter (\b -> b.id == id) |> List.head
                    viewBox = case boxOpt of
                                Just b -> b
                                Nothing -> emptyBox
                    model_ = {model | isPopUpActive = True,currentBox = viewBox, editNote = True}                                        
                in    
                    (model_  , Cmd.none)
        SaveBoard -> (model,saveNotes model.boxGroup)
        SetPosition x y -> ({ model | position =  Position x  y  },Cmd.none)
        UpdateTitleColor tileColor -> 
                let
                    box = model.currentBox                                                                    
                    newBox = {box | color = Just tileColor}                            
                in
                    ({model | currentBox = newBox} , Cmd.none)        
        Pick ->
            ( model
            , Select.files ["json/*"] ImportBoard  
            )
        DragEnter ->
            ( { model | hover = True }
            , Cmd.none
            )
        DragLeave ->
            ( { model | hover = False }
            , Cmd.none
            )
        ImportBoard file files ->
            ( { model
                    | files = file :: files                    
                    , hover = False
                    , saveDefault = False
                }
            , readImportedBoard file
            )
        LoadImportedBoard fileContent -> 
            let
                boxGroup_ = boxGroupDecoderString <| fileContent
                newIdelBoxes = (Maybe.withDefault emptyGroup boxGroup_).idleBoxes
                newBoxGroup = {boxGroup | idleBoxes = newIdelBoxes}
            in  
                ({model | boxGroup = newBoxGroup },Cmd.none)
        ToggleAutoSave -> ({model | saveDefault = not model.saveDefault}, Cmd.none)
        UpdateBoxSize boxSize -> 
            let
                box = model.currentBox                                                                    
                newBox = {box | size = boxSize}                            
            in
                ({model | currentBox = newBox} , Cmd.none)
        ExportBoard content boardName ->(model,downloadJson content boardName)                            
        GetSvg ->
            ( model,Cmd.batch [Ports.getSvg "boxesView"]  )
        GotSvg output ->             
            ( model, downloadSVG output model.boxGroup.name)             
        ContextMenuMsg cMsg ->
            let                            
                ( contextMenu_, cmd ) =
                    ContextMenu.update cMsg model.contextMenu              
                contextMenuJson = Debug.toString contextMenu_
            
                position_ = if String.contains "hover = None, mouse =" contextMenuJson  then
                                 positionDecoderContextMenu contextMenuJson
                                else model.position
                                                
            in
                ({ model | position = position_, contextMenu = contextMenu_ } , Cmd.map ContextMenuMsg cmd )   
        SelectShape context action ->
                        let                              
                           position = context                                                    
                           updateCmdMsg = if context == "mainContextMenu" then
                               case action of 
                                        New -> (model,Core.run StartNoteForm)
                                        DeleteAll -> (model,Core.run NoOp)
                                        Share ->  (model,Core.run NoOp)
                                        _ -> (model, Core.run NoOp)
                            else
                                case action of 
                                        Open -> (model,Core.run (ViewNote context))
                                        Completed -> (model, Core.run (CheckNote context))
                                        Delete ->  (model,Core.run (ClearNote context))
                                        _ -> (model,Core.run NoOp)
                             
                        in            
                            updateCmdMsg  
        NewBoard -> (model, Task.perform (NewBoardGen) Time.now)                                                      
        NewBoardGen timeNow -> 
                let                                    
                    boxGroup_ = emptyGroupWithId (Time.posixToMillis timeNow) (Core.dateToString timeNow)                    
                    containsBoxGroup = List.filter (\board -> board.uid == model.boxGroup.uid) model.boxGroups
                    boxGroups_ = if List.isEmpty containsBoxGroup then
                                       boxGroup_ :: model.boxGroups 
                                    else
                                       boxGroup_ :: List.map 
                                            (\board -> if board.uid == model.boxGroup.uid then boxGroup else board) 
                                            model.boxGroups                     
                    model_ = {model | boxGroup = boxGroup_, boxGroups = boxGroups_}                   
                    savePostsCmd = saveBoards boxGroups_
                    
                in
                    (model_,savePostsCmd)
        LoadSelectedBoard boardId -> 
                    let          
                        switchBoard =
                                    let 
                                        containsBoxGroup = List.filter (\board -> board.uid == boardId) model.boxGroups
                                    
                                        (boxGroup_,boxGroups_) = 
                                                    if List.isEmpty containsBoxGroup then                                        
                                                        (model.boxGroup,  model.boxGroups)
                                                    else
                                                        (Maybe.withDefault model.boxGroup (List.head containsBoxGroup)
                                                        , List.map  
                                                            (\board -> if board.uid == model.boxGroup.uid then model.boxGroup else board) 
                                                            model.boxGroups)                     
                                        model_ = {model | boxGroup = boxGroup_, boxGroups = boxGroups_}                                           
                                        savePostsCmd = saveBoards boxGroups_                        
                                    in
                                        (model_,savePostsCmd)
                        modelMsg =  if model.boxGroup.uid == boardId then (model,Cmd.none)  else  switchBoard
                    in
                        modelMsg
        ReceivedBoards boxGroupsString -> 
                            let
                               boxGroups = boxGroupsDecoderString boxGroupsString                                                          
                            in
                                ({model | boxGroups = boxGroups},Cmd.none)
        CurrentDateTime -> (model, Task.perform (CaptureDateTime) Time.now)            
        CaptureDateTime timeNow -> 
                            let
                                timeNow_ = Time.posixToMillis timeNow
                                boxGroup_ = Core.emptyGroupWithId timeNow_  (Core.dateToString timeNow)
                                boxGroups_ = [boxGroup_]
                            in                
                                ({model | boxGroup = boxGroup_,boxGroups = boxGroups_ },Cmd.none)
        NavbarMsg state -> 
                        ( { model | navbarState = state }, Cmd.none )
        MenuHoverIn menuId -> ({model | menuHover = Just menuId},Cmd.none)
        MenuHoverOut -> ({model | menuHover = Nothing},Cmd.none)
        EditBoardTitle uid -> ({ model | boardTitleEdit = Just uid}, Cmd.none)
        BoardTitleChange text -> 
                            let 
                                boxGroups_ = case model.boardTitleEdit of 
                                                    Just boardId -> List.map 
                                                            (\board -> 
                                                            if boardId == board.uid  then  {board | name = text}  else  board
                                                            ) 
                                                            model.boxGroups
                                                    Nothing -> model.boxGroups                                                      
                                boxGroup_ = {boxGroup | name = text}            
                            in  
                                ({ model | boxGroup = boxGroup_, boxGroups = boxGroups_}, Cmd.none)

        SaveBoardTitleChange -> ({ model | boardTitleEdit = Nothing,boxGroups = model.boxGroups}, Cmd.none)
        RemoveBoard uid -> 
            let
                boxGroups_ = List.filter (\board -> board.uid == uid |> not) model.boxGroups                
                boxGroup_ = Maybe.withDefault emptyGroup (List.head boxGroups_)                
            in 
                ({model | boxGroup = boxGroup_, boxGroups = boxGroups_},Core.run (LoadSelectedBoard boxGroup_.uid) )
        Search keyword ->
                    let 
                        boxGroup_ = Core.searchBox boxGroup keyword
                    in
                        ({model | boxGroup = boxGroup_},Cmd.none)        
        SearchKeywordChange keyword -> 
                    let                        
                        boxGroup_ = Core.searchBox boxGroup keyword                                                                                        
                    in    
                        ({model | boxGroup = boxGroup_, searchKeyword = if String.isEmpty keyword then Nothing else Just keyword},Cmd.none)
        SearchClear -> 
                let
                    result = 
                        List.map 
                                (\box ->  if box.foundInSearch == True then {box | foundInSearch = False} else box ) 
                                    boxGroup.idleBoxes
                    boxGroup_ = {boxGroup | idleBoxes = result}                
                in 
                    ({model | searchKeyword = Nothing, boxGroup = boxGroup_},Cmd.none)
     

