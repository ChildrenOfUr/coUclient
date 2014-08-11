library couclient;
/*
 *  THE CHILDREN OF UR WEBCLIENT
 *  http://www.childrenofur.com
 * 
 * 
*/

// DART //
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:math' show Random;

// LIBRARIES //
// Used for NumberFormat
import 'package:intl/intl.dart' show NumberFormat;
// Slack Webhook API
import 'package:slack/slack_html.dart' as slack;
// SoundCloud Helper
import 'package:scproxy/scproxy.dart';
// Audio and Graphics
import 'package:gorgon/gorgon.dart'; // for Webaudio api
// Asset Loading
import 'package:libld/libld.dart'; // Nice and simple asset loading.
// Event Bus and Pumps // for more infomation see '/doc/pumps.md'
import 'package:pump/pump.dart';

// SYSTEMS MODULES //
part 'package:couclient/src/systems/clock.dart';
part 'package:couclient/src/systems/debug.dart';
part 'package:couclient/src/systems/events.dart';
part 'package:couclient/src/systems/commands.dart';
part 'package:couclient/src/game/input.dart';

// NETWORKING MODULES //
part 'package:couclient/src/network/chat.dart';
part 'package:couclient/src/network/multiplayer.dart';

// UI/UX MODULES //
part 'package:couclient/src/display/userinterface.dart';
part 'package:couclient/src/display/chatpanel.dart';
part 'package:couclient/src/display/windows.dart';
part 'package:couclient/src/display/meters.dart';
part 'package:couclient/src/display/audio.dart';

// STREET RENDERING MODULES //


// GAME MODULES //
part 'package:couclient/src/game/game.dart';
part 'package:couclient/src/game/player.dart';
part 'package:couclient/src/game/npc.dart';
part 'package:couclient/src/game/street.dart';
part 'package:couclient/src/game/quoin.dart';


// API KEYS // for more infomation see '/doc/api.md'
part 'package:couclient/API_KEYS.dart';

// Globals //
Storage session = window.sessionStorage;
Storage local = window.localStorage;
Random random = new Random();
NumberFormat commaFormatter = new NumberFormat("#,###");

// GAME ENTRY //
Game game = new Game();

main() {
  // System
  new DebugManager();
  new ClockManager();
  new CommandManager();
  
  // Networking
  new NetChatManager();
  
  // UI/UX
  new SoundManager();
  new MeterManager();
  new WindowManager();
  new InputManager();
  

  // Test Information
  ui.username = 'NewUITest';
  new Moment('StartChat','Global Chat');
  ui.update();
  
  // This tells the game to put the start button on the loading page.
  new Moment('DoneLoading',null);  
  
}
