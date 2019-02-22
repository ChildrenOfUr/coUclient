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
import 'dart:collection';
// (unused) // import 'dart:profiler';

// Libraries

import 'package:couclient/configs.dart'; // Global data
import 'package:couclient/src/network/server_interop/itemdef.dart'; // Items
import 'package:coUemoticons/bin/main.dart' as emoji; // Emoticons
import 'package:dnd/dnd.dart'; // Webaudio api
import 'package:gorgon/gorgon.dart'; // Audio and graphics
import 'package:intl/intl.dart'; // Used for NumberFormat
import 'package:json_annotation/json_annotation.dart'; // Dart object <-> JSON conversions
import 'package:libld/libld.dart'; // Asset loading
import 'package:scproxy/scproxy.dart'; // SoundCloud helper
import 'package:transmit/transmit.dart'; // Event bus
import "package:xml/xml.dart" as XML; // Blog post checking
import 'package:firebase/firebase.dart' as firebase; // Login
import 'package:angular/angular.dart';
import 'package:cou_login/cou_login/cou_login.template.dart' as loginComponent; // ignore: uri_has_not_been_generated

// Systems

part 'package:couclient/src/network/metabolics.dart'; // Metabolics display
part 'package:couclient/src/display/gps_display.dart';
part 'package:couclient/src/game/input.dart';
part 'package:couclient/src/game/joystick.dart';
part 'package:couclient/src/systems/clock.dart';
part 'package:couclient/src/systems/commands.dart';
part 'package:couclient/src/systems/gps.dart';
part 'package:couclient/src/systems/homestreet.dart';
part 'package:couclient/src/systems/quest_manager.dart';
part 'package:couclient/src/systems/util.dart';
part 'package:couclient/src/systems/weather.dart';

// Networking

part 'package:couclient/src/network/auth.dart';
part 'package:couclient/src/network/chat.dart';
part 'package:couclient/src/network/constants.dart';
part 'package:couclient/src/network/item_action.dart';
part 'package:couclient/src/network/metabolics_service.dart';
part 'package:couclient/src/network/server_interop/inventory.dart';
part 'package:couclient/src/network/server_interop/so_chat.dart';
part 'package:couclient/src/network/server_interop/so_item.dart';
part 'package:couclient/src/network/server_interop/so_multiplayer.dart';
part 'package:couclient/src/network/server_interop/so_player.dart';
part 'package:couclient/src/network/server_interop/so_street.dart';
part 'package:couclient/src/network/streetservice.dart';

// UI

part 'package:couclient/src/display/buff.dart';
part 'package:couclient/src/display/chatmessage.dart';
part 'package:couclient/src/display/chatpanel.dart';
part 'package:couclient/src/display/information_display.dart';
part 'package:couclient/src/display/inventory.dart';
part 'package:couclient/src/display/loop.dart';
part 'package:couclient/src/display/meters.dart';
part 'package:couclient/src/display/minimap.dart';
part 'package:couclient/src/display/render.dart';
part 'package:couclient/src/display/toast.dart';
part 'package:couclient/src/display/ui_templates/howmany.dart';
part 'package:couclient/src/display/ui_templates/interactions_menu.dart';
part 'package:couclient/src/display/ui_templates/item_chooser.dart';
part 'package:couclient/src/display/ui_templates/menu_keys.dart';
part 'package:couclient/src/display/ui_templates/right_click_menu.dart';
part 'package:couclient/src/display/view.dart';
part 'package:couclient/src/systems/audio.dart';
part "package:couclient/src/display/blog_notifier.dart";
part "package:couclient/src/display/darkui.dart";
part "package:couclient/src/display/overlays/text_anim.dart";

// Windows

part 'package:couclient/src/display/windows/achievements_window.dart';
part 'package:couclient/src/display/windows/add_friend_window.dart';
part 'package:couclient/src/display/windows/avatar_window.dart';
part 'package:couclient/src/display/windows/bag_window.dart';
part 'package:couclient/src/display/windows/bug_window.dart';
part 'package:couclient/src/display/windows/calendar_window.dart';
part 'package:couclient/src/display/windows/change_username_window.dart';
part 'package:couclient/src/display/windows/emoticon_picker.dart';
part 'package:couclient/src/display/windows/go_window.dart';
part 'package:couclient/src/display/windows/inv_search_window.dart';
part 'package:couclient/src/display/windows/item_window.dart';
part 'package:couclient/src/display/windows/mailbox_window.dart';
part 'package:couclient/src/display/windows/map_window.dart';
part 'package:couclient/src/display/windows/motd_window.dart';
part 'package:couclient/src/display/windows/note_window.dart';
part 'package:couclient/src/display/windows/quest_maker_window.dart';
part 'package:couclient/src/display/windows/questlog_window.dart';
part 'package:couclient/src/display/windows/prompt_str_window.dart';
part 'package:couclient/src/display/windows/rock_window.dart';
part 'package:couclient/src/display/windows/settings_window.dart';
part 'package:couclient/src/display/windows/shrine_window.dart';
part 'package:couclient/src/display/windows/useitem_window.dart';
part 'package:couclient/src/display/windows/vendor_window.dart';
part 'package:couclient/src/display/windows/weather_window.dart';
part 'package:couclient/src/display/windows/windows.dart';

// Overlays

