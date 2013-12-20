library coUclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:game_loop/game_loop_html.dart';
import 'package:asset_pack/asset_pack.dart';

// Import our coU libraries.
import 'package:coUlib/glitch-time.dart';// The script that spits out time!
import 'package:scproxy/scproxy.dart';

// main game entry
part './dart/initialize.dart';

// Point to external dart files
part './dart/commands.dart';
part './dart/engine.dart';
part './dart/input.dart';
part './dart/chat.dart';
part './dart/street.dart';
part './dart/player.dart';
part './dart/camera.dart';

// TODO: It may be a good idea to write our own simpler game_loop at some point.
// Define our game_loop
CanvasElement gameCanvas = new CanvasElement();

GameLoopHtml game = new GameLoopHtml(gameCanvas)
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
  //Update Camera (to follow)
  
  if (CurrentCamera is Camera)
    CurrentCamera.update();

  //Update Player (positon, input)
  if (CurrentPlayer is Player)
    CurrentPlayer.update();
  
  //Draw Street
  if (CurrentStreet is Street)
  CurrentStreet.render();
  
  //Clear canvas (very expensive)
  //Minimizes clearing for now
  if (CurrentCamera is Camera)
    gameCanvas.context2D.clearRect(CurrentPlayer.posX-CurrentPlayer.width, CurrentPlayer.posY-CurrentPlayer.height, CurrentPlayer.posX+CurrentPlayer.width, CurrentPlayer.posY+CurrentPlayer.height);
  
  //Draw Player
  if (CurrentPlayer is Player)
    CurrentPlayer.render();
}

//TODO: IMPORTANT
/*Coding experience could start going much smoother if
 * inheritance was used.
 * Dart already makes base objects, BUT
 * Objects like Camera and Player (and later items)
 * should inherit from a base class that has position,
 * movement, image, draw and update methods, animations etc */
