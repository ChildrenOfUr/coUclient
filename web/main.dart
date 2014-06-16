library couclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart'; //used for NumberFormat
import 'package:slack/slack_html.dart' as slack; // Access to the slack webhook api

// Import our coU libraries.
import 'package:glitchTime/glitch-time.dart';// The script that spits out time!
import 'package:scproxy/scproxy.dart'; // Paul's soundcloud bootstrap
import 'package:libld/libld.dart'; // Nice and simple asset loading.

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
part 'dart/engine/animation.dart';
part 'dart/engine/multiplayer.dart';


// Game parts
part 'dart/street.dart';
part 'dart/player.dart';
part 'dart/npc.dart';
part 'dart/quoin.dart';

//localStorage to use throughout app
Storage localStorage = app.local;

// Declare our game_loop
double lastTime = 0.0;
DateTime startTime = new DateTime.now();

gameLoop(num delta)
{
	double dt = (delta-lastTime)/1000;
	loop(dt);
	render();
	lastTime = delta;
	//uncomment next line and comment 2 lines from here for max fps
	//Timer.run(() => gameLoop(new DateTime.now().difference(startTime).inMilliseconds.toDouble()));
	window.animationFrame.then(gameLoop);
}