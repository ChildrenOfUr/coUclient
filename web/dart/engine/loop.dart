part of coUclient;

double timeLast = 0.0;
String lastXY = "";
// Our gameloop
loop() 
{
	print("inside loop");
	CurrentPlayer.update(game.dt);
	print("updated current player");
	
	otherPlayers.forEach((String username, Player otherPlayer)
	{
		int x = otherPlayer.posX;
		int y = otherPlayer.posY;
		String transform = "translateY(${y}px) translateX(${x}px) translateZ(0)";
		if(!otherPlayer.facingRight)
		{
			transform += ' scale(-1,1)';
			otherPlayer.playerName.style.transform = 'scale(-1,1)';
			
			if(otherPlayer.chatBubble != null)
				otherPlayer.chatBubble.textElement.style.transform = 'scale(-1,1)';
		}
		else
		{
			transform += ' scale(1,1)';
			otherPlayer.playerName.style.transform = 'scale(1,1)';
			
			if(otherPlayer.chatBubble != null)
				otherPlayer.chatBubble.textElement.style.transform = 'scale(1,1)';
		}
		otherPlayer.playerCanvas.style.transform = transform;
	});
	print("updated other players");
	
	//update the other clients with our position & street
	timeLast += game.dt;
	if(timeLast > .015 && playerSocket != null && playerSocket.readyState == WebSocket.OPEN)
	{
		String xy = CurrentPlayer.posX.toString()+","+CurrentPlayer.posY.toString();
		if(xy == lastXY) //don't send updates when the player doesn't move
			return;
		
		sendPlayerInfo();
	}
	print("sent currentplayer info");
}

sendPlayerInfo()
{
	String xy = CurrentPlayer.posX.toString()+","+CurrentPlayer.posY.toString();
	timeLast = 0.0;
	Map map = new Map();
	map["username"] = chat.username;
	map["xy"] = xy;
	map["street"] = currentStreet.label;
	map["facingRight"] = CurrentPlayer.facingRight.toString();
	map["animation"] = CurrentPlayer.currentAnimation.animationName;
	if(CurrentPlayer.chatBubble != null)
		map["bubbleText"] = CurrentPlayer.chatBubble.text;
	playerSocket.send(JSON.encode(map));
}