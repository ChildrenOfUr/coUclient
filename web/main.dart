library coUclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:game_loop/game_loop_html.dart';
import 'package:asset_pack/asset_pack.dart';

// Import our coU libraries.
import 'package:coUlib/glitch-time.dart';// The script that spits out time!

// main game entry
part './dart/initialize.dart';

// Point to external dart files
part './dart/commands.dart';
part './dart/user_interface.dart';
part './dart/input.dart';
part './dart/render.dart';

// TODO: It may be a good idea to write our own simpler game_loop at some point.
// Define our game_loop
GameLoopHtml game = new GameLoopHtml(middleCanvas)
  ..onUpdate = ((gameLoop) {loop();})
  ..onRender = ((gameLoop) {render();});

// Declare our asset manager.
AssetManager assets = new AssetManager();



// Initialize and begin the game.
main() {
  init();
  game.start();
}

// Our gameloop
loop() {
  
  
}

// Our renderloop
render() {
// Update clock
refreshClock();

// Update Street
if (CurrentStreet is Street)
CurrentStreet.render();

}



