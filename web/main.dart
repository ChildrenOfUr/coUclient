library couclient;
/*
 *  THE CHILDREN OF UR WEBCLIENT
 *  http://www.childrenofur.com
*/

// DART //
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:js';
// (unused) // import 'dart:profiler';


// POLYMER COMPONENTS //
import 'package:polymer/polymer.dart';
import 'package:couclient/components/mailbox/mailbox.dart';
import 'package:cou_toolkit/toolkit/slider/slider.dart';
import 'package:cou_login/login/login.dart';
import 'package:paper_elements/paper_radio_group.dart';

import 'package:couclient/src/network/metabolics.dart';

// LIBRARIES //
// Used for NumberFormat
import 'package:intl/intl.dart';
// Slack Webhook API
import 'package:slack/html/slack.dart' as slack;
// SoundCloud Helper
import 'package:scproxy/scproxy.dart';
// Audio and Graphics
import 'package:gorgon/gorgon.dart';
// for Webaudio api
import 'package:dnd/dnd.dart';
//for dragging items into vendor interface
// Asset Loading
import 'package:libld/libld.dart';
// Nice and simple asset loading.
// Event Bus and Pumps // for more infomation see '/doc/pumps.md'
import 'package:transmit/transmit.dart';
//converting JSON to Dart objects and back
import 'package:jsonx/jsonx.dart';

import 'package:couclient/configs.dart';

import 'package:browser_detect/browser_detect.dart';

export 'package:polymer/init.dart';

// SYSTEMS MODULES //
part 'package:couclient/src/systems/clock.dart';
part 'package:couclient/src/systems/gps.dart';
part 'package:couclient/src/systems/weather.dart';
part 'package:couclient/src/systems/commands.dart';
part 'package:couclient/src/game/input.dart';
part 'package:couclient/src/game/joystick.dart';
part 'package:couclient/src/systems/util.dart';
part 'package:couclient/src/display/gps_display.dart';

// NETWORKING MODULES //
part 'package:couclient/src/network/chat.dart';
part 'package:couclient/src/network/streetservice.dart';
part 'package:couclient/src/network/auth.dart';
part 'package:couclient/src/network/server_interop/so_chat.dart';
part 'package:couclient/src/network/server_interop/so_item.dart';
part 'package:couclient/src/network/server_interop/so_player.dart';
part 'package:couclient/src/network/server_interop/so_street.dart';
part 'package:couclient/src/network/server_interop/so_multiplayer.dart';
part 'package:couclient/src/network/item_action.dart';
part 'package:couclient/src/network/metabolics_service.dart';

// UI/UX MODULES //
part 'package:couclient/src/display/view.dart';
part 'package:couclient/src/display/chatpanel.dart';
part 'package:couclient/src/display/meters.dart';
part 'package:couclient/src/display/toast.dart';
part 'package:couclient/src/systems/audio.dart';
part 'package:couclient/src/display/render.dart';
part 'package:couclient/src/display/loop.dart';
part 'package:couclient/src/display/information_display.dart';

//  WINDOW MODULES //
part 'package:couclient/src/display/windows/windows.dart';
part 'package:couclient/src/display/windows/settings_window.dart';
part 'package:couclient/src/display/windows/bag_window.dart';
part 'package:couclient/src/display/windows/bug_window.dart';
part 'package:couclient/src/display/windows/map_window.dart';
part 'package:couclient/src/display/windows/motd_window.dart';
part 'package:couclient/src/display/windows/vendor_window.dart';
part 'package:couclient/src/display/windows/go_window.dart';
part 'package:couclient/src/display/windows/calendar_window.dart';
part 'package:couclient/src/display/windows/shrine_window.dart';
part 'package:couclient/src/display/windows/rock_window.dart';
part 'package:couclient/src/display/windows/item_window.dart';
part 'package:couclient/src/display/windows/emoticon_picker.dart';
part 'package:couclient/src/display/windows/useitem_window.dart';

// OVERLAYS //
part 'package:couclient/src/display/overlays/overlay.dart';
part 'package:couclient/src/display/overlays/newdayscreen.dart';
part 'package:couclient/src/display/overlays/imgmenu.dart';
part 'package:couclient/src/display/overlays/levelup.dart';

// WIDGET MODULES //
part 'package:couclient/src/display/widgets/volumeslider.dart';
part 'package:couclient/src/display/widgets/soundcloud.dart';

// STREET RENDERING MODULES //
part 'package:couclient/src/display/render/camera.dart';
part 'package:couclient/src/display/render/deco.dart';
part 'package:couclient/src/display/render/ladder.dart';
part 'package:couclient/src/display/render/wall.dart';
part 'package:couclient/src/display/render/platform.dart';
part 'package:couclient/src/display/render/signpost.dart';
part 'package:couclient/src/display/render/collision_lines_debug.dart';
part 'package:couclient/src/network/mapdata.dart';
part 'package:couclient/src/display/render/worldmap.dart';
part 'package:couclient/src/display/render/maps_data.dart';

