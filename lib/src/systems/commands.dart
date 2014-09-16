part of couclient;

// List of commandable functions
Map<String, Function> COMMANDS = {};

class CommandManager {
  CommandManager() {

    COMMANDS['playsound'] = (noun) {
      new Moment('PlaySound', noun);
    };

    // Trigger arbitrary EventInstances
    COMMANDS['event'] = (String noun) {
      new Moment(noun.split(' ')[0], noun.split(' ')[1]);
    };

    COMMANDS
        ..['setname'] = setName
        ..['go'] = setLocationCommand
        ..['setlocation'] = setLocationCommand;
  }
}



/////////////////////////////////// COMMAND FUNCTIONS /////////////////////////////////////////////


bool parseCommand(String command) {
  // Getting the important data
  String verb = command.split(" ")[0].toLowerCase().replaceFirst('/', '');
  String noun = command.split(' ').skip(1).join(' ');

  if (COMMANDS.containsKey(verb)) {
    COMMANDS[verb](noun);
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
  String oldName = ui.username;

  // Is it appropriate?
  if (containsBadCharacter(newName)) {
    new Moment('ChatEvent', {
      'channel': 'Global Chat',
      'message': "Sorry, you can't use the following characters in your name<br>~ ! @ \$ % ^ & * ( ) + = , . / ' ; : \" ? > < [ ] \ { } | ` #"
    });
    return;
  }
  
  if(CurrentPlayer != null)
  	CurrentPlayer.playerName.text = noun;
  ui.username = noun;
  localStorage['username'] = noun;

  // Prepare Server Message
  Map map = new Map();
  map["statusMessage"] = "changeName";
  map["username"] = oldName;
  map["newUsername"] = noun;
  map["channel"] = 'Global Chat';

  // Send new name to server
  new Moment('OutgoingChatEvent', map);

  // Alert the Player
  new Moment('ChatEvent', {
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
	ui.loadingScreen.className = "MapLoadingScreenIn";
	ui.loadingScreen.style.opacity = "1.0";
	//changes first letter to match revdancatt's code - only if it starts with an L
	if(noun.startsWith("L"))
		noun = noun.replaceFirst("L", "G");
	ScriptElement loadStreet = new ScriptElement();
	loadStreet.src = "http://robertmcdermot.github.io/CAT422-glitch-location-viewer/locations/$noun.callback.json";
	document.body.append(loadStreet);
}
