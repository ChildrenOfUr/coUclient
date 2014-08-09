library coUclient;
// Import deps
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart'; //used for NumberFormat

// Import our coU libraries.
import 'package:glitch_time/glitch_time.dart';// The script that spits out time!
import 'package:scproxy/scproxy.dart'; // Paul's soundcloud bootstrap
import 'package:libld/libld.dart'; // Nice and simple asset loading.
import 'package:gorgon/gorgon.dart';
import 'package:dnd/dnd.dart';

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
part 'dart/engine/multiplayer.dart';

// Definitions
part 'dart/engine/def/keycodes.dart';
part 'dart/engine/def/elements.dart';
part 'dart/engine/util.dart';

// Game parts
part 'dart/street.dart';
part 'dart/engine/street_components/camera.dart';
part 'dart/engine/street_components/ladder.dart';
part 'dart/engine/street_components/platform.dart';
part 'dart/engine/street_components/worldmap.dart';
part 'dart/engine/street_components/signpost.dart';
part 'dart/engine/street_components/deco.dart';
part 'dart/maps_data.dart';
part 'dart/player.dart';
part 'dart/chat_bubble.dart';
part 'dart/npc.dart';
part 'dart/quoin.dart';
part 'dart/plant.dart';
part 'dart/entity.dart';

//ui templates (in lieu of <template> being available on some browsers)
part 'dart/ui_templates/vendor_window.dart';
part 'dart/ui_templates/right_click_menu.dart';
part 'dart/ui_templates/interactions_menu.dart';
part 'dart/ui_templates/details_window.dart';
part 'dart/ui_templates/sell_interface.dart';
part 'dart/ui_templates/vendor_shelves.dart';

main()
{
	initialize();
}

//localStorage to use throughout app
Storage localStorage = window.localStorage;

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