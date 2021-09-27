### Why this new space for notes
Why do even notes need to be serial/sequential or fit into an order? 
Rough notes would show our Real creative face. Your thoughts need more respect than just text. 

Let's Finspin helps you to keep your notes, keywords, bookmarks in any order. Go and place it as you like on your offline board. 

Colour it as your like. 
Move it! Mark it !! Edit !!  Share in your creativity board.

 It's the freedom to arrange your board. 
Use it professionally with templates or pick your template to collaborate easily with friends. Ideas worth sharing more creatively.



# Finspin
Finspin is interactive board for notes - [Progressive WebApp](https://web.dev/what-are-pwas/) [![Build Status](https://app.travis-ci.com/ranraj/finspin.svg?branch=main)](https://app.travis-ci.com/ranraj/finspin)

## Idea

Application to take notes that like Twitter message short and linkable. Drag and Drop UI to arrange your notes in your way. It gives a graph representation for your linked notes. It can serve as MindMap.

## Motivation  
I see developers are using notepad for multipurpose. It is an offline web application solution like a notepad with a server sync option. Notes stored offline as default. Enable the Save toggle option to sync notes instantly on the server. 

Note : Currently supports only PC version. 

Live ['Demo'](https://finspin.netlify.app/)

Tech Stack  
```
Elm 19.0
```
## Elm Dev Environment
Run
```
  elm reactor
```  
Build
```
elm make src/Main.elm --output=public/main.js
```

Test (Mac) 
```
open public/index.html
```

## NPM Dev Environment

Build
```
npm install 
npm run build
```
Run
```
npm run start
```
Test
```
http://localhost:3000
```

App screenshot
![](https://ranraj.github.io/finspin/Screenshot.png)


## Release Notes :
### V 1.0.0 Beta
- Add, Update and Delete Note
- Add, Rename, and Delete Note Board
- Search Notes
- Drag & Drop notes
- Right click (Context menu) to add notes operation
- Change Note Size and Color
- Title Board (Only have Title) for labelling purpose
- Complete offline Application - Stores the Boards in local browser storage
- Progressive Web App - Intermident network disconnection doest not kill the user experience
- Default Autosave, Toggle for Autosave, Save
- Import and Export Board
- Download Board as SVG Image
#### Requested feature
- Multiboard support (Saravanabhavan)
- Clone notes - (Jerome)
- Undo - Add, Update, Delete - (Jerome)
- New Box Overlapping - (Radhakrishnan)