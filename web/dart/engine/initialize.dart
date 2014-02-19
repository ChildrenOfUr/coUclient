part of coUclient;

WebSocket playerSocket;
Map<String,Player> otherPlayers;

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
	.then((_) => new Street('test').load()
	.then((_)
	{
		//initialize chat after street has been loaded and currentStreet.label is set
		chat.init();
		
		otherPlayers = new Map();
		playerSocket = new WebSocket("ws://couserver.herokuapp.com/playerUpdate");
		playerSocket.onMessage.listen((MessageEvent event)
		{
			Map map = JSON.decode(event.data);
			if(map["changeStreet"] != null)
			{
				if(map["changeStreet"] != currentStreet.label) //someone left this street
				{
					removeOtherPlayer(map);
				}
				else //someone joined
				{
					createOtherPlayer(map);
				}
			}
			else if(map["disconnect"] != null)
			{
				removeOtherPlayer(map);
			}
			else if(otherPlayers[map["username"]] == null)
			{
				createOtherPlayer(map);
			}
			else //update a current otherPlayer
			{
				updateOtherPlayer(map,otherPlayers[map["username"]]);
			}
		});
		
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
				playButton.onClick.first.then((_)
				{
					if(ui.currentSong != null && int.parse(prevVolume) > 0 && isMuted == '0')
						ui.currentSong.play();
					start();
				});
			}
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
	    	
	// Begin the GAME!!!
	gameLoop(0.0);
}

createOtherPlayer(Map map)
{
	Player otherPlayer = new Player(map["username"]);
	
	updateOtherPlayer(map,otherPlayer);
	
	otherPlayers[map["username"]] = otherPlayer;
	querySelector("#PlayerHolder").append(otherPlayer.playerCanvas);
}

updateOtherPlayer(Map map, Player otherPlayer)
{
	otherPlayer.currentAnimation = CurrentPlayer.animations[map["animation"]];
	if(!otherPlayer.avatar.style.backgroundImage.contains(otherPlayer.currentAnimation.backgroundImage))
	{
		otherPlayer.avatar.style.backgroundImage = 'url('+otherPlayer.currentAnimation.backgroundImage+')';
		otherPlayer.avatar.style.width = otherPlayer.currentAnimation.width.toString()+'px';
		otherPlayer.avatar.style.height = otherPlayer.currentAnimation.height.toString()+'px';
		otherPlayer.avatar.style.animation = otherPlayer.currentAnimation.animationStyleString;
		otherPlayer.canvasHeight = otherPlayer.currentAnimation.height+50;
	}
	
	otherPlayer.playerCanvas.style.position = "absolute";
	otherPlayer.playerCanvas.id = "player-"+map["username"];
	

	double x = double.parse(map["xy"].split(',')[0]);
	double y = double.parse(map["xy"].split(',')[1]);

	otherPlayer.posX = x;
	otherPlayer.posY = y;
	
	if(map["bubbleText"] != null)
	{
		if(otherPlayer.chatBubble == null)
			otherPlayer.chatBubble = new ChatBubble(map["bubbleText"]);
		otherPlayer.playerCanvas.append(otherPlayer.chatBubble.bubble);
	}
	else if(otherPlayer.chatBubble != null)
	{
		otherPlayer.chatBubble.bubble.remove();
		otherPlayer.chatBubble = null;
	}
	
	bool facingRight = false;
	if(map["facingRight"] == "true")
		facingRight = true;
	otherPlayer.facingRight = facingRight;
}

removeOtherPlayer(Map map)
{
	otherPlayers.remove(map["username"]);
	Element otherPlayer = querySelector("#player-"+map["username"]);
	if(otherPlayer != null)
		otherPlayer.remove();
}