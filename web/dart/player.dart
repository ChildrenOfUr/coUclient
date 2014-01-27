part of coUclient;

Player CurrentPlayer;

class Player
{
	int posX, posY, width, height, speed;
	num yVel, yAccel = -40;
	bool jumping = false, facingRight = true;
	ImageElement avatar;
  
	//for testing purposes
	//if false, player can move around with wasd and arrows, no falling
	bool doPhysicsApply = true;
  
	CanvasElement playerCanvas;
  
	Player()
	{
		//TODO: Remove hard-coded values used for testing
		width = 100;
		height = 172;
		speed = 5;
		yVel = 0;
		posX = 0;
		posY = currentStreet.bounds.height - height;
		
		avatar = new ImageElement(src: "assets/sprites/avatar.png");
		playerCanvas = new CanvasElement();
		playerCanvas.id = "playerCanvas";
		playerCanvas.style.position = "absolute";
		playerCanvas.width = width;
		playerCanvas.height = height;
		gameScreen.append(playerCanvas);
		
		CurrentPlayer = this;
	}
  
	update(double dt)
	{
		//should be more general value 'speed'
		if (playerInput.rightKey == true)
		{
			posX += CurrentPlayer.speed;
			facingRight = true;
		}
	    if (playerInput.leftKey == true)
		{
			posX -= CurrentPlayer.speed;
			facingRight = false;
		}
			
	    //primitive jumping
	    if (playerInput.spaceKey == true && !jumping)
		{
			Random rand = new Random();
			if(rand.nextInt(4) == 3)
				yVel = -20;
			else
				yVel = -15;
			jumping = true;
		}
	    
	    //needs acceleration, some gravity const somewhere
	    //for jumps/falling	    
		if(doPhysicsApply)
		{
			yVel = yVel - yAccel * dt;
			posY = (posY + yVel)~/1;
	    }
		else
		{
			if (playerInput.downKey == true)
				posY += CurrentPlayer.speed;
			if (playerInput.upKey == true)
				posY -= CurrentPlayer.speed;
	    }
	    
	    if (posX < 0)
			posX = 0;
	    if (posX > currentStreet.bounds.width - width)
			posX = currentStreet.bounds.width - width;
	    if (posY > currentStreet.bounds.height - height)
		{
			posY = currentStreet.bounds.height - height;
			yVel = 0;
			jumping = false;
		}
	    if (posY < 0)
			posY = 0;
						
		num translateX = posX, translateY = gameScreen.clientHeight - height;
		if(posX > currentStreet.bounds.width - width/2 - gameScreen.clientWidth/2)
		{
			camera.x = currentStreet.bounds.width - gameScreen.clientWidth;
			translateX = posX - currentStreet.bounds.width + gameScreen.clientWidth; //allow character to move to screen right
		}
		else if(posX + width/2 > gameScreen.clientWidth/2)
		{
			camera.x = posX + width/2 - gameScreen.clientWidth/2;
			translateX = gameScreen.clientWidth/2 - width/2; //keep character in center of screen
		}
		else
			camera.x = 0;
		
		if(posY + height/2 < gameScreen.clientHeight/2)
		{
			camera.y = 0;
			translateY = posY;
		}
		else if(posY < currentStreet.bounds.height - height/2 - gameScreen.clientHeight/2)
		{
			num yDistanceFromBottom = currentStreet.bounds.height - posY - height/2;
			camera.y = currentStreet.bounds.height - (yDistanceFromBottom + gameScreen.clientHeight/2);
			translateY = gameScreen.clientHeight/2 - height/2;
		}
		else
		{
			camera.y = currentStreet.bounds.height - gameScreen.clientHeight;
			translateY = gameScreen.clientHeight - (currentStreet.bounds.height - posY);
		}
		
		//translateZ forces the whole operation to be gpu accelerated (which is very good)
		String transform = 'translateX('+translateX.toString()+'px) translateY('+translateY.toString()+'px) translateZ(0)';
		if(!facingRight)
			transform += ' scale(-1,1)';
		playerCanvas.style.transform = transform;

	}
  
	render()
	{
		//Need scaling; some levels change player's apparent size
		CurrentPlayer.playerCanvas.context2D.clearRect(0, 0, width, height);
		CurrentPlayer.playerCanvas.context2D.drawImageScaled(avatar, 0, 0, width, height);
	}
}