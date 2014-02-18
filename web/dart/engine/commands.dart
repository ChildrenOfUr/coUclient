part of coUclient;

StreamSubscription consolelistener;// the eventlistener for entering console commands.
// To Create new console commands, add them to this list.
List<List> COMMANDS = new List<List>()
      // The console command, the description, the function called
	..add(['print','"print <message>" Prints a message to the console.',printConsole])
	..add(['clear','Clears the console history',clearConsole])
	..add(['help','Displays this dialog.',printHelp])
	..add(['hideConsole','Hides the console from view',hideConsole])
	
	..add(['setenergy','"setenergy <value>" Changes the energy meter',setEnergy])
	..add(['setmaxenergy','"setmaxenergy <value>" Changes the energy meters max value',setMaxEnergy])
	
	..add(['setmood','"setmood <value>" Changes the mood meter',setMood])
	..add(['setmaxmood','"setmaxmood <value>" Changes the mood meters max value',setMaxMood])
	
	..add(['setcurrants','"setcurrants <value>" Changes the currant meters value',setCurrants])
	..add(['setimg','"setimg <value>" Changes the img meters value',setImg])
	
	..add(['setname','"setname <value>" Changes the players displayed name',setName])
	
	..add(['setlocation','"setlocation <tsid>" Changes the current street',setLocation])
	
	..add(['setsong','"setsong <value>" Changes the currently playing song',setSong])
	..add(['setvolume','"setvolume <1-100>" Changes the volume of the current song',setVolume])
	
	..add(['togglefps','show or hide the fps display"',toggleFps])
	..add(['togglePhysics','enable or disable jumping and falling to the groud"',togglePhysics]);

/**
 * Attempts to parse input from the user and run the appropriate command.
 * 
 * This method will cycle through the list of available commands and try to match the user's input to one of them.
 * If it matches, it will pass the parsed parameters to that function.
 */
// We'll use this for handing console commands, and responses to menu options.
runCommand(String commandToRun)
{
	for (List syntaxParts in COMMANDS)
	{
		//match the input with one of the available commands
		if (commandToRun.startsWith(syntaxParts[0]))
		{
			Function action = syntaxParts[2];
			String commandID = syntaxParts[0]; 
			String data = commandToRun.replaceAll(commandID,'').replaceAll('\n', '');
			action(data);
			return;
		}
	}
}

/**
 * Updates the console window using the given input string.
 * 
 * Adds [line] to the console window and scrolls the window to the bottom.  Pass in [null] if you want to clear all history from the window.
 */
updateConsole(String line)
{
	Element container = querySelector('#CommandConsole');
	
	if(line == null)
	{
		container.children.clear();
		return;
	}
	
	DivElement lineDiv = new DivElement()
	    ..classes.add('ConsoleEntry')
	    ..text = line;
	container.append(lineDiv);
	container.scrollTop = container.scrollHeight; //scroll to the bottom
}

/**
 * Shows the debug console.
 * 
 * This method will set the debug console to be unhidden.  Additionally it will scroll the contents to the bottom.
 */
showConsole()
{
	querySelector('#DevConsole').hidden = false;
	querySelector('.ConsoleInput').focus();
	consolelistener = querySelector('.ConsoleInput').onKeyUp.listen((key)
	{
    	if (key.keyCode == 13)
    		_runConsoleCommand();
	});
	Element container = querySelector('#CommandConsole');
	container.scrollTop = container.scrollHeight; //scroll to the bottom
}

//gets the input from the console and passes it on to be parsed, then resets the input control
_runConsoleCommand()
{
	TextAreaElement input = querySelector('.ConsoleInput');
	String value = input.value;
	printConsole('> $value');
	runCommand(value);
	input.value = '';
}

/**
 * Hides the debug console.
 * 
 * This method will set the debug console to be hidden.
 */
hideConsole(var nothing)
{
	querySelector('#DevConsole').hidden = true;
	consolelistener.cancel();
}

/**
 * Echoes the [message] to the console.
 * 
 * This method echoes whatever the user types into a new line in the console's history.
 */
printConsole(String message)
{
	updateConsole(message);
}

/**
 * Prints a list of available commands and their descriptions.
 * 
 * This method shows the user a list of commands that they can use.
 */
printHelp(var nothing)
{
	printConsole('List of Commands:');
	for (List command in COMMANDS)
		printConsole(command[0] + ' : ' + command[1]);
}

/**
 * Clears the history in the console.
 * 
 * This method clears all of the previous console history.
 */
clearConsole(var nothing)
{
	updateConsole(null);
}

// Console commands to manipulate Meters
/**
 * Sets the player's energy to [value]
 */
setEnergy(String value)
{
	int intvalue = int.parse(value,onError:null);
	if (intvalue != null)
	{
		ui._setEnergy(intvalue);
		printConsole('Setting energy value to $value');
	}
}

/**
 * Sets the player's maximum energy to [value]
 */
setMaxEnergy(String value)
{
	int intvalue = int.parse(value,onError:null);
	if (intvalue != null)
	{
		ui._maxenergy = intvalue;
		ui._setEnergy(ui._maxenergy);
		ui._maxEnergyText.text = value;
		printConsole('Setting the maximum energy value to $value');
	}
}

