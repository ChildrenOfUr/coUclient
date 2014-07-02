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

import 'package:intl/intl.dart'; //used for NumberFormat

// Slack Webhook API
import 'package:slack/slack_html.dart' as slack;

// SoundCloud Bootstrap
import 'package:scproxy/scproxy.dart';

// Asset Loading
import 'package:libld/libld.dart'; // Nice and simple asset loading.

// Event Bus
import 'package:venti/venti.dart';

// Glitchen Ur Clock
part 'package:couclient/src/clock.dart';

// GAME MODULES //
part 'package:couclient/src/ui.dart';
part 'package:couclient/src/audio.dart';


// API KEYS // for more infomation see '/doc/api.md'
//part 'API_KEYS.dart';


main() {
  app.init();
  app.update();
}
