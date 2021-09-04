# finspin
Finspin is intractive board for notes

## Idea

Application to take notes that like Twitter message short and linkable. Drag and Drop UI to arrange your notes in your way. It gives a graph representation for your linked notes. It can serve as MindMap.

## Motivation  
I see developers are using notepad for multipurpose. It is an offline web application solution like a notepad with a server sync option. Notes stored offline as default. Enable the Save toggle option to sync notes instantly on the server. 

Note : Currently supports only PC version. 

Live ['Demo'](https://ranraj.github.io/finspin/index.html)

Tech Stack  
```
Elm 19.0
```

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
App screenshot
![](https://ranraj.github.io/finspin/Screenshot.png)
