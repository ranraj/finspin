module Main exposing (..)

import Browser
import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)
import Math.Vector2 as Vector2 exposing (Vec2, getX, getY)
import Svg exposing (Svg,text_)
import Svg.Attributes as Attr
import Svg.Events exposing (onMouseUp)
import Svg.Keyed
import Svg.Lazy exposing (lazy)
import Types exposing (..)
import BoardTiles exposing (..)
import Tuple exposing (first,second)
import Html exposing (Html, button, text,p, div, h4, img, li, ul, input, i,textarea)
import Html.Attributes exposing ( class, src, style, type_, placeholder, value, checked)
import Html.Events exposing (onInput, onClick)
import FontAwesome.Attributes as Icon
import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Layering as Icon
import FontAwesome.Solid as Icon
import FontAwesome.Styles as Icon
import Config exposing (welcomeNotes,defaultNewTilePosition)
import Ports
import Json.Encode as Encode
import Json.Decode as JD exposing (Error(..), Value, decodeValue, string,field,decodeString,bool,Decoder)
import Math.Vector2 as Vector2 exposing (Vec2, getX, getY)
import Array

buildNote : Int -> String -> String -> Note
buildNote length t d= { 
            id = ((String.fromInt length ++ String.slice 0 5 t))
            , done = False
            , title = t
            , description = d 
            }

addDefaultPositionToNote : Note -> (Vec2,Note)
addDefaultPositionToNote note = (defaultNewTilePosition,note)
    
makeBox : Id -> (Vec2,Note) -> Box
makeBox id position =
    Box id (first position) False (second position)

addBox : (Vec2, Note) -> BoxGroup -> BoxGroup
addBox position ({ uid, idleBoxes } as group) =
    { group
        | idleBoxes = makeBox (String.fromInt uid) position :: idleBoxes
        , uid = uid + 1
    }


makeBoxGroup : List (Vec2,Note) -> BoxGroup
makeBoxGroup positions =
    positions
        |> List.foldl addBox emptyGroup

boxPositions : List (Vec2,Note)
boxPositions =
    let
        indexToPosition =
            toFloat >> (*) 60 >> (+) 10 >> Vector2.vec2 10
        notes = welcomeNotes
    in
    notes |> List.indexedMap (\i x -> ((indexToPosition i),x))

boxesView : BoxGroup -> Svg Msg
boxesView boxGroup =
    boxGroup
        |> allBoxes
        |> List.reverse
        |> List.map boxView
        |> Svg.node "g" []

svgPanelBackground : Svg msg
svgPanelBackground =
    Svg.rect
        [ Attr.x "0"
        , Attr.y "0"
        , Attr.width "100%"
        , Attr.height "100%"
        , Attr.fill (getColor BoardGreen)
        ]
        []    


-- Notes View Html --

addNotePanel : Note -> Bool -> Html Msg
addNotePanel note isEdit =
    li [class "add-to-panel"]
        [ div [ class "li-header"] [ viewInput "text" "Title" "form-input" note.title (ChangeTitle)]
        , div [ class "line-seperator"] []
        , div [] [ viewTextArea "Description" "form-input" note.description (ChangeDesc)]   
        , div [] 
            [
               button [ onClick ((if isEdit then UpdateNote else AddNote) note.title note.description), class "form-btn"] [text "Save"]
               ,button [ onClick CancelNoteForm, class "form-btn" ] [text "Clear"]            
            ]             
        ]

viewNoteComponent : Note -> Box -> Html Msg
viewNoteComponent addNote box  =
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

viewNoteForm : Note -> Html Msg
viewNoteForm note =
    div [ class "form" ]
    [ h4 [] [ text "Add Note" ] 
    , viewInput "text" "title" "form-input" note.title (ChangeTitle)
    , viewInput "text" "description" "form-input" note.description (ChangeDesc)
    , div [] 
        [ button [ onClick CancelNoteForm, class "form-btn" ] [text "Cancel"]
        , button [ onClick (AddNote note.title note.description), class "form-btn"] [text "Save"]
        ]
    ]

