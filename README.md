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
   If you're having trouble installing the coUlib package, try cloning the project
   from GitHub and specify the local pathname in the pubspec.yaml source
   
##General Roadmap##
The project is built in <a href="https://www.dartlang.org" target="_blank">Dart</a>, which is then compiled and minified into javascript and can run in most browsers.

main.dart serves as the main game loop. This class controls all functions within the game.

To test the project, it can be run at any time within the Dartium browser, which natively supports Dart.
To test the project within other browsers, it is necessary to first compile the project.
In coUclient, run grind.dart to compile your current build of the project.


##License##

The MIT License (MIT)
Copyright (c) 2013 the coU Development Team

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


##Library and Content Licenses##
 

FontAwesome code is under the MIT License (MIT)
Copyright (c) 2013 dave@fontawesome.io

Glitch assets are under CC0
http://www.glitchthegame.com/licensing/

Pub installed packages have their own licensing see pub.dartlang.org for details.

##Attribution##
Font Awesome by Dave Gandy - http://fontawesome.io
Glitch Assets by TinySpeck - http://tinyspeck.com/

