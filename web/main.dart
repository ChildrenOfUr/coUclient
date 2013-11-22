library coUclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'package:dartemis/dartemis.dart' as dartemis;
import 'package:stagexl/stagexl.dart' as xl;
import 'package:game_loop/game_loop_html.dart';

// Import our private libraries.
import 'package:coUlib/glitch-time.dart';// The script that spits out time!

// main game entry
part './dart/cou.dart';

// Point to external dart files
part './dart/commands.dart';
part './dart/user_interface.dart';
part './dart/resize.dart';
part './dart/input.dart';
part './dart/loader.dart';
part './dart/display.dart';

// setup the Stage and RenderLoop 
xl.Stage stage = new xl.Stage('gamescreen', querySelector('#GameScreen'));
xl.RenderLoop renderLoop = new xl.RenderLoop()
    ..addStage(stage);

// Define our ResourceManager
xl.ResourceManager resourceManager;

// Define our Dartemis World
dartemis.World world = new dartemis.World();

// Define our game_loop
GameLoopHtml gameLoop = new GameLoopHtml(querySelector('#GameScreen'))
  ..onUpdate = ((gameLoop) {loop();})
  ..onRender = ((gameLoop) {render();});

// Start the Game, see 'cou.dart' for 'game()'
main() {
  game();

}




