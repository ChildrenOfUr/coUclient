library coUclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'package:dartemis/dartemis.dart' as dartemis;
import 'package:game_loop/game_loop_html.dart';

// Import our private libraries.
import 'package:coUlib/glitch-time.dart';// The script that spits out time!

// main game entry
part './dart/cou.dart';

// Point to external dart files
part './dart/commands.dart';
part './dart/ui/meters.dart';
part './dart/resize.dart';
part './dart/input.dart';
part './dart/loader.dart';
part './dart/ui/rightclickmenu.dart';


// Define our game_loop loop(s)
GameLoopHtml loop = new GameLoopHtml(query('#GameScreen'));

// Define our Dartemis World
dartemis.World world = new dartemis.World();

// Start the Game
main() {
  game();
}




