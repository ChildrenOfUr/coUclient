#Children of Ur Web Client#

##What is this?##
This repository contains the source code for Children of Ur's Dart-based browser client.
The project is currently hosted at <a href="http://childrenofur.github.io/" target="_blank">childrenofur.github.io</a>.

Children of Ur is based on Tiny Speck's browser-based game, Glitch©. The original game's elements have been released into the public domain.
For more information on the original game and its licensing information, visit <a href="http://www.glitchthegame.com/" target="_blank">glitchthegame.com</a>.

##Getting Started##
1. Download the <a href="https://www.dartlang.org/">Dart Editor</a> and open this project
2. Make sure you have the required dependencies specified in pubspec.yaml
   If you're missing any of these, try running Tools > Pub Install
   If you're having trouble installing the coUlib package, try cloning the project
   from GitHub and specify the local pathname in the pubspec.yaml source
   
##General Roadmap##
The project is built in Dart, which is then compiled and minified into javascript and can run in most browsers.

main.dart serves as the main game loop. This class controls all functions within the game.

To test the project, it can be run at any time within the Dartium browser, wchih natively supports Dart.
To test the project within other browsers, it is necessary to first compile the project.
In coUclient, run tools > Publish_web.dart to compile your current build of the project.
