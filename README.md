#Children of Ur Web Client#

##What is this?##
This repository contains the source code for Children of Ur's Dart-based browser client.
The project is currently hosted at <a href="http://childrenofur.com" target="_blank">childrenofur.com</a>.

Children of Ur is based on Tiny Speck's browser-based game, Glitch™. The original game's elements have been released into the public domain.
For more information on the original game and its licensing information, visit <a href="http://www.glitchthegame.com" target="_blank">glitchthegame.com</a>.

##Getting Started##
1. Download the <a href="https://www.dartlang.org/">Dart Editor</a> and open this project
2. Make sure you have the required dependencies specified in pubspec.yaml
   If you're missing any of these, try running Tools > Pub Install
   
##General Roadmap##
The project is built in <a href="https://www.dartlang.org" target="_blank">Dart</a>, which is then compiled and minified into javascript and can run in most browsers.

main.dart serves as the main game loop. This class controls all functions within the game.

To test the project, you will have to build an 'API_KEYS.dart' file for the /lib folder. Directions can be found <a href="https://github.com/ChildrenOfUr/coUclient/blob/master/doc/api.md" target="_blank">Here.</a>
With that included, simply right clicking on the index.html file and selecting 'Run in Dartium' will fire up the client.
To test the project within other browsers, it is necessary to first compile the project.
While using the Dart Editor, right click the index.html file and 'Run as JavaScript'.
