part of coUclient;

double timeLast = 0.0;
// Our gameloop
loop() 
{
	CurrentPlayer.update(game.dt);
	
	otherPlayers.forEach((String username, Player otherPlayer)
	{
		int x = otherPlayer.posX;
		int y = otherPlayer.posY;
		otherPlayer.playerCanvas.style.top = y.toString()+'px';
		otherPlayer.playerCanvas.style.left = x.toString()+'px';
	});
	
	//update the other clients with our position & street
	timeLast += game.dt;
	if(timeLast > .1 && playerSocket != null && playerSocket.readyState == WebSocket.OPEN)
	{
		timeLast = 0.0;
		Map map = new Map();
		map["username"] = chat.username;
		map["xy"] = CurrentPlayer.posX.toString()+","+CurrentPlayer.posY.toString();
		map["street"] = currentStreet.label;
		map["facingRight"] = CurrentPlayer.facingRight.toString();
		map["animation"] = CurrentPlayer.currentAnimation.animationName;
		playerSocket.send(JSON.encode(map));
	}
}