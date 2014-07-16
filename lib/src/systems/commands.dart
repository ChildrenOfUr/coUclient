part of couclient;


parseCommand(String command) {
  Map map = new Map();
  if (command.split(" ")[0].toLowerCase() == "/setname") {
    String newName = command.substring(9).replaceAll(" ", "_");
    if (!new RegExp(r"^-?[_a-zA-Z]+[_a-zA-Z0-9-]*$").hasMatch(newName)) {
      new EventInstance('ChatEvent', {
        'channel': 'Global Chat',
        'message': "Sorry, you can't use the following characters in your name<br>~ ! @ \$ % ^ & * ( ) + = , . / ' ; : \" ? > < [ ] \ { } | ` #"
      });
      return;
    }
    map["statusMessage"] = "changeName";
    map["username"] = ui.username;
    map["newUsername"] = command.substring(9);
    ui.username = command.substring(9);
    map["channel"] = 'Global Chat';
    
    new EventInstance('ChatEvent', {
        'channel': 'Global Chat',
        'message': "Name changed to ${ui.username}"
    });
    
  } else if (command.toLowerCase() == "/list") {
    map["username"] = ui.username;
    map["statusMessage"] = "list";
    map["channel"] = 'Global Chat';
    //map["street"] = currentStreet.label;
  } /*
        else if(command.split(" ")[0].toLowerCase() == "/setlocation" || command.split(" ")[0].toLowerCase() == "/go")
        {
          setLocation(command.split(" ")[1]);
          return;
        }
        */
  else if (command.split(" ")[0].toLowerCase() == "/playsong") {
    new EventInstance('PlaySound', command.split(' ')[1]);
    return;
  }
  new EventInstance('OutgoingChatEvent',map);
}
