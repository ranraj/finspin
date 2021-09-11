module Update exposing (..)

import Draggable
import Date

import Tuple exposing (first,second)
import File.Select as Select
import Task
import Dict exposing (Dict)

import Model exposing (Model,Position,Shape(..),Tool(..))
import Msg exposing (Color(..), Msg(..))
import Core exposing (buildNote,makeBox,updateNoteBox,saveNotes)
import Ports
import View exposing (..)
import App exposing (emptyBox)
import BoardTiles exposing (..)
import BoardDecoder exposing (boxListDecoder)
import BoardEncoder exposing (shapesEncoder)
import Model exposing (Tool(..))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ boxGroup } as model) =
    case msg of
        OnDragBy delta ->
            ( { model | boxGroup = boxGroup |> dragActiveBy delta }, Cmd.none )

        StartDragging id ->
                let
                   newBoxGroup = model.boxGroup |> startDragging  id
                   savePostsCmd = if model.saveDefault then saveNotes newBoxGroup.idleBoxes else Cmd.none  
                in 
                    ( { model | boxGroup = newBoxGroup }, savePostsCmd )

        StopDragging ->            
                let
                   newBoxGroup = model.boxGroup |> stopDragging 
                   savePostsCmd = if model.saveDefault then saveNotes newBoxGroup.idleBoxes else Cmd.none  
                in    
                    ({ model | boxGroup = newBoxGroup }, savePostsCmd )

        DragMsg dragMsg ->
            Draggable.update dragConfig dragMsg model

        AddNote t d ->                     
            let 
                currentBox = model.currentBox
                
                note  = buildNote (List.length model.boxGroup.idleBoxes) t d                             
                isEmpty = String.isEmpty t && String.isEmpty d
                savePostsCmd = if isEmpty || not model.saveDefault then Cmd.none else saveNotes idleBoxes
                tilePosition = Position (toFloat (first model.position)) (toFloat (second model.position))
                idleBoxes = 
                    if isEmpty then 
                        boxGroup.idleBoxes
                    else 
                        makeBox note.id note tilePosition currentBox.color currentBox.size :: boxGroup.idleBoxes
            in
                 ({ model | isPopUpActive = False,welcomeTour = False,currentBox = emptyBox,boxGroup = {boxGroup | idleBoxes = idleBoxes}}
                , savePostsCmd)  

        UpdateNote t d ->                     
            let                  
                edit = model.editNote                                
                isEmpty = String.isEmpty t && String.isEmpty d                

                newIdleBoxes = if edit && isEmpty then boxGroup.idleBoxes else List.map (\box -> updateNoteBox model box t d) boxGroup.idleBoxes                                                                                    
                savePostsCmd = if isEmpty || not model.saveDefault then Cmd.none else saveNotes newIdleBoxes
                
            in
                 ({ model |                     
                    isPopUpActive = False,
                    editNote = False,
                    boxGroup = { 
                        boxGroup |
                             idleBoxes = newIdleBoxes
                             }     
                  }
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
                savePostsCmd = if model.saveDefault then saveNotes newBoxGroup.idleBoxes else Cmd.none
            in
            ({ model | boxGroup = newBoxGroup}, savePostsCmd)

        ClearNote i ->
            let
                idleBoxesFiltered = List.filter (\box -> box.note.id /= i) model.boxGroup.idleBoxes 
                savePostsCmd = if model.saveDefault then saveNotes idleBoxesFiltered else Cmd.none
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
        PointSelection x y -> ({ model | position = (x, y) },Cmd.none)
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
                newIdelBoxes = boxListDecoder <| fileContent
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
            ( model,Cmd.batch [Ports.getSvg "boxesView",Task.perform  (DownloadSVG "") Date.today]  )
        GotSvg output ->             
            ( model, downloadSVG output "type")     
        NoOp ->
            ( model, Cmd.none )
        MouseMove pos ->
            let
                mouse = model.mouse
                nextMouse =
                    { mouse | position = pos }
            in
                ({ model | mouse = nextMouse }, Cmd.none)
        MouseDown pos ->
            let
                mouse = model.mouse
                nextMouse =
                    { mouse | down = True, downSvgPosition = mouse.svgPosition }
            in
                ({ model | mouse = nextMouse }, Cmd.none)

        MouseUp pos ->
            let
                mouse = model.mouse
                nextMouse =
                    { mouse | down = False }

                nextModel =
                    { model
                        | mouse = nextMouse
                        , dragAction = Nothing
                        , comparedShape = Nothing
                    }
            in
                case model.dragAction of
                    Just _ ->
                        ( nextModel, sendShapes nextModel.shapes )

                    Nothing ->
                        (nextModel,Cmd.none)
        DeselectShape ->
            ({ model | selectedShapeId = Nothing }                
            ,Cmd.none)                        
        SelectShape shapeId ->
            ({ model
                | selectedShapeId = Just shapeId
            },Cmd.none)
        AddShape shape ->
            ( model |> addShape shape
            , Cmd.none
            )
                |> andSendShapes
       
                

        -- AddShape shape ->
        --     ( model |> addShape shape
        --     , Cmd.none
        --     )
        --         |> andSendShapes                    

sendShapes : Dict Int Shape -> Cmd Msg
sendShapes shapes =
    shapes
        |> shapesEncoder
        |> Ports.persistShapes

addShape : Shape -> Model -> Model
addShape shape model =
    let
        shapes : Dict Int Shape
        shapes =
            model.shapes

        maxId : Int
        maxId =
            shapes
                |> Dict.keys
                |> List.maximum
                |> Maybe.withDefault 0

        nextShapes : Dict Int Shape
        nextShapes =
            model.shapes
                |> Dict.insert (maxId + 1) shape
    in
        { model | shapes = nextShapes }

andSendShapes : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andSendShapes ( model, cmd ) =
    ( model
    , Cmd.batch
        [ cmd
        , sendShapes model.shapes
        ]
    )