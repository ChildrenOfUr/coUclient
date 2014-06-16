part of couclient;

WebSocket playerSocket;

main()
{
  /*
	//disable the mobile stylesheet
	//we do it here instead of in the html so that it loads
	//also firefox ignores the disabled attribute in html
	if(localStorage["interface"] == null || localStorage["interface"] == "desktop")
		(querySelector("#MobileStyle") as LinkElement).disabled = true;
	else
		querySelector("#ThemeSwitcher").text = "Desktop View";
  */
  
	// The player has requested that the game is to begin.
	// run all audio initialization tasks
	//set status text on loading screen to show progress TODO: temporary until prettier thing arrives
	
  app.init();
  
  app.loadStatus.text = "Loading Audio";
	
	// On-game-started loading tasks
	sound.init()
	.then((_) => load_streets()
	.then((_) => new Street('test').load()
	.then((_)
	{
		//initialize chat after street has been loaded and currentStreet.label is set
		chat.init();
		
		//connect to the multiplayer server and start managing the other players on the screen
		multiplayerInit();
		
		CurrentPlayer = new Player();
		CurrentPlayer.loadAnimations()
		.then((_)
		{
			CurrentPlayer.currentAnimation = CurrentPlayer.animations['idle'];
			
					start();
				});
	})));
}

start()
{
	// Finally finished loading. Clean up.
	
	// Peacefully fade out the loading screen.
	querySelector('#LoadingScreen').style.opacity = '0.0';
	new Timer(new Duration(seconds:1), ()
	{
		querySelector('#LoadingScreen').remove();
	});
	if(app.volume > 0)
	{
		if(ASSET['game_loaded'] != null)
		{
			AudioElement doneLoading = ASSET['game_loaded'].get();
			doneLoading.play();
		}
	} 
	
	printConsole('System: Initializing..');
	
	// Start listening for clicks and key presses
	playerInput = new Input()
	..init();
	
	printConsole('System: Initialization Finished.');
	printConsole('');
	
	printConsole('COU DEVELOPMENT CONSOLE');
	printConsole('For a list of commands type "help"');
	    	
	// Begin the GAME!!!
	gameLoop(0.0);
}