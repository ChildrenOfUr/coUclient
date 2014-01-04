library coUclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart'; //used for NumberFormat

// Import our non-standard libraries.
import 'package:game_loop/game_loop_html.dart';// TODO: It may be a good idea to write our own simpler game_loop at some point.

// Import our coU libraries.
import 'package:glitchTime/glitch-time.dart';// The script that spits out time!
import 'package:scproxy/scproxy.dart'; // Paul's soundcloud bootstrap
import 'package:loadie/loadie.dart'; // Nice and simple asset loading.

// main game entry
part 'dart/engine/initialize.dart'; // home of the 'main()'

// Engine parts
part 'dart/engine/render.dart'; // render loop
part 'dart/engine/loop.dart';   // game loop
part 'dart/engine/audio.dart';
part 'dart/engine/commands.dart';
part 'dart/engine/ui.dart';
part 'dart/engine/input.dart';
part 'dart/engine/chat.dart';
part 'dart/engine/joystick.dart';

// Game parts
part 'dart/street.dart';

//localStorage to use throughout app
Storage localStorage = window.localStorage;

// Declare our game_loop
CanvasElement gameCanvas = new CanvasElement();
GameLoopHtml game = new GameLoopHtml(gameCanvas)
  ..onUpdate = ((gameLoop) {loop();})
  ..onRender = ((gameLoop) {render();});
