part of couclient;

// debugging service
Service errService = new Service(['err', 'debug'], (event) {
  transmit('toast', 'Debug: ${event.content}');
});

// List of commandable functions
Map<String, Function> COMMANDS = {};

class CommandManager {
  CommandManager() {

    COMMANDS['follow'] = (noun) => new Toast(CurrentPlayer.followPlayer(noun.trim()));
    COMMANDS["help"] = (_) => new Toast(
        "Available commands: " +
            COMMANDS.keys.toList().toString().replaceAll("[", "").replaceAll("]", "")
    );
    COMMANDS['interface'] = changeInterface;
    COMMANDS['playsong'] = (noun) => transmit('playSong', noun);
    COMMANDS['playsound'] = (noun) => transmit('playSound', noun);
    COMMANDS["reload"] = (_) => hardReload();

    if (Configs.testing) {
      COMMANDS
        ..['music'] = setMusic
        ..['tp'] = go
        ..['collisions'] = toggleCollisionLines
        ..['physics'] = togglePhysics
        ..['log'] = log
        ..['time'] = setTime
        ..['weather'] = setWeather
        ..['note'] = note;
    }
  }
}

bool parseCommand(String command) {
  // Getting the important data
  String verb = command.split(" ")[0].toLowerCase().replaceFirst('/', '');

  String noun = command.split(' ').skip(1).join(' ');

  if (COMMANDS.containsKey(verb)) {
    COMMANDS[verb](noun);
    logmessage('[Chat] Parsed valid command: "$command"');
    return true;
  } else {
    return false;
  }
}

// Allows switching to desktop view on touchscreen laptops
changeInterface(var type) {
  if (type == "desktop") {
    (querySelector("#MobileStyle") as StyleElement).disabled = true;
    localStorage['interface'] = 'desktop';
    new Toast('Switched to desktop view');
  } else if (type == "mobile") {
    (querySelector("#MobileStyle") as StyleElement).disabled = false;
    localStorage['interface'] = 'mobile';
    new Toast('Switched to mobile view');
  } else {
    new Toast('Interface type must be either desktop or mobile, ' + type + ' is invalid');
  }
}

/////////////////////////////////// TESTING ONLY

go(String tsid) {
  tsid = tsid.trim();
  view.mapLoadingScreen.className = "MapLoadingScreenIn";
  view.mapLoadingScreen.style.opacity = "1.0";
  minimap.containerE.hidden = true;
  //changes first letter to match revdancatt's code - only if it starts with an L
  if (tsid.startsWith("L")) tsid = tsid.replaceFirst("L", "G");
  streetService.requestStreet(tsid);
}

setTime(String noun) {
  transmit('timeUpdateFake', [noun]);
  if (noun == '6:00am') {
    transmit('newDayFake', null);
  }
}

setWeather(String noun) {
  if (noun == 'snow') {
    transmit('setWeatherFake', {'state':WeatherState.SNOWING.index});
  } else if (noun == 'rain') {
    transmit('setWeatherFake', {'state':WeatherState.RAINING.index});
  } else if (noun == 'clear') {
    transmit('setWeatherFake', {'state':WeatherState.CLEAR.index});
  }
}

toggleCollisionLines(_) {
  if (showCollisionLines) {
    showCollisionLines = false;
    hideLineCanvas();
    new Toast('Collision lines hidden');
  }
  else {
    showCollisionLines = true;
    showLineCanvas();
    new Toast('Collision lines shown');
  }
}

togglePhysics(_) {
  if (CurrentPlayer.doPhysicsApply) {
    CurrentPlayer.doPhysicsApply = false;
    new Toast('Physics no longer apply to you');
  } else {
    CurrentPlayer.doPhysicsApply = true;
    new Toast('Physics apply to you');
  }
}

setMusic(String song) {
  new Toast("Music set to $song");
  audio.setSong(song);
}

note(_) => new NoteWindow(null);