library couclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:okeyee/okeyee.dart'; // used for keyboard stuff.
import 'package:intl/intl.dart'; //used for NumberFormat

// Import our coU libraries.
import 'package:glitchTime/glitch-time.dart';// The script that spits out time!
import 'package:streetlib/streetlib.dart'; // rendering streets
import 'package:scproxy/scproxy.dart'; // Paul's soundcloud bootstrap
import 'package:libld/libld.dart'; // Nice and simple asset loading.
import 'package:slack/slack_html.dart' as slack; // Access to the slack webhook api

// Engine parts
part 'dart/engine/ui.dart';
part 'dart/engine/audio.dart';
part 'dart/engine/input.dart';

part 'dart/engine/inventory.dart';

Random r = new Random();
Street currStreet;

main()
{
  app.init();
  input.init();
  app.name = 'Playername';
  
  jsonExtensions.add('street');
  new Asset('./lib/locations/test.street').load()
    .then((Asset a) {
    Street s = new Street(a.get());
    currStreet = s;
    gameLoop(0.0);  
  });  
}

// Declare our game_loop
double lastTime = 0.0;
gameLoop(num delta)
{
double dt = (delta-lastTime)/1000;
lastTime = delta;

// GAME LOOP
currStreet.update();
//RENDER LOOP
app.update();

window.animationFrame.then(gameLoop);
}