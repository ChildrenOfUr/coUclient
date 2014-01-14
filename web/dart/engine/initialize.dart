part of coUclient;

main()
{
	// The player has requested that the game is to begin.
	// run all audio initialization tasks
	//set status text on loading screen to show progress TODO: temporary until prettier thing arrives
	Element loadStatus = querySelector("#LoadStatus");
	Element loadStatus2 = querySelector("#LoadStatus2");
	loadStatus.text = "Loading Audio";
	init_audio();
	
	// On-game-started loading tasks  
	load_audio()
	.then((_) => load_streets()
	.then((_) => new Street('test').load())
	.then((_)
	{
		// Finally finished loading. Clean up.

	    // Peacefully fade out the loading screen.
	    querySelector('#LoadingScreen').style.opacity = '0.0';
	    Timer t = new Timer(new Duration(seconds:1), querySelector('#LoadingScreen').remove);
	  
	    // Set the meters to their current values.
	    ui.init();      
	
	    printConsole('System: Initializing..');
	    
	    // Start listening for clicks and key presses
	    playerInput = new Input()
	    	..init();
	    
	    printConsole('System: Initialization Finished.');
	    printConsole('');
	    
	    printConsole('COU DEVELOPMENT CONSOLE');
	    printConsole('For a list of commands type "help"');    
    
		if(int.parse(prevVolume) > 0 && isMuted == '0')
		{
			AudioElement doneLoading = ASSET['game_loaded'].get();
			doneLoading.volume = int.parse(prevVolume)/100;
			doneLoading.play();
		}
	})
	.then((_) 
	{	
		chat.init();
		// Begin the GAME!!!
		game.start();
  
	}));
}