library coUclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dartemis/dartemis.dart';
import 'package:game_loop/game_loop_html.dart';// TODO: It may be a good idea to write our own simpler game_loop at some point.
import 'package:asset_pack/asset_pack.dart';

// Import our coU libraries.
import 'package:coUlib/glitch-time.dart';// The script that spits out time!
import 'package:scproxy/scproxy.dart'; // Paul's soundcloud bootstrap
import 'package:intl/intl.dart'; //used for NumberFormat

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

// Point to external dart files
part 'dart/street.dart';
part 'dart/player.dart';

//localStorage to use throughout app
Storage localStorage = window.localStorage;

// Declare our game_loop
CanvasElement gameCanvas = new CanvasElement();
GameLoopHtml game = new GameLoopHtml(gameCanvas)
  ..onUpdate = ((gameLoop) {loop();})
  ..onRender = ((gameLoop) {render();});

// Declare our asset manager.
AssetManager assets = new AssetManager();

// Create a world
World world = new World();