/**
 * Sets the player's mood to [value]
 */
setMood(String value)
{
	int intvalue = int.parse(value,onError:null);
	if (intvalue != null)
	{
		ui._setMood(intvalue);
		printConsole('Setting mood value to $value');
	}
}

/**
 * Sets the player's maximum mood to [value]
 */
setMaxMood(String value)
{
	int intvalue = int.parse(value,onError:null);
	if (intvalue != null)
	{
		ui._mood = intvalue;
		ui._setMood(ui._mood);
		ui._maxMoodText.text = value;
		printConsole('Setting the maximum mood value to $value');
	}
}

/**
 * Sets the player's currants to [value]
 */
setCurrants(String value)
{
	// Force an int
	int intvalue = int.parse(value,onError:null);
	if (intvalue != null)
	{
		ui._setCurrants(intvalue);
		printConsole('Setting currants to $value');
	}  
}

/**
 * Sets the player's iMG to [value]
 */
setImg(String value)
{
	// Force an int
	int intvalue = int.parse(value,onError:null);
	if (intvalue != null)
	{
		ui._setImg(intvalue);
		printConsole('Setting Img to $value');
	}  
}

/**
 * Sets the player's name above the energy meter to [value].  This does not have any effect on the player's chat name.
 */
setName(String value)
{
	ui._setName(value);
	printConsole('Setting name to "$value"');  
}

/**
 * Sets the player's location to the street [value].
 * Recognizes TSIDs as values
 */
setLocation(String value)
{
	Element loadingScreen = querySelector('#MapLoadingScreen');
	loadingScreen.className = "MapLoadingScreenIn";
	loadingScreen.style.opacity = "1.0";
	//changes first letter to match revdancatt's code
	value = value.replaceFirst("L", "G").trim();
	ScriptElement loadStreet = new ScriptElement();
	loadStreet.src = "http://revdancatt.github.io/CAT422-glitch-location-viewer/locations/$value.callback.json";
	document.body.append(loadStreet);
	printConsole('Teleporting to $value');
}

/**
 * Sets the SoundCloud widget's song to [value].  Must be one of the available songs.
 * If [value] is already playing, this method has no effect.
 */
Future setSong(String value)
{
	Completer c = new Completer();
	
	if(value == ui.titleMeter.text)
	{
		c.complete();
		return c.future;
	}
	
	value = value.replaceAll(' ', '');
	if(ui.jukebox[value] == null)
	{
		loadSong(value).then((_)
		{
			_playSong(value);
			c.complete();
		});
	}
	else
	{
		_playSong(value);
		c.complete();
	}
	
	return c.future;
}

_playSong(String value)
{
	/*
	 * canPlayType should return:
	 * 		probably: if the specified type appears to be playable.
	 * 		maybe: if it's impossible to tell whether the type is playable without playing it.
	 * 		The empty string: if the specified type definitely cannot be played.
	 */
	String testResult = new AudioElement().canPlayType('audio/mp3');
	if (testResult == '')
	{
		printConsole('SoundCloud: Your browser doesnt like mp3s :(');
		//return;
	}
	else if(testResult == 'maybe') //give warning message but proceed anyway
		printConsole('SoundCloud: Your browser may or may not fully support mp3s');
	
	// Changes the ui
	if (ui.currentSong != null)
		ui.currentSong.pause();
	ui.currentSong = ui.jukebox[value];
	ui.currentSong.play();
	ui.currentSong.loop(true);	
	String title = ui.currentSong.meta['title'];
	String artist = ui.currentSong.meta['user']['username'];
	ui._setSong(artist,title);
	AnchorElement link = querySelector('#SCLink');
	link.href = ui.currentSong.meta['permalink_url'];
}

/**
 * Sets the volume of anny sound that is played to [value].  Must be in the range [0,100]
 */
setVolume(String value)
{
	// Force an int
	int intvalue = int.parse(value,onError:null);
	if (intvalue != null)
	{
		InputElement volumeSlider = (querySelector('#VolumeSlider') as InputElement);
		localStorage['prevVolume'] = volumeSlider.value;
		volumeSlider.value = value.trim();
		querySelector('#rangevalue').text = value.trim();
		if (ui.currentSong != null)
	    	ui.currentSong.volume(intvalue);
		printConsole('Setting volume to $value');
	}  
}

/**
 * Shows the map.
 * 
 *
 */
showMap()
{
  querySelector('#MapWindow').hidden = false;
  querySelector('.ConsoleInput').focus();
}
hideMap(var nothing)
{
  querySelector('#MapWindow').hidden = true;
  /* V ???
  consolelistener.cancel();
  */
}

/**
 * Toggles the display of the fps counter
 */
toggleFps(var nothing)
{
	if(showFps)
		showFps = false;
	else
		showFps = true;
}

/**
 * Toggles physics on the current player
 */
togglePhysics(var nothing)
{
	if(CurrentPlayer.doPhysicsApply)
		CurrentPlayer.doPhysicsApply = false;
	else
		CurrentPlayer.doPhysicsApply = true;
}

// A blank action.
doNothing(var nothing){}