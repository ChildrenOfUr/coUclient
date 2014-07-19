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
      ..['setname'] = setnameCommand
      ..['list'] = listplayersCommand;
    
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

setnameCommand(String noun) {
  // Fix Name
  String newName = noun.replaceAll(" ", "_");

  // Is it appropriate?
  if (!new RegExp(r"^-?[_a-zA-Z]+[_a-zA-Z0-9-]*$").hasMatch(newName)) {
    new Moment('ChatEvent', {
      'channel': 'Global Chat',
      'message': "Sorry, you can't use the following characters in your name<br>~ ! @ \$ % ^ & * ( ) + = , . / ' ; : \" ? > < [ ] \ { } | ` #"
    });
    return;
  }

  // Prepare Server Message
  Map map = new Map();
  map["statusMessage"] = "changeName";
  map["username"] = ui.username;
  map["newUsername"] = newName;
  ui.username = newName;
  map["channel"] = 'Global Chat';

  // Send new name to server
  new Moment('OutgoingChatEvent', map);

  // Alert the Player
  new Moment('ChatEvent', {
    'channel': 'Global Chat',
    'message': "Name changed to $newName"
  });
}

listplayersCommand(String noun) {
  Map map = new Map();
  map["username"] = ui.username;
  map["statusMessage"] = "list";
  map["channel"] = 'Global Chat';
  //map["street"] = currentStreet.label;

  // Send message to server
  new Moment('OutgoingChatEvent', map);
}



setlocationCommand(String noun) { // TODO implement after streets are usable.
  /*
  else if(command.split(" ")[0].toLowerCase() == "/setlocation" || command.split(" ")[0].toLowerCase() == "/go")
  {
  setLocation(command.split(" ")[1]);
  return;
  }
*/
}
