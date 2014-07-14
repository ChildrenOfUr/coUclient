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

// LIBRARIES //
// Used for NumberFormat
import 'package:intl/intl.dart' show NumberFormat; 
// Slack Webhook API
import 'package:slack/slack_html.dart' as slack;
// SoundCloud Helper
import 'package:scproxy/scproxy.dart';
// Asset Loading
import 'package:libld/libld.dart'; // Nice and simple asset loading.
// Event Bus and Pumps // for more infomation see '/doc/pumps.md'
import 'package:pump/pump.dart';

// SYSTEMS MODULES //
part 'package:couclient/src/systems/clock.dart';
part 'package:couclient/src/systems/debug.dart';
part 'package:couclient/src/systems/events.dart';
part 'package:couclient/src/systems/commands.dart';

// NETWORKING MODULES //
part 'package:couclient/src/network/chat.dart';
part 'package:couclient/src/network/multiplayer.dart';

// UI/UX MODULES
part 'package:couclient/src/display/ui.dart';
part 'package:couclient/src/display/audio.dart';
part 'package:couclient/src/display/chat_bubble.dart';

// GAME MODULES //
part 'package:couclient/src/game/game.dart';
part 'package:couclient/src/game/player.dart';
part 'package:couclient/src/game/npc.dart';
part 'package:couclient/src/game/street.dart';
part 'package:couclient/src/game/quoin.dart';


// API KEYS // for more infomation see '/doc/api.md'
//part 'API_KEYS.dart';


// GAME ENTRY //
main() {
  app.init();
  new ChatManager();
  new ClockManager();
  new DebugManager();
  app.update();  
}