getNotes : BoxGroup -> Note -> Html Msg
getNotes boxGroup addNote=
    ul [ class "note-list", style "color" "black" ] (List.map (viewNoteComponent addNote) boxGroup.idleBoxes)

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
    ( { boxGroup = makeBoxGroup boxPositions
      , drag = Draggable.init
      , addingNote = False
      , editNote = False
      , noteToAdd = emptyNote
      , localData = []
      , jsonError = Nothing
      }
    , Cmd.none
    )
         
view : Model -> Html Msg
view model =
    div [class "content-container"] [
        div [class "content-display"] 
        [
            div
             []
                [ 
                h4 [] [ text "Finspin Board" ]                  
                ,p
                    [ style "padding-left" "8px" ]
                    [ text "Drag any box around. Click it to toggle its color." ]
                , Svg.svg
                    [ Attr.class "svgPanel"
                    ]
                    [ svgPanelBackground
                    , boxesView model.boxGroup
                    ]
                ]
        ]
        ,div [class "content-controller"]
        [ Icon.css  
        ,p
            [ style "padding-left" "8px" ]
            [ text "Add or Edit note" ]             
        , button 
            [ onClick (if model.addingNote then CancelNoteForm else StartNoteForm)
             , style "border" "none", style "svgPanelBackground-color" "transparent",style "color" "skyblue"
             ] [ Icon.viewStyled [ Icon.fa2x ] Icon.plusCircle]
        , button 
            [ onClick (SaveBoard)
             , style "border" "none", style "svgPanelBackground-color" "transparent",style "color" "skyblue"
             ] [ Icon.viewStyled [ Icon.fa2x ] Icon.save]
        , ul [ class "list", style "color" "black" ] [addNotePanel model.noteToAdd model.editNote]    
        , (if model.addingNote then viewNoteForm model.noteToAdd else div [ style "hidden" "true" ] [])        
        , getNotes model.boxGroup model.noteToAdd      
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

        ToggleBoxClicked id -> let            
                                    boxOpt = boxGroup.idleBoxes |> List.filter (\b -> b.id == id) |> List.head
                                    viewNote = case boxOpt of
                                                Just b -> b.note
                                                Nothing -> emptyNote
                                    newBoxGroup = boxGroup |> toggleBoxClicked id
                                    savePostsCmd = saveNotes newBoxGroup.idleBoxes 
                                in    
                                    ({ model | noteToAdd = viewNote, boxGroup = newBoxGroup }, savePostsCmd)         

        DragMsg dragMsg ->
            Draggable.update dragConfig dragMsg model

        AddNote t d ->                     
            let 
                note  = buildNote (List.length model.boxGroup.idleBoxes) t d
                box = addDefaultPositionToNote <| note
                
                isEmpty = String.isEmpty t && String.isEmpty d
                savePostsCmd = if isEmpty then Cmd.none else saveNotes idleBoxes
                idleBoxes = if isEmpty then boxGroup.idleBoxes else makeBox note.id box :: boxGroup.idleBoxes
            in
                 ({ model | noteToAdd = emptyNote,boxGroup = {boxGroup | idleBoxes = idleBoxes}}
                , savePostsCmd)  

        UpdateNote t d ->                     
            let 
                updateNote box = if (box.id == model.noteToAdd.id) then
                                        let
                                            newTitle = if String.isEmpty t then box.note.title else t
                                            newDescription = if String.isEmpty d then box.note.description else d
                                            newNote = Note box.note.id box.note.done newTitle newDescription
                                        in    
                                            {box | note = newNote}
                                    else 
                                        box

                edit = model.editNote                                
                isEmpty = String.isEmpty t && String.isEmpty d                

                newIdleBoxes = if edit && isEmpty then boxGroup.idleBoxes else List.map (\box -> updateNote box) boxGroup.idleBoxes                                                                                    
                savePostsCmd = if isEmpty then Cmd.none else saveNotes newIdleBoxes
                
            in
                 ({ model | noteToAdd = emptyNote,boxGroup = { boxGroup | idleBoxes = newIdleBoxes}}
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
            ({ model | boxGroup = { boxGroup | idleBoxes = idleBoxesFiltered }}, savePostsCmd)

        StartNoteForm ->
            ({ model | addingNote = True }, Cmd.none)
        
        CancelNoteForm ->
            ({ model | addingNote = False,editNote=False, noteToAdd = emptyNote }, Cmd.none)
        
        ChangeTitle t ->
            ({ model | noteToAdd = 
            { id = model.noteToAdd.id
            , title = t
            , description = model.noteToAdd.description
            , done = False
            } }, Cmd.none)
        ChangeDesc d ->
            ({ model | noteToAdd = 
            { id = model.noteToAdd.id
            , title = model.noteToAdd.title
            , description = d
            , done = False
            } }, Cmd.none)
        ReceivedDataFromJS value ->              
            let                 
                localData = boxListDecoder value
                boxList = if List.isEmpty localData then model.boxGroup.idleBoxes else localData
            in    
             ( { model | localData = localData, boxGroup = {boxGroup | idleBoxes = boxList  } }, Cmd.none )

        ViewNote id -> let            
                            boxOpt = boxGroup.idleBoxes |> List.filter (\b -> b.id == id) |> List.head
                            viewNote = case boxOpt of
                                        Just b -> b.note
                                        Nothing -> emptyNote                                
                        in    
                            ( {model | noteToAdd = viewNote, editNote = True} , Cmd.none)
        SaveBoard -> (model,saveNotes model.boxGroup.idleBoxes)

subscriptions : Model -> Sub Msg
subscriptions { drag } = 
    Draggable.subscriptions DragMsg drag

------- Local Stroage --------------------------------
saveNotes : List Box -> Cmd msg
saveNotes noteBoxes =
    Encode.list noteBoxEncoder noteBoxes        
        |> Ports.storeNotes            

noteEncoder : Note -> Encode.Value
noteEncoder note = Encode.object
        [ ("id", Encode.string note.id)
        , ("done", Encode.bool note.done)
        , ("title", Encode.string note.title)
        , ("description", Encode.string note.description)        
        ]

noteBoxEncoder : Box -> Encode.Value
noteBoxEncoder noteBox =
  let 
    positionStr = String.fromFloat (getX noteBox.position) ++ "," ++ String.fromFloat (getY noteBox.position)
  in
    Encode.object
        [ ("id", Encode.string noteBox.id)
        , ("position", Encode.string positionStr)
        , ("note", noteEncoder noteBox.note)
        , ("clicked", Encode.bool noteBox.clicked)        
        ]

notePositionDecoder : Maybe Float -> Maybe Float -> (Float, Float)
notePositionDecoder x y = 
        let         
            xFloat = case x of
                Just a -> a
                _ -> 0
            yFloat = case y of
                Just a -> a
                _ -> 0        
        in
            (xFloat,yFloat)    

noteDecoder : Decoder Note
noteDecoder =
  JD.map4 Note
    (field "id" string)
    (field "done" bool)
    (field "title" string)
    (field "description" string)

positionDecoder : String -> (Float, Float)
positionDecoder pos = 
        let
            posSplit = Array.fromList (String.split "," pos)
            x = case (Array.get 0 posSplit) of
                Just a -> String.toFloat a
                _ -> Nothing
            y = case (Array.get 1 posSplit) of
                Just a -> String.toFloat a
                _ -> Nothing
        in
           notePositionDecoder  x y
        
boxDecoder:  Decoder Box
boxDecoder =
  JD.map4 Box
    (field "id" string)
    (field "position" string |>  JD.map ( \pos -> positionDecoder pos |> (\vec -> Vector2.vec2 (first vec) (second vec))))
    (field "clicked" bool )
    (field "note" noteDecoder)

boxListDecoder : String -> List Box
boxListDecoder value = 
  let
    res =  decodeString (JD.list boxDecoder) value    
    
  in
    case res of
        Result.Ok data -> data
        Result.Err e -> 
            let               
               emptyArray = []
            in
                emptyArray

subscriptionsLocalStorage : Model -> Sub Msg
subscriptionsLocalStorage _ = 
        Ports.receiveData ReceivedDataFromJS    
