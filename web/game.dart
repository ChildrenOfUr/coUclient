library couclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart'; //used for NumberFormat

// Import our coU libraries.
import 'package:glitchTime/glitch-time.dart';// The script that spits out time!
import 'package:scproxy/scproxy.dart'; // Paul's soundcloud bootstrap
import 'package:libld/libld.dart'; // Nice and simple asset loading.

// Engine parts

part 'dart/engine/ui.dart';
part 'dart/engine/audio.dart';

//localStorage to use throughout app
Storage localStorage = window.localStorage;

main()
{
  // initialize the userinterface.
  display.init();  
  load_audio()
  .then((_) => loadSong('firebog'))
  .then((_) => playSong('firebog'));

  
  
  // Begin the GAME!!!
  gameLoop(0.0);
}

// Declare our game_loop
double lastTime = 0.0;
gameLoop(num delta)
{
double dt = (delta-lastTime)/1000;
//  loop(dt);
display.update();
lastTime = delta;
window.animationFrame.then(gameLoop);
}