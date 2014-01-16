part of coUclient;

main()
{
	// The player has requested that the game is to begin.
	// run all audio initialization tasks
	//set status text on loading screen to show progress TODO: temporary until prettier thing arrives
	querySelector("#LoadStatus").text = "Loading Audio";
	init_audio();
	
	// On-game-started loading tasks
	load_audio()
	.then((_) => load_streets()
	.then((_) => new Street('test').load())
	.then((_)
	{
		//initialize chat after street has been loaded and currentStreet.label is set
		chat.init();
		
		//if the client is mobile, wait for user to press play button so that we can do audio tricks for mobile browsers
		//else just start now
		if(window.innerWidth > 1220 && window.innerHeight > 325)
			start();
		else
		{
			querySelector("#LoadingFrame").style.display = "none";
			Element playButton = querySelector("#PlayButton");
			playButton.style.display = "inline-block";
			playButton.onClick.listen((_)
			{
				if(ui.currentSong != null)
					ui.currentSong.play();
				start();
			});
		}
	}));
}

start()
{
	// Finally finished loading. Clean up.
	
	// Peacefully fade out the loading screen.
	querySelector('#LoadingScreen').style.opacity = '0.0';
	new Timer(new Duration(seconds:1), ()
	{
		querySelector('#LoadingScreen').remove();
		if(int.parse(prevVolume) > 0 && isMuted == '0')
		{
			AudioElement doneLoading = ASSET['game_loaded'].get();
			doneLoading.volume = int.parse(prevVolume)/100;
			doneLoading.play();
		}
	});
	
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
	
	// Begin the GAME!!!
	game.start();
}