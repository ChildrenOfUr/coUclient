#Children of Ur Web Client#

##What is this?##
This repository contains the source code for Children of Ur's Dart-based browser client.
The project is currently hosted at <a href="http://childrenofur.com" target="_blank">childrenofur.com</a>.

Children of Ur is based on Tiny Speck's browser-based game, Glitch™. The original game's elements have been released into the public domain.
For more information on the original game and its licensing information, visit <a href="http://www.glitchthegame.com" target="_blank">glitchthegame.com</a>.

##Getting Started##
1. Download the <a href="https://www.dartlang.org/">Dart Editor</a>
2. In the Dart Editor, go to File -> "Open Existing Folder" and open this project folder
3. Make sure you have the required dependencies specified in pubspec.yaml. If you're missing
any of these, try selecting a file in the project, and then running Tools > Pub Get.

###Test in Dartium###
Right clicking on the `web/game.html` file and selecting 'Run in Dartium' will fire up the client.

###Test in Other Browsers###
To test the project within other browsers, it is necessary to first compile the project.
While using the Dart Editor, right click the `web/game.html` file and 'Run as JavaScript'.

##General Roadmap##
The project is built in <a href="https://www.dartlang.org" target="_blank">Dart</a>, 
which is then compiled and minified into javascript and can run in most browsers. See our team collaboration
site on Trello for the current roadmap.

##Project Layout##
main.dart serves as the main game loop. This class controls all functions within the game. Dart classes and
functions are in the `lib/src` folder. Images, CSS and other web resources are in `web/assets`. More
development documentation is in the `doc` folder.

[ ![Codeship Status for ChildrenOfUr/coUclient](https://codeship.com/projects/7e85d760-15e5-0132-d849-622a88ccaa2e/status?branch=master)](https://codeship.com/projects/33763)

