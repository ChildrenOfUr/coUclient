part of couclient;

StreetService streetService = new StreetService();

// GAME ENTRY AND MANAGEMENT //
class Game {
	String username, location, email;
	double lastTime = 0.0;
	DateTime startTime = new DateTime.now();
	bool ignoreGamepads = false;
	List<String> devs = [];
	List<String> guides = [];
	bool loaded = false;

	// INITIALIZATION //
	Game(Metabolics m) {
		username = localStorage['username'];
		location = sessionStorage['playerStreet'];
		email = sessionStorage['playerEmail'];
		_init(m);

		getPlayerRoles().then((_) {
			// Hide "Become a Guide" button
			if (game.guides.contains(game.username) || game.devs.contains(game.username)) {
				querySelector("#becomeGuideFromChatPanel").hidden = true;
			}

			// Display border on avatar image
			// (Devs shouldn't see it, our blog post screenshots would be different)
			if (game.guides.contains(game.username)) {
				querySelector("ur-meters /deep/ #leftDisk").classes.add("guideDisk");
			}
		});
	}

	Future getPlayerRoles() async {
		await HttpRequest.requestCrossOrigin("http://childrenofur.com/scripts/labels/devs.php?listDevs=wu7AGYR62SuAY81d").then((String str) {
			devs = str.split(",");
		});

		await HttpRequest.requestCrossOrigin("http://childrenofur.com/scripts/labels/guides.php?listGuides=L6EJI1PF0oXD6iYSf0cZ").then((String str) {
			guides = str.split(",");
		});
	}

	_init(Metabolics m) async {
		//load the player's street from the server
		await streetService.requestStreet(location);

		//setup the chat and open two initial channels
		new NetChatManager();
		transmit('startChat', 'Local Chat');
		transmit('startChat', 'Global Chat');

		//show the message of the day
		//windowManager.motdWindow.open();

		//init the players metabolcs
		await metabolics.init(m);

		//setup the communications for multiplayer events
		multiplayerInit();

		//create the player entity and display their name in the UI
		CurrentPlayer = new Player(username);
		view.meters.updateNameDisplay();

		//load the player's animation spritesheets then set them to idle
		await CurrentPlayer.loadAnimations();
		CurrentPlayer.currentAnimation = CurrentPlayer.animations['idle'];
		transmit('playerLoaded', null);

		//stop loading sounds and load the street's song
		if(audio.loadingSound != null) {
			audio.loadingSound.stop();
		}
		transmit('playSound', 'game_loaded');
		//play appropriate song for street (or just highlands for now)
		//await audio.setSong('highlands');

		//start time based colors (and rain)
		weather = new WeatherManager();

		//send and receive messages from the server about quests
		questManager = new QuestManager();

		//finally start the main game loop
		loop(0.0);

		loaded = true;
		transmit("gameLoaded", loaded);
		logmessage("Game loaded!");

		// Update player letters every second
		// (Don't worry, it checks to make sure the current street has letters
		// before sending the request to the server, and adjusts accordingly)
		new Timer.periodic(new Duration(seconds: 1), (_) => updatePlayerLetters());

		// Tell the server when we have changed streets, and to assign us a new letter
		new Service(["streetLoaded", "gameUnloading"], (_) {
			if (currentStreet.useLetters) {
				HttpRequest.getString("http://${Configs.utilServerAddress}/letters/newPlayerLetter?username=${game.username}");
			}
		});

		// Load previous GPS state
		if (localStorage.containsKey("gps_navigating")) {
			GPS.getRoute(currentStreet.label, localStorage["gps_navigating"]);
		}
	}

	// GAME LOOP //
	loop(num delta) {
		//UserTag loopTag = new UserTag('gameloop');
		//UserTag previousTag = loopTag.makeCurrent();

		double dt = (delta - lastTime) / 1000;
		lastTime = delta;

		//if the gamepad api isn't supported, don't continue to try to get updates from it
		if(!ignoreGamepads) {
			try {
				//UserTag gamepadTag = new UserTag('gamepad');
				//UserTag prev = gamepadTag.makeCurrent();

				inputManager.updateGamepad();

				//prev.makeCurrent();
			}
			catch(err) {
				ignoreGamepads = true;
				logmessage('[UI] Sorry, this browser does not support the gamepad API');
			}
		}

		//UserTag updateTag = new UserTag('update');
		//UserTag prev = updateTag.makeCurrent();

		update(dt);

		//prev.makeCurrent();

		//UserTag renderTag = new UserTag('render');
		//prev = renderTag.makeCurrent();

		render();

		//prev.makeCurrent();

		window.animationFrame.then(loop);

		//previousTag.makeCurrent();
	}

	Future updatePlayerLetters() async {
		Map<String, Player> players = new Map()
			..addAll(otherPlayers)
			..addAll(({game.username: CurrentPlayer}));

		players.forEach((String username, Player player) async {
			Element parentE = player.playerParentElement;

			String username = parentE.id.replaceFirst("player-", "");
			if (username.startsWith("pc-")) {
				username = username.replaceFirst("pc-", "");
			}

			if (currentStreet.useLetters) {
				String letter = await HttpRequest.getString("http://${Configs.utilServerAddress}/letters/getPlayerLetter?username=$username");

				DivElement letterDisplay = new DivElement()
					..classes.addAll(["letter", "letter-$letter"]);

				parentE
					..children.removeWhere((Element e) => e.classes.contains("letter"))
					..append(letterDisplay);
			} else {
				parentE.children.removeWhere((Element e) => e.classes.contains("letter"));
			}
		});
	}
}
