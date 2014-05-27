library couclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart'; //used for NumberFormat

// Import our coU libraries.
import 'package:glitchTime/glitch-time.dart';// The script that spits out time!
import 'package:scproxy/scproxy.dart'; // Paul's soundcloud bootstrap
import 'package:libld/libld.dart'; // Nice and simple asset loading.

// Engine parts
part 'dart/engine/ui.dart';
part 'dart/engine/audio.dart';

main()
{
  display.init();
  gameLoop(0.0);  
}

// Declare our game_loop
double lastTime = 0.0;
gameLoop(num delta)
{
double dt = (delta-lastTime)/1000;
lastTime = delta;

// GAME LOOP


//RENDER LOOP
display.update();

window.animationFrame.then(gameLoop);
}