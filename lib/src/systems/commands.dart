part of couclient;

// debugging service
Service errService = new Service(['err', 'debug'], (event) {
	transmit('toast', 'Debug: ${event.content}');
});


// List of commandable functions
Map<String, Function> COMMANDS = {};

class CommandManager {
	CommandManager() {

		COMMANDS['playsound'] = (noun) {
			transmit('playSound', noun);
		};

		COMMANDS['playsong'] = (noun) {
			transmit('playSong', noun);
		};

		COMMANDS
      ..['minimap'] = updateMinimap
			..['interface'] = changeInterface
			..['setname'] = setName
			..['go'] = setLocationCommand
			..['setlocation'] = setLocationCommand
			..['tp'] = setLocationCommand
			..['toast'] = toast
			..['buff'] = buff
			..['collisions'] = toggleCollisionLines
			..['physics'] = togglePhysics
			..['log'] = log
			..['setcurrants'] = setCurrants
			..['settime'] = setTime
			..['setweather'] = setWeather;
	}
}


/////////////////////////////////// COMMAND FUNCTIONS /////////////////////////////////////////////

bool parseCommand(String command) {
	// Getting the important data
	String verb = command.split(" ")[0].toLowerCase().replaceFirst('/', '');

	String noun = command.split(' ').skip(1).join(' ');

	if(COMMANDS.containsKey(verb)) {
		COMMANDS[verb](noun);
		log('Parsed valid command : "$command"');
		return true;
	} else {
		return false;
	}
}

// COMMAND FUNCTIONS BELOW  //

// Changes the clock for the current player

updateMinimap(var nothing) {
  minimap.updateObjects();
}

setTime(String noun) {
	transmit('timeUpdateFake',[noun]);
	if(noun == '6:00am') {
		transmit('newDayFake',null);
	}
}

setWeather(String noun) {
	if(noun == 'snow') {
		transmit('setWeatherFake',{'state':WeatherState.SNOWING.index});
	} else if(noun == 'rain') {
		transmit('setWeatherFake',{'state':WeatherState.RAINING.index});
	} else if(noun == 'clear') {
		transmit('setWeatherFake', {'state':WeatherState.CLEAR.index});
	}
}

// Changes the name of the current player

setName(String noun) {
	// Fix Name
	String newName = noun.replaceAll(" ", "_");
	String oldName = game.username;

	// Is it appropriate?
	if(containsBadCharacter(newName)) {
		transmit('chatEvent', {
			'channel': 'Global Chat',
			'message': "Sorry, you can't use the following characters in your name<br>~ ! @ \$ % ^ & * ( ) + = , . / ' ; : \" ? > < [ ] \ { } | ` #"
		});
		return;
	}

	game.username = noun;
	view.meters.updateNameDisplay();

	// Prepare Server Message
	Map map = new Map();
	map["statusMessage"] = "changeName";
	map["username"] = oldName;
	map["newUsername"] = noun;
	map["channel"] = 'Global Chat';

	// Send new name to server
	transmit('outgoingChatEvent', map);

	toast('Name changed to ' + noun);
}

// Tests if the username is valid

bool containsBadCharacter(String newName) {
	List<String> badChars = "! @ \$ % ^ & * ( ) + = , . / ' ; : \" ? > < [ ] \\ { } | ` #".split(" ");
	for(String char in badChars) {
		if(newName.contains(char)) return true;
	}

	return false;
}

// Teleports the player

setLocationCommand(String noun) {
	playerTeleFrom = "console";
	noun = noun.trim();
	view.mapLoadingScreen.className = "MapLoadingScreenIn";
	view.mapLoadingScreen.style.opacity = "1.0";
  minimap.containerE.hidden = true;
	//changes first letter to match revdancatt's code - only if it starts with an L
	if(noun.startsWith("L")) {
		noun = noun.replaceFirst("L", "G");
	}
	streetService.requestStreet(noun);
}

// Shows or hides collision lines on platforms

toggleCollisionLines(var nothing) {
	if(showCollisionLines) {
		showCollisionLines = false;
		hideLineCanvas();
		toast('Collision lines hidden');
	}
	else {
		showCollisionLines = true;
		showLineCanvas();
		toast('Collision lines shown');
	}
}

// Toggles physics for the current player

togglePhysics(var nothing) {
	if(CurrentPlayer.doPhysicsApply) {
		CurrentPlayer.doPhysicsApply = false;
		toast('Physics no longer apply to you');
	} else {
		CurrentPlayer.doPhysicsApply = true;
		toast('Physics apply to you');
	}
}

// Allows switching to desktop view on touchscreen laptops

changeInterface(var type) {
	if (type == "desktop") {
		(querySelector("#MobileStyle") as StyleElement).disabled = true;
		localStorage['interface'] = 'desktop';
		toast('Switched to desktop view');
	} else if (type == "mobile") {
		(querySelector("#MobileStyle") as StyleElement).disabled = false;
		localStorage['interface'] = 'mobile';
		toast('Switched to mobile view');
	} else {
		toast('Interface type must be either desktop or mobile, ' + type + ' is invalid');
	}
}

// Explain why /setcurrants won't work

setCurrants(var amt) {
	toast('/setcurrants ' + amt + ' does not work anymore because you can collect quoins now. Ask a dev nicely and they may give you some starting-off money.');
}