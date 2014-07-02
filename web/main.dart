library couclient;
/*
 *  THE CHILDREN OF UR WEBCLIENT
 *  http://www.childrenofur.com
 *  
 * 
 * 
 * 
 * 
 * 
 * 
*/

import 'dart:html';
import 'dart:async';
import 'dart:convert';

// Used for NumberFormat
import 'package:intl/intl.dart' show NumberFormat; 

// Slack Webhook API
import 'package:slack/slack_html.dart' as slack;

// SoundCloud Bootstrap
import 'package:scproxy/scproxy.dart';

// Asset Loading
import 'package:libld/libld.dart'; // Nice and simple asset loading.

// Event Bus
import 'package:pump/pump.dart';

// Glitchen Ur-Time Clock
part 'package:couclient/src/model/clock.dart';

// GAME MODULES //
part 'package:couclient/src/events.dart';
part 'package:couclient/src/view/ui.dart';
part 'package:couclient/src/view/audio.dart';
part 'package:couclient/src/model/chat.dart';

// API KEYS // for more infomation see '/doc/api.md'
//part 'API_KEYS.dart';

main() {
  app.init();
  new ChatManager();
  new ClockManager();
  new DebugManager();
  app.update();  
}
