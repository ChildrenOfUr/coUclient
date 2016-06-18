part of couclient;

StreetService streetService = new StreetService();
xl.ResourceManager resourceManager = new xl.ResourceManager();

// GAME ENTRY AND MANAGEMENT //
class Game {
	String username, location, email;
	num lastTime = 0.0;
	DateTime startTime = new DateTime.now();
	bool ignoreGamepads = false;
	Map<String, String> elevationCache = new Map();
	bool loaded = false;

	// INITIALIZATION //
	Game(Metabolics m) {
		username = localStorage['username'];
		location = sessionStorage['playerStreet'];
		email = sessionStorage['playerEmail'];
		_init(m);

		getElevation(username).then((String role) {
			// Hide "Become a Guide" button
			if (["dev", "guide"].contains(role)) {
				querySelector("#becomeGuideFromChatPanel").hidden = true;
			}

			// Display border on avatar image
			// (Devs shouldn't see it, our blog post screenshots would be different)
			if (role == "guide") {
				querySelector("ur-meters /deep/ #leftDisk").classes.add("guideDisk");
			}
		});

		// Change username button
		querySelector("#changeUsernameFromChatPanel").onClick.listen((_) {
			windowManager.changeUsernameWindow.open();
		});
	}

	Future<String> getElevation(String username) async {
		if (elevationCache[username] != null) {
			return elevationCache[username];
		} else {
			String elevation = await HttpRequest.getString(
				"http://${Configs.utilServerAddress}/elevation/get/$username"
			).timeout(new Duration(seconds: 5), onTimeout: () {
				return '';
			});
			elevationCache[username] = elevation;
			return elevation;
		}
	}

	_init(Metabolics m) async {
		//set some stagexl global vars
		xl.StageXL.stageOptions.renderEngine = xl.RenderEngine.WebGL;
		xl.StageXL.stageOptions.transparent = true;
		xl.StageXL.stageOptions.backgroundColor = xl.Color.Transparent;
		xl.StageXL.stageOptions.stageScaleMode = xl.StageScaleMode.NO_SCALE;
		xl.StageXL.stageOptions.stageAlign = xl.StageAlign.TOP_LEFT;
		xl.StageXL.bitmapDataLoadOptions.corsEnabled = true;

		view.stageCanvas = new CanvasElement()
			..style.position = 'absolute'
			..style.top = '0'
			..style.left = '0'
			..style.width = '${view.worldElementWidth}px'
			..style.height = '${view.worldElementHeight}px';
		view.worldElement.append(view.stageCanvas);

		view.playerStage = new xl.Stage(view.stageCanvas, width: view.worldElementWidth, height: view.worldElementHeight);
		view.renderLoop = new xl.RenderLoop();
		view.renderLoop.addStage(view.playerStage);

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
//		CurrentPlayer.currentAnimation = CurrentPlayer.animations['idle'];
		transmit('playerLoaded', null);

		// HACK: toggling fixes mute issues
		view.slider
		    ..volumeGlyph.click()
			..volumeGlyph.click()
			..doToasts = true;

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

		// Load buffs
		Buff.loadExisting();

		// Load skills
		Skills.loadData();
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
}
