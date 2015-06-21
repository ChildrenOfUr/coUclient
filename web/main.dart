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
import 'package:cou_auction_house/auction_house/encodes.dart';
import 'package:couclient/components/mailbox/mail.dart';
import 'package:cou_toolkit/toolkit/slider/slider.dart';
import 'package:cou_login/login/login.dart';
import 'package:paper_elements/paper_radio_group.dart';


// LIBRARIES //
// Used for NumberFormat
import 'package:intl/intl.dart';
// Slack Webhook API
import 'package:slack/html/slack.dart' as slack;
// SoundCloud Helper
import 'package:scproxy/scproxy.dart';
// Audio and Graphics
import 'package:gorgon/gorgon.dart'; // for Webaudio api
import 'package:dnd/dnd.dart'; //for dragging items into vendor interface
// Asset Loading
import 'package:libld/libld.dart'; // Nice and simple asset loading.
// Event Bus and Pumps // for more infomation see '/doc/pumps.md'
import 'package:pump/pump.dart';

import 'package:couclient/configs.dart';

import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/mapper_factory.dart';

// SYSTEMS MODULES //
part 'package:couclient/src/systems/clock.dart';
part 'package:couclient/src/systems/weather.dart';
part 'package:couclient/src/systems/commands.dart';
part 'package:couclient/src/game/input.dart';
part 'package:couclient/src/game/joystick.dart';
part 'package:couclient/src/systems/util.dart';

// NETWORKING MODULES //
part 'package:couclient/src/network/chat.dart';
part 'package:couclient/src/network/streetservice.dart';
part 'package:couclient/src/network/auth.dart';
part 'package:couclient/src/network/multiplayer.dart';
part 'package:couclient/src/network/metabolics.dart';

// UI/UX MODULES //
part 'package:couclient/src/display/view.dart';
part 'package:couclient/src/display/chatpanel.dart';
part 'package:couclient/src/display/meters.dart';
part 'package:couclient/src/display/toast.dart';
part 'package:couclient/src/systems/audio.dart';
part 'package:couclient/src/display/render.dart';
part 'package:couclient/src/display/loop.dart';

//  WINDOW MODULES //
part 'package:couclient/src/display/windows.dart';
part 'package:couclient/src/display/overlay.dart';
part 'package:couclient/src/display/windows/settings_window.dart';
part 'package:couclient/src/display/windows/bag_window.dart';
part 'package:couclient/src/display/windows/bug_window.dart';
part 'package:couclient/src/display/windows/map_window.dart';
part 'package:couclient/src/display/windows/motd_window.dart';
part 'package:couclient/src/display/windows/vendor_window.dart';
part 'package:couclient/src/display/windows/go_window.dart';
part 'package:couclient/src/display/windows/calendar_window.dart';
part 'package:couclient/src/display/windows/shrine_window.dart';

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
part 'package:couclient/src/game/street.dart';
part 'package:couclient/src/game/entities/quoin.dart';
part 'package:couclient/src/game/entities/grounditem.dart';
part 'package:couclient/src/game/entities/street_spirit.dart';

// UI PIECES //
part 'package:couclient/src/display/ui_templates/interactions_menu.dart';
part 'package:couclient/src/display/ui_templates/right_click_menu.dart';

// Globals //
Storage sessionStorage = window.sessionStorage;
Storage localStorage = window.localStorage;
Random random = new Random();
NumberFormat commaFormatter = new NumberFormat("#,###");
SoundManager audio;
WeatherManager weather;
InputManager inputManager;
WindowManager windowManager;
CommandManager commandManager;
AuthManager auth;
Game game;
DateTime startTime;

bool get hasTouchSupport => context.callMethod('hasTouchSupport');

void main()
{
	//if the device is capable of touch events, assume the touch ui
	//unless the user has explicitly turned it off in the options
	if(!hasTouchSupport)
	{
		print('device does not have touch support, turning off mobile style');
		(querySelector("#MobileStyle") as StyleElement).disabled = true;
	}

	//make sure the application cache is up to date
	handleAppCache();

	//read configs
	Configs.init().then((_)
	{
		startTime = new DateTime.now();
		bootstrapMapper();
    	initPolymer();
	});
}

@whenPolymerReady
initMethod()
{
	view = new UserInterface();
	audio = new SoundManager();
	windowManager = new WindowManager();
	auth = new AuthManager();

	// System
	new ClockManager();
	new CommandManager();
}

void handleAppCache()
{
	if(window.applicationCache.status == ApplicationCache.UPDATEREADY)
	{
		log('Application cache updated, swapping and reloading page');
        print('Application cache updated, swapping and reloading page');
	    window.applicationCache.swapCache();
	    window.location.reload();
	    return;
	}

	window.applicationCache.onUpdateReady.first.then((_) => handleAppCache());
}