library coUclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart'; //used for NumberFormat

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
part 'dart/engine/touchscroller.dart';
part 'dart/engine/animation.dart';

// Game parts
part 'dart/street.dart';
part 'dart/player.dart';
part 'dart/chat_bubble.dart';

//localStorage to use throughout app
Storage localStorage = window.localStorage;

// Declare our game_loop
double lastTime = 0.0;
gameLoop(num delta)
{
	double dt = (delta-lastTime)/1000;
	loop(dt);
	render();
	lastTime = delta;
	window.animationFrame.then(gameLoop);
}