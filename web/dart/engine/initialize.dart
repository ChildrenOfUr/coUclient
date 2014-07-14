part of coUclient;

WebSocket playerSocket;
AudioInstance loadingMusic;

main()
{
	//disable the mobile stylesheet
	//we do it here instead of in the html so that it loads
	//also firefox ignores the disabled attribute in html
	if(localStorage["interface"] == null || localStorage["interface"] == "desktop")
		(querySelector("#MobileStyle") as LinkElement).disabled = true;
	else
	{
		querySelector("#ThemeSwitcher").text = "Desktop View";
		querySelector("#InventoryDrawer").append(querySelector('#InventoryBar'));
		querySelector("#InventoryDrawer").append(querySelector('#InventoryBag'));
	}

	// The player has requested that the game is to begin.
	// run all audio initialization tasks
	//set status text on loading screen to show progress TODO: temporary until prettier thing arrives
	querySelector("#LoadStatus").text = "Loading Audio";
	init_audio();
	
	// On-game-started loading tasks
	load_audio()
	.then((_)
	{
		//play loading music while loading everything else
		if(useWebAudio)
			loadingMusic = playSound('loading',looping:true);
		
		load_streets()
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

    			//if the client is mobile, wait for user to press play button so that we can do audio tricks for mobile browsers
    			//else just start now
    			if(window.innerWidth > 1220 && window.innerHeight > 325)
    				start();
    			else
    			{
    				querySelector("#LoadingFrame").style.display = "none";
    				Element playButton = querySelector("#PlayButton");
    				playButton.text = "Play";
    				playButton.style.display = "inline-block";
    				playButton.onClick.first.then((_) => start());
    			}
    		});
    	}));
	});
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
	if(int.parse(prevVolume) > 0 && isMuted == '0')
	{
		if(ASSET['game_loaded'] != null)
		{
			AudioElement doneLoading = ASSET['game_loaded'].get();
			doneLoading.volume = int.parse(prevVolume)/100;
			doneLoading.play();
		}
	}
	
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
	
	refreshClock();
	//update the clock once every 10 seconds
	new Timer.periodic(new Duration(seconds:10), (Timer timer)
	{
		// Update clock
		refreshClock();
	});
	    	
	stopSound(loadingMusic);
	playSound('game_loaded');
        					
	// Begin the GAME!!!
	gameLoop(0.0);
}