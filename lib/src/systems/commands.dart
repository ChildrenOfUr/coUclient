part of couclient;

// debugging service
Service errService = new Service([#err,#debug],(Message event){new Message(#toast,'Debug: ${event.content}');});


// List of commandable functions
Map<String, Function> COMMANDS = {};

class CommandManager {
  CommandManager() {

    COMMANDS['playsound'] = (noun) {
      new Message(#playSound, noun);
    };

    COMMANDS['playsong'] = (noun) {
      new Message(#playSong, noun);
    };

    COMMANDS
        ..['setname'] = setName
        ..['go'] = setLocationCommand
        ..['setlocation'] = setLocationCommand
        ..['toast'] = toast
        ..['toggleCollisionLines'] = toggleCollisionLines
        ..['togglePhysics'] = togglePhysics
        ..['log'] = log
  }
}



/////////////////////////////////// COMMAND FUNCTIONS /////////////////////////////////////////////


bool parseCommand(String command) {
  // Getting the important data
  String verb = command.split(" ")[0].toLowerCase().replaceFirst('/', '');

  String noun = command.split(' ').skip(1).join(' ');

  if (COMMANDS.containsKey(verb)) {
    COMMANDS[verb](noun);
    log('Parsed valid command : "$command"');
    return true;
  } else {
    return false;
  }
}

// COMMAND FUNCTIONS BELOW  //

setName(String noun)
{
  // Fix Name
  String newName = noun.replaceAll(" ", "_");
  String oldName = game.username;

  // Is it appropriate?
  if (containsBadCharacter(newName)) {
    new Message(#chatEvent, {
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
  new Message(#outgoingChatEvent, map);

  // Alert the Player
  new Message(#chatEvent, {
    'channel': 'Global Chat',
    'message': "Name changed to $noun"
  });
}

bool containsBadCharacter(String newName) {
  List<String> badChars = "! @ \$ % ^ & * ( ) + = , . / ' ; : \" ? > < [ ] \\ { } | ` #".split(" ");
  for (String char in badChars) {
    if (newName.contains(char)) return true;
  }

  return false;
}

setLocationCommand(String noun)
{
	playerTeleFrom="console";
	noun = noun.trim();
	view.mapLoadingScreen.className = "MapLoadingScreenIn";
	view.mapLoadingScreen.style.opacity = "1.0";
	//changes first letter to match revdancatt's code - only if it starts with an L
	if(noun.startsWith("L"))
		noun = noun.replaceFirst("L", "G");
	streetService.requestStreet(noun);
}

toggleCollisionLines(var nothing)
{
	if(showCollisionLines)
	{
		showCollisionLines = false;
		hideLineCanvas();
	}
	else
	{
		showCollisionLines = true;
		showLineCanvas();
	}
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

