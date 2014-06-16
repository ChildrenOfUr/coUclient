part of couclient;

StreamSubscription consolelistener;// the eventlistener for entering console commands.
// To Create new console commands, add them to this list.
List<List> COMMANDS = new List<List>()
      // The console command, the description, the function called
	..add(['print','"print <message>" Prints a message to the console.',printConsole])
	..add(['clear','Clears the console history',clearConsole])
	..add(['help','Displays this dialog.',printHelp])
	
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
	
	//..add(['togglefps','show or hide the fps display"',toggleFps])
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
	app.print(line);
	app.consoleText.scrollTop = app.consoleText.scrollHeight; //scroll to the bottom
}


/* TODO reimplement
//gets the input from the console and passes it on to be parsed, then resets the input control
_runConsoleCommand()
{
	String value = consoleInput.value;
	printConsole('> $value');
	runCommand(value);
	consoleInput.value = '';
}
*/

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
		app.energy = intvalue;
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
		app.maxenergy = intvalue;
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
		app.mood = intvalue;
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
	  app.maxmood = intvalue;
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
		app.currants = intvalue;
		localStorage["currants"] = value;
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
		app.img = intvalue;
		localStorage["img"] = value;
		printConsole('Setting Img to $value');
	}  
}

/**
 * Sets the player's name above the energy meter to [value].  This does not have any effect on the player's chat name.
 */
setName(String value)
{
	app.username = value;
	printConsole('Setting name to "$value"');  
}

/**
 * Sets the player's location to the street [value].
 * Recognizes TSIDs as values
 */
setLocation(String value)
{
	value = value.trim();

	querySelector('#streetLoading')
        ..style.opacity = '1'
        ..style.transition = 'opacity 0.5s'
        ..hidden = false;
	
	//changes first letter to match revdancatt's code - only if it starts with an L
	if(value.startsWith("L"))
		value = value.replaceFirst("L", "G");
	ScriptElement loadStreet = new ScriptElement();
	loadStreet.src = "http://robertmcdermot.github.io/CAT422-glitch-location-viewer/locations/$value.callback.json";
	document.body.append(loadStreet);
	printConsole('Teleporting to $value');
}

/**
 * Sets the SoundCloud widget's song to [value].  Must be one of the available songs.
 * If [value] is already playing, this method has no effect.
 */
setSong(String value)
  {
	sound.play(value);
  }


/**
 * Sets the volume of anny sound that is played to [value].  Must be in the range [0,100]
 */
setVolume(String value, bool mute)
{
	// Force an int
	int intvalue = int.parse(value,onError:null);
  app.volume = intvalue;
	printConsole('Setting volume to $value');
}

/* TODO: This is built into the the development console in most browsers, do we need it?
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
*/

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