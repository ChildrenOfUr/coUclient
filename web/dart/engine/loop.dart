part of coUclient;

double timeLast = 0.0;
String lastXY = "";
// Our gameloop
loop(var dt) 
{
	CurrentPlayer.update(dt);
	
	otherPlayers.forEach((String username, Player otherPlayer)
	{
		double x = otherPlayer.posX;
		double y = otherPlayer.posY;
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
	
	//update the other clients with our position & street
	timeLast += dt;
	if(timeLast > .03 && playerSocket != null && playerSocket.readyState == WebSocket.OPEN)
	{
		String xy = CurrentPlayer.posX.toString()+","+CurrentPlayer.posY.toString();
		if(xy == lastXY) //don't send updates when the player doesn't move
			return;
		
		sendPlayerInfo();
	}
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