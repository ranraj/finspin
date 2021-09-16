module Update exposing (..)

import Draggable
import Date

import Tuple exposing (first,second)
import Math.Vector2 as Vector2
import File.Select as Select
import Task
import Dict exposing (Dict)
import Model exposing (Model,BoxGroup)
import Core exposing (buildNote,makeBox,emptyBox,updateNoteBox)
import Ports
import View exposing (..)
import App exposing (..)
import BoardTiles exposing (..)
import BoardDecoder exposing (boxListDecoderString,boxGroupDecoder)
import ContextMenu exposing (ContextMenu)
import Msg exposing (BoxAction(..),Color(..),Msg(..))
import Core exposing (emptyGroup)
import Dict exposing (empty)

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
                   savePostsCmd = if model.saveDefault then saveNotes newBoxGroup else Cmd.none  
                in 
                    ( { model | boxGroup = newBoxGroup }, Cmd.none )

        StopDragging ->            
                let
                   newBoxGroup = model.boxGroup |> stopDragging 
                    
                   savePostsCmd = if model.saveDefault then saveNotes newBoxGroup else Cmd.none  
                   _ = Debug.log "stop drag" newBoxGroup                   
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
                tilePosition = Vector2.vec2 (toFloat (first model.position)) (toFloat (second model.position))
                idleBoxes = 
                    if isEmpty then 
                        boxGroup.idleBoxes
                    else 
                        makeBox note.id note tilePosition currentBox.color currentBox.size :: boxGroup.idleBoxes
            in
                 ({ model | isPopUpActive = False,welcomeTour = False,currentBox = emptyBox,boxGroup = newBoxGroup}
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
        ReceivedDataFromJS value ->              
            let                 
                boxGroupMaybe = boxGroupDecoder value
                _ = Debug.log "receive" boxGroupMaybe
                newBoxGroup = case boxGroupMaybe of                                
                                Just data -> data
                                Nothing -> boxGroup
            in    
             ( { model | localBoxGroup = boxGroupMaybe, boxGroup = newBoxGroup }, Cmd.none )

        ViewNote id -> let       
                            boxOpt = boxGroup.idleBoxes |> List.filter (\b -> b.id == id) |> List.head
                            viewBox = case boxOpt of
                                        Just b -> b
                                        Nothing -> emptyBox
                            model_ = {model | isPopUpActive = True,currentBox = viewBox, editNote = True}                                        
                        in    
                            (model_  , Cmd.none)
        SaveBoard -> (model,saveNotes model.boxGroup)
        Position x y -> ({ model | position = (x, y) },Cmd.none)
        UpdateTitleColor tileColor -> 
                        let
                            box = model.currentBox                                                                    
                            newBox = {box | color = Just tileColor}                            
                        in
                            ({model | currentBox = newBox} , Cmd.none)        
        Pick ->
            ( model
            , Select.files ["json/*"] GotFiles  
            )
        DragEnter ->
            ( { model | hover = True }
            , Cmd.none
            )
        DragLeave ->
            ( { model | hover = False }
            , Cmd.none
            )
        GotFiles file files ->
            ( { model
                    | files = file :: files                    
                    , hover = False
                    , saveDefault = False
                }
            , read file
            )
        MarkdownLoaded fileContent -> 
            let
                newIdelBoxes = boxListDecoderString <| fileContent
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
        InitDownloadSVG content ->(model,Task.perform  (DownloadSVG content) Date.today)                    
        DownloadSVG content today -> (model,downloadJson content (Date.toIsoString today))                    
        GetSvg ->
            ( model,Cmd.batch [Ports.getSvg "boxesView"
            --,Task.perform  (DownloadSVG "") Date.today
            ]  )
        GotSvg output ->             
            ( model, downloadSVG output "type")             
        ContextMenuMsg cMsg ->
                        let                            
                            ( contextMenu_, cmd ) =
                                ContextMenu.update cMsg model.contextMenu
                        in
                            ({ model | contextMenu = contextMenu_ } , Cmd.map ContextMenuMsg cmd )   
        SelectShape context action ->
                        let                                                        
                           updateCmdMsg = if context == "mainContextMenu" then
                               case action of 
                                        New -> (model,run StartNoteForm)
                                        DeleteAll -> (model,run NoOp)
                                        Share ->  (model,run NoOp)
                                        _ -> (model, run NoOp)
                            else
                                case action of 
                                        Open -> (model,run (ViewNote context))
                                        Completed -> (model, run (CheckNote context))
                                        Delete ->  (model,run (ClearNote context))
                                        _ -> (model,run NoOp)
                             
                        in            
                            updateCmdMsg                                    
        NewBoard -> 
                let
                    boxGroup_ = emptyGroup
                    
                    model_ = {model | boxGroup = boxGroup_}                   
                in
                    (model_,Cmd.none)
run : msg -> Cmd msg
run m =
    Task.perform (always m) (Task.succeed ())
