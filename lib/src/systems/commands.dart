part of couclient;

// debugging service
Service errService = new Service(['err', 'debug'], (event) {
	transmit('toast', 'Debug: ${event.content}');
});

// List of commandable functions
Map<String, Function> COMMANDS = {};

class CommandManager {
	CommandManager() {
		COMMANDS['help'] = (_) => new Toast(
			'Available commands: ' + COMMANDS.keys.toList().toString().replaceAll('[', '').replaceAll(']', ''));

		COMMANDS
			..['interface'] = changeInterface
			..['ping'] = checkLag
			..['playsong'] = (noun) => transmit('playSong', noun)
			..['playsound'] = (noun) => transmit('playSound', noun)
			..['reload'] = (_) => hardReload();

		if (Configs.testing) {
			COMMANDS
				..['makehome'] = makeHome
				..['gohome'] = goHome
				..['collisions'] = toggleCollisionLines
				..['follow'] = follow
				..['log'] = log
				..['music'] = setMusic
				..['physics'] = togglePhysics
				..['time'] = setTime
				..['tp'] = go
				..['weather'] = setWeather;
		}
	}
}

bool parseCommand(String command) {
	// Getting the important data
	String verb = command.split(' ')[0].toLowerCase().replaceFirst('/', '');

	String noun = command.split(' ').skip(1).join(' ');

	if (COMMANDS.containsKey(verb)) {
		COMMANDS[verb](noun);
		logmessage('[Chat] Parsed valid command: "$command"');
		return true;
	} else {
		return false;
	}
}

// Makes the current street the player's home street
Future makeHome(var options) async {
	options = options.trim();

	String existingHome = await HomeStreet.getForPlayer();
	if (existingHome != null && options != 'replace') {
		new Toast(
			'You already have a home street ($existingHome). '
			'Run "/makehome replace" to delete it and use this street instead. '
			'Any items and entities on your existing street will be deleted!',
			notify: NotifyRule.NO,
			onClick: ({MouseEvent event, String argument}) {
				Chat.localChat.chatInput.value = '/makehome replace';
			}
		);
	} else if (await HomeStreet.setForSelf(currentStreet.tsid)) {
		new Toast(
			'Home street set successfully. Click here or run "/gohome" to visit it.',
			notify: NotifyRule.NO,
			onClick: ({MouseEvent event, String argument}) => goHome()
		);
	} else {
		new Toast('Error setting home street', notify: NotifyRule.NO);
	}
}

// Teleports the player to their home street
Future goHome(var ignored) async {
	String tsid = await HomeStreet.getForPlayer();
	if (tsid == null) {
		new Toast(
			'You don\'t have a home street yet! Run "/makeHome" to get one like this street.',
			notify: NotifyRule.NO,
			onClick: ({MouseEvent event, String argument}) {
				Chat.localChat.chatInput.value = '/makehome';
			}
		);
	} else {
		streetService.requestStreet(tsid);
	}
}

// Allows switching to desktop view on touchscreen laptops
void changeInterface(var type) {
	if (type == 'desktop') {
		(querySelector('#MobileStyle') as StyleElement).disabled = true;
		localStorage['interface'] = 'desktop';
		new Toast('Switched to desktop view');
	} else if (type == 'mobile') {
		(querySelector('#MobileStyle') as StyleElement).disabled = false;
		localStorage['interface'] = 'mobile';
		new Toast('Switched to mobile view');
	} else {
		new Toast('Interface type must be either desktop or mobile, ' + type + ' is invalid');
	}
}

void go(String tsid) {
	tsid = tsid.trim();
	//changes first letter to match revdancatt's code - only if it starts with an L
	if (tsid.startsWith('L')) tsid = tsid.replaceFirst('L', 'G');
	streetService.requestStreet(tsid);
}

void setTime(String noun) {
	transmit('timeUpdateFake', [noun]);
	if (noun == '6:00am') {
		transmit('newDayFake', null);
	}
}

void setWeather(String noun) {
	if (noun == 'snow') {
		transmit('setWeatherFake', {'state':WeatherState.SNOWING.index});
	} else if (noun == 'rain') {
		transmit('setWeatherFake', {'state':WeatherState.RAINING.index});
	} else if (noun == 'clear') {
		transmit('setWeatherFake', {'state':WeatherState.CLEAR.index});
	}
}

void toggleCollisionLines(_) {
	if (showCollisionLines) {
		showCollisionLines = false;
		hideLineCanvas();
		new Toast('Collision lines hidden');
	} else {
		showCollisionLines = true;
		showLineCanvas();
		new Toast('Collision lines shown');
	}
}

void togglePhysics(_) {
	if (CurrentPlayer.doPhysicsApply) {
		CurrentPlayer.doPhysicsApply = false;
		new Toast('Physics no longer apply to you');
	} else {
		CurrentPlayer.doPhysicsApply = true;
		new Toast('Physics apply to you');
	}
}

void setMusic(String song) {
	new Toast('Music set to $song');
	audio.setSong(song);
}

void follow(String player) {
	new Toast(CurrentPlayer.followPlayer(player));
}

Future checkLag([bool silent]) async {
	DateTime start, end, serverCalc, serverTest;

	start = new DateTime.now().toUtc();

	try {
		String response = await HttpRequest.getString(
			'${Configs.http}//${Configs.utilServerAddress}/time/utc')
			.timeout(new Duration(seconds: 1));
		serverTest = DateTime.parse(response);
	} catch (e) {
		if (!silent) {
			new Toast('Ping test failed: $e');
		}
		return -1;
	}

	end = new DateTime.now().toUtc();

	// Midpoint of client times = (end - start) + start
	serverCalc = start.add(end.difference(start));

	Duration ping = serverCalc.difference(serverTest).abs();

	if (!silent) {
		new Toast('Game server ping time was ${ping.inMilliseconds} ms');
	}

	return ping.inMilliseconds;
}