// GAME MODULES //
part 'package:couclient/src/game/game.dart';
part 'package:couclient/src/game/entities/player.dart';
part 'package:couclient/src/game/animation.dart';
part 'package:couclient/src/game/chat_bubble.dart';
part 'package:couclient/src/game/action_bubble.dart';
part 'package:couclient/src/game/entities/entity.dart';
part 'package:couclient/src/game/entities/wormhole.dart';
part 'package:couclient/src/game/entities/npc.dart';
part 'package:couclient/src/game/entities/plant.dart';
part 'package:couclient/src/game/entities/door.dart';
part 'package:couclient/src/game/street.dart';
part 'package:couclient/src/game/entities/quoin.dart';
part 'package:couclient/src/game/entities/grounditem.dart';
part 'package:couclient/src/game/entities/street_spirit.dart';

// UI PIECES //
part 'package:couclient/src/display/ui_templates/interactions_menu.dart';
part 'package:couclient/src/display/ui_templates/right_click_menu.dart';
part 'package:couclient/src/display/ui_templates/howmany.dart';
part 'package:couclient/src/display/minimap.dart';

// Globals //
Storage sessionStorage = window.sessionStorage;
Storage localStorage = window.localStorage;
Random random = new Random();
MapWindow mapWindow;
NumberFormat commaFormatter = new NumberFormat("#,###");
SoundManager audio;
WeatherManager weather;
InputManager inputManager;
WindowManager windowManager;
CommandManager commandManager;
AuthManager auth;
Game game;
DateTime startTime;
Minimap minimap;
GpsIndicator gpsIndicator = new GpsIndicator();
final String rsToken = "ud6He9TXcpyOEByE944g";
MapData mapData;

bool get hasTouchSupport => context.callMethod('hasTouchSupport');

@whenPolymerReady
afterPolymer() async {

  // Don't try to load the game in an unsupported browser
  // They will continue to see the error message
  if (browser.isIe || browser.isSafari) return;

  // Show the loading screen
  querySelector("#browser-error").hidden = true;
  querySelector("#loading").hidden = false;

  // Decide which UI to use
  checkMedia();

  //make sure the application cache is up to date
  handleAppCache();

  //read configs
  await Configs.init();
  startTime = new DateTime.now();
  view = new UserInterface();
  audio = new SoundManager();
  windowManager = new WindowManager();
  auth = new AuthManager();
  minimap = new Minimap();
  GPS.initWorldGraph();

  // Download the latest map data
  mapData = await new MapData()
    ..init();

  // System
  new ClockManager();
  new CommandManager();

  // Watch for Collision-Triggered teleporters
  Wormhole.init();
}

// Set up resource/asset caching

void handleAppCache() {
  if (window.applicationCache.status == ApplicationCache.UPDATEREADY) {
    logmessage('[Loader] Application cache updated, swapping and reloading page');
    window.applicationCache.swapCache();
    window.location.reload();
    return;
  }

  window.applicationCache.onUpdateReady.first.then((_) => handleAppCache());
}

// Manage different device types

enum ViewportMedia {
  DESKTOP,
  TABLET,
  MOBILE
}

void checkMedia() {
  // If the device is capable of touch events, assume the touch ui
  // unless the user has explicitly turned it off in the options.
  if (localStorage['interface'] == 'desktop') {
    // desktop already preferred
    setStyle(ViewportMedia.DESKTOP);
  } else if (localStorage['interface'] == 'mobile') {
    // mobile already preferred
    setStyle(ViewportMedia.MOBILE);
  } else if (hasTouchSupport) {
    // no preference, touch support, use mobile view
    setStyle(ViewportMedia.MOBILE);
    logmessage(
        "[Loader] Device has touch support, using mobile layout. "
        "Run /desktop in Global Chat to use the desktop view."
    );
  } else if (!hasTouchSupport) {
    // no preference, no touch support, use desktop view
    setStyle(ViewportMedia.DESKTOP);
  }
}

void setStyle(ViewportMedia style) {
  /**
   * The stylesheets are set up so that the desktop styles are always applied,
   * the tablet styles are applied to tablets and phones, and the mobile style
   * is only applied to phones:
   *
   * | Viewport | Desktop | Tablet  | Mobile  |
   * |----------|---------|---------|---------|
   * | Desktop  | Applied |         |         |
   * | Tablet   | Applied | Applied |         |
   * | Mobile   | Applied | Applied | Applied |
   *
   * Tablet provides touchscreen functionality and minimal optimization
   * for a slightly smaller screen, while mobile prepares the UI
   * for a very small viewport.
   */

  StyleElement mobile = querySelector("#MobileStyle");
  StyleElement tablet = querySelector("#TabletStyle");

  switch (style) {
    case ViewportMedia.DESKTOP:
      mobile.disabled = true;
      tablet.disabled = true;
      break;

    case ViewportMedia.TABLET:
      mobile.disabled = true;
      tablet.disabled = false;
      break;

    case ViewportMedia.MOBILE:
      mobile.disabled = false;
      tablet.disabled = false;
      break;
  }

  if (style == ViewportMedia.TABLET || style == ViewportMedia.MOBILE) {
    querySelectorAll("html, body").onScroll.listen((Event e) {
      (e.target as Element).scrollLeft = 0;
      print(e.target);
    });
  }
}