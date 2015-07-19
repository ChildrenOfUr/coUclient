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
			// ENABLED:
			..['interface'] = changeInterface
			// DEPRECATED:
			..['setcurrants'] = setCurrants
			..['setname'] = setName
			..['go'] = setLocationCommand
			..['setlocation'] = setLocationCommand
			..['teleport'] = setLocationCommand
			..['tp'] = setLocationCommand
		  // REMOVED OR ONLY USED WHEN TESTING:
//			..['toast'] = toast
//			..['buff'] = buff
//			..['collisions'] = toggleCollisionLines
			..['physics'] = togglePhysics;
//			..['log'] = log
//			..['settime'] = setTime
//			..['setweather'] = setWeather
	}
}

bool parseCommand(String command) {
	// Getting the important data
	String verb = command.split(" ")[0].toLowerCase().replaceFirst('/', '');

	String noun = command.split(' ').skip(1).join(' ');

	if(COMMANDS.containsKey(verb)) {
		COMMANDS[verb](noun);
		logmessage('[Chat] Parsed valid command: "$command"');
		return true;
	} else {
		return false;
	}
}

/////////////////////////////////// ENABLED

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

/////////////////////////////////// DEPRECATED

setLocationCommand(_) {
	toast('Teleporting through commands has been disabled. Click on streets on the map instead.');
}

setCurrants(_) {
	toast('/setcurrants does not work anymore because you can collect quoins or sell things now.');
}

setName(_) {
	toast('To change your name, click it at the top left, log in to the site, and use the Account section of your profile page.');
}

/////////////////////////////////// TESTING ONLY

//// Teleports

go(String tsid) {
	tsid = tsid.trim();
	view.mapLoadingScreen.className = "MapLoadingScreenIn";
	view.mapLoadingScreen.style.opacity = "1.0";
	minimap.containerE.hidden = true;
	//changes first letter to match revdancatt's code - only if it starts with an L
	if (tsid.startsWith("L")) tsid = tsid.replaceFirst("L", "G");
	streetService.requestStreet(tsid);
}

//// [LOCAL ONLY] Changes the time temporarily

setTime(String noun) {
	transmit('timeUpdateFake',[noun]);
	if(noun == '6:00am') {
		transmit('newDayFake',null);
	}
}

//// [LOCAL ONLY] Changes the weather temporarily

setWeather(String noun) {
	if(noun == 'snow') {
		transmit('setWeatherFake',{'state':WeatherState.SNOWING.index});
	} else if(noun == 'rain') {
		transmit('setWeatherFake',{'state':WeatherState.RAINING.index});
	} else if(noun == 'clear') {
		transmit('setWeatherFake', {'state':WeatherState.CLEAR.index});
	}
}

//// [LOCAL ONLY] Shows or hides collision lines on platforms

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

//// Enables 'flying'

togglePhysics(var nothing) {
	if(CurrentPlayer.doPhysicsApply) {
		CurrentPlayer.doPhysicsApply = false;
		toast('Physics no longer apply to you');
	} else {
		CurrentPlayer.doPhysicsApply = true;
		toast('Physics apply to you');
	}
}