part 'package:couclient/src/display/overlays/achievementget.dart';
part 'package:couclient/src/display/overlays/imgmenu.dart';
part 'package:couclient/src/display/overlays/levelup.dart';
part 'package:couclient/src/display/overlays/module_skills.dart';
part 'package:couclient/src/display/overlays/newdayscreen.dart';
part 'package:couclient/src/display/overlays/overlay.dart';
part 'package:couclient/src/display/overlays/streetloadingscreen.dart';

// Widgets

part 'package:couclient/src/display/widgets/soundcloud.dart';
part 'package:couclient/src/display/widgets/volumeslider.dart';

// Street rendering

part 'package:couclient/src/display/render/camera.dart';
part 'package:couclient/src/display/render/collision_lines_debug.dart';
part 'package:couclient/src/display/render/deco.dart';
part 'package:couclient/src/display/render/ladder.dart';
part 'package:couclient/src/display/render/platform.dart';
part 'package:couclient/src/display/render/signpost.dart';
part 'package:couclient/src/display/render/wall.dart';
part 'package:couclient/src/network/mapdata.dart';

// Game rendering

part 'package:couclient/src/game/action_bubble.dart';
part 'package:couclient/src/game/animation.dart';
part 'package:couclient/src/game/chat_bubble.dart';
part 'package:couclient/src/game/entities/door.dart';
part 'package:couclient/src/game/entities/entity.dart';
part 'package:couclient/src/game/entities/grounditem.dart';
part 'package:couclient/src/game/entities/npc.dart';
part 'package:couclient/src/game/entities/physics.dart';
part 'package:couclient/src/game/entities/plant.dart';
part 'package:couclient/src/game/entities/player.dart';
part 'package:couclient/src/game/entities/quoin.dart';
part 'package:couclient/src/game/entities/wormhole.dart';
part 'package:couclient/src/game/game.dart';
part 'package:couclient/src/game/street.dart';

// Built classes
part 'main.g.dart';

// Globals

final GpsIndicator gpsIndicator = new GpsIndicator(); // GPS status display
final NumberFormat commaFormatter = new NumberFormat("#,###"); // Comma format
final Random random = new Random(); // Random object
final Storage localStorage = window.localStorage; // Local storage
final Storage sessionStorage = window.sessionStorage; // Session storage
final String rsToken = "ud6He9TXcpyOEByE944g"; // Token for redstone

Constants constants; // Server-defined constants
MapData mapData; // Map, street, and hub metadata

AuthManager auth; // Auth server interop
CommandManager commandManager; // Command input
DateTime startTime; // Track times in log messages
Game game; // Game object
InputManager inputManager; // Input handler
MapWindow mapWindow; // Single-instance map window
Minimap minimap; // Minimap object
QuestManager questManager; // Quest manager
SoundManager audio; // Audio manager
WeatherManager weather; // Weather manager
WindowManager windowManager; // Window manager

bool get hasTouchSupport => context.callMethod("hasTouchSupport");

Future main() async {
	// Don't try to load the game in an unsupported browser
	// They will continue to see the error message
	if (knownUnsupportedBrowser()) return;

	// Show the loading screen
	querySelector("#browser-error").hidden = true;
	querySelector("#loading").hidden = false;

	// Decide which UI to use
	checkMedia();

	// Start uptime counter
	startTime = new DateTime.now();

	// Gotta catch 'em all!
	startConsoleErrorLogging();

	try {
    // initialize firebase and the login component
    firebase.initializeApp(
        apiKey: 'AIzaSyCTXgszjO2AJNLTZUMYp2ZtFAmVLS2G6J4',
        authDomain: 'blinding-fire-920.firebaseapp.com',
    );
    runApp(loginComponent.CouLoginNgFactory);

		// Load server connection configuration
		await Configs.init();

		// Download the latest map data
		mapData = await MapData.download();

		// Make sure we have an up-to-date (1 day expiration) item cache
		await Item.loadItems();

		// Download constants
		constants = await Constants.download();
	} catch (e, st) {
		logmessage("Error loading server data: $e\n$st");
		serverDown = true;
	}

	try {
		// init ui
		view = new UserInterface();
		audio = new SoundManager();
		windowManager = new WindowManager();
		auth = new AuthManager();
		minimap = new Minimap();
		GPS.initWorldGraph();
		InvDragging.init();
	} catch (e, st) {
		logmessage("Error initializing interface: $e\n$st");
		new Toast(
			"OH NO! There was an error, so you should click here to reload."
			" If you see this several times, please file a bug report.",
			onClick: (_) => hardReload()
		);
	}

	// System
	new ClockManager();
	new CommandManager();

	// Watch for Collision-Triggered teleporters
	Wormhole.init();

	// Check the blog
	BlogNotifier.refresh();
}

// Clear cache with JS reload

void hardReload() {
	context["location"].callMethod("reload", [true]);
}

// Manage different device types

enum ViewportMedia {
	DESKTOP,
	TABLET,
	MOBILE
}

bool knownUnsupportedBrowser() =>
	window.navigator.appName.contains("Microsoft") ||
	window.navigator.appVersion.contains("Trident") ||
	window.navigator.appVersion.contains("Edge") ||
	window.navigator.vendor.contains('Apple');

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
				"Run /interface desktop in chat to use the desktop view."
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

	LinkElement mobile = querySelector("#MobileStyle");
	LinkElement tablet = querySelector("#TabletStyle");

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
			//print(e.target);
		});
	}
}
