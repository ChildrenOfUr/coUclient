part of coUclient;

main()
{
	// The player has requested that the game is to begin.
	
	// run all audio initialization tasks  
	init_audio();

	//////////////////////////////////////////////////////////////////////////////////////
	// Play the loading music.
	new Asset('./assets/system/loading.ogg').load()
		.then((Asset Loading)
		{
		    if(int.parse(prevVolume) > 0 && isMuted == '0')
		    {
		      Loading.get().volume = int.parse(prevVolume)/100;
		      querySelector('#LoadingScreen').append(Loading.get());
		      Loading.get().play();
		    }
		})
	//////////////////////////////////////////////////////////////////////////////////////
  
	// On-game-started loading tasks  
	.then((_) => load_audio())
	.then((_) => load_streets()) 
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
    
		//////////////////////////////////////////////////////////////////////////////////////
		// Play the 'doneloading' sound
		new Asset('./assets/system/game_loaded.ogg').load().then((Asset doneLoading)
		{
			if(int.parse(prevVolume) > 0 && isMuted == '0')
			{
				doneLoading.get().volume = int.parse(prevVolume)/100;
				doneLoading.get().play();
			}
		//////////////////////////////////////////////////////////////////////////////////////
		})
		.then((_) => new Street('groddle').load());
    
		// Begin the GAME!!!
		game.start();
	}); 
}