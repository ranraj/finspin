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

Supported Browser : Chrome

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
#### Requested features
- Multiboard support - [Saravanabhavan-Jaganathan](https://github.com/Saravanabhavan-Jaganathan)
- Clone notes - [Jerome](https://github.com/jerome4598)
- Undo - Add, Update, Delete - [Jerome](https://github.com/jerome4598)
- New Box Overlapping - [Radhakrishnan](https://github.com/rakihears)

### Pipeline features
- Board Sharing
- Community Board and Multi user action
- Real time update and event Notification
- Advertisment Wall
- Image Support
- SVG clip arts (Various Shapes)
- Transform shapes and Text
- Auto allignment of note boxes
- Labeling, Add Notes type, Template note types
- Auto grouping by labeling notes type and date
- Zoom in / out the Notes Board
- UX imporvement
- Reminder and Browser alert
- Notes type for Table, Graph, Long text
- Edit poup shoule be maximizable for long text edit
- Calender view - Timesheet option
- Clip arts - Like, Heart, Fire, Simle
### Improvement 
- Pick other tile color on edit a tile

### Bugs
- Default note position goes beyong the board limit
- Firefox add notes popup does not hide properly
