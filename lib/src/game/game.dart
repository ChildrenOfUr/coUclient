part of couclient;

StreetService streetService = new StreetService();

// GAME ENTRY AND MANAGEMENT //
class Game {
	String username, location, email;
	double lastTime = 0.0;
	DateTime startTime = new DateTime.now();
	bool ignoreGamepads = false;

	// INITIALIZATION //
	Game(Metabolics m) {
		username = localStorage['username'];
		location = sessionStorage['playerStreet'];
		email = sessionStorage['playerEmail'];
		_init(m);
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
		metabolics.init(m);

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
		await audio.setSong('highlands');

		//start time based colors (and rain)
		weather = new WeatherManager();

		//finally start the main game loop
		loop(0.0);
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
				print('Sorry, this browser does not support the gamepad API');
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
