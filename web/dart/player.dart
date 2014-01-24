part of coUclient;

Player CurrentPlayer;

class Player
{
	int posX, posY, width, height;  
	ImageElement avatar;
  
	//for testing purposes
	//if false, player can move around with wasd and arrows, no falling
	bool doPhysicsApply = true;
  
	CanvasElement playerCanvas;
  
	Player()
	{
		//TODO: Remove hard-coded values used for testing
		posX = 0;
		posY = 550;
		width = 100;
		height = 172;
		
		avatar = new ImageElement(src: "assets/sprites/avatar.png");
		playerCanvas = new CanvasElement();
		playerCanvas.id = "playerCanvas";
		playerCanvas.width = width;
		playerCanvas.height = height;
		playerCanvas.style.left = (posX.toString()) + 'px';
		playerCanvas.style.top =  (posY.toString()) + 'px';
		gameScreen.append(playerCanvas);
		
		CurrentPlayer = this;
	}
  
	update()
	{
	    //should be more general value 'speed'
	    if (playerInput.rightKey == true)
			posX += 5;
	    if (playerInput.leftKey == true)
			posX -= 5;
	    //primitive jumping
	    if (playerInput.spaceKey == true)
			posY -= 10;
	    
	    //needs acceleration, some gravity const somewhere
	    //for jumps/falling
	    
	    if (doPhysicsApply == false)
		{
			if (playerInput.downKey == true)
				posY += 5;
			if (playerInput.upKey == true)
				posY -= 5;
	    }
	    if (doPhysicsApply == true)
		{
			if (posY < 400)
				posY += 3;
	    }
	    
	    if (posX < 0)
			posX = 0;
	    if (posX > currentStreet.bounds.width - width)
			posX = currentStreet.bounds.width - width;
	    if (posY < 0)
			posY = 0;
	    if (posY > currentStreet.bounds.height + height)
			posY = currentStreet.bounds.height + height;
					
		playerCanvas.style.left = (posX.toString()) + 'px';
		playerCanvas.style.top = (posY.toString()) + 'px';
	}
  
	render()
	{
		//Need scaling; some levels change player's apparent size
		CurrentPlayer.playerCanvas.context2D.clearRect(0, 0, width, height);
		CurrentPlayer.playerCanvas.context2D.drawImageScaled(avatar, 0, 0, width, height);
	}
}