# Finspin
Finspin is interactive board for notes - Progressive WebApp

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
