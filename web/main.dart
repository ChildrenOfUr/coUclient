library coUclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'package:game_loop/game_loop_html.dart';
import 'package:asset_pack/asset_pack.dart';

// Import our coU libraries.
import 'package:coUlib/glitch-time.dart';// The script that spits out time!

// main game entry
part './dart/initialize.dart';

// Point to external dart files
part './dart/commands.dart';
part './dart/engine.dart';
part './dart/input.dart';
part './dart/render.dart';
part './dart/player.dart';
part './dart/camera.dart';

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
//CB - Haven't seen this model before, generally have seen
//update() and draw() as separate actions.
//leaving it as is for now. Is this the general setup for game_loop?

render() {

  // Update clock
  refreshClock();
  
  /*Would normally want to clear the screen before drawing BUT
   * gameScreen is a div, so we can't clear them all at once, AND
   * canvases move, AND
   * different canvas may want to refresh at different rates */
   

  //Update Player (positon, input)
  if (mysteryman is Player)
    mysteryman.update();
  
  //Update Camera (to follow)
  if (CurrentCamera is Camera)
    CurrentCamera.update();
  

  //Draw Street
  if (CurrentStreet is Street)
  CurrentStreet.render();
  
  //hard-coded values why
  //this is wonky right now, just for demonstration, to be fixed on next commit
  //very expensive operation
  if (CurrentCamera is Camera)
  middleCanvas.context2D.clearRect(10000, 10000, -10000, -10000);

  //Draw Player
  if (mysteryman is Player)
    mysteryman.render();
  
}

//TODO: IMPORTANT
/*Coding experience could start going much smoother if
 * inheritance was used.
 * Dart already makes base objects, BUT
 * Objects like Camera and Player (and later items)
 * should inherit from a base class that has position,
 * movement, image, draw and update methods, animations etc */
