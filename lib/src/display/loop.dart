part of couclient;

double timeLast = 0.0;
String lastXY = "";
// Our gameloop
update(double dt) 
{
	CurrentPlayer.update(dt);
	
	otherPlayers.forEach((String username, Player otherPlayer)
	{
		if(otherPlayer.currentAnimation != null)
			otherPlayer.currentAnimation.updateSourceRect(dt);
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
		otherPlayer.playerParentElement.style.transform = transform;
	});
	
	quoins.forEach((String id, Quoin quoin) => quoin.update(dt));
	entities.forEach((String id, Entity entity) => entity.update(dt));
	
	//update the other clients with our position & street
	timeLast += dt;
	/*if(timeLast > .03 && playerSocket != null && playerSocket.readyState == WebSocket.OPEN)
	{
		String xy = CurrentPlayer.posX.toString()+","+CurrentPlayer.posY.toString();
		if(xy == lastXY) //don't send updates when the player doesn't move - except once every 5 seconds
		{
			if(timeLast < 5)
				return;
		}
		
		lastXY = xy;
		sendPlayerInfo();
	}*/
}