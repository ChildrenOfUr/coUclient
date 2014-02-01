part of coUclient;

Player CurrentPlayer;

class Player
{
	int posX, posY, width, height, canvasHeight, speed;
	num yVel, yAccel = -40;
	bool jumping = false, moving = false, facingRight = true;
	Map<String,Animation> animations = new Map();
	Animation currentAnimation;
  		
	//for testing purposes
	//if false, player can move around with wasd and arrows, no falling
	bool doPhysicsApply = true;
  
	DivElement playerCanvas;
	DivElement avatar;
	DivElement playerName;
  
	Player()
	{
		//TODO: Remove hard-coded values used for testing
		width = 116;
		height = 137;
		speed = 5;
		yVel = 0;
		posX = 0;
		posY = currentStreet.bounds.height - 170;
				
		playerCanvas = new DivElement()
			..style.display = "inline-block"
			..style.textAlign = "center";
		playerName = new DivElement()
			..text = chat.username;
		
		avatar = new DivElement();
		avatar.id = "playerCanvas";
		
		playerCanvas.append(playerName);
		playerCanvas.append(avatar);
		
		gameScreen.append(playerCanvas);
		
		canvasHeight = playerCanvas.clientHeight;
				
		CurrentPlayer = this;
	}
	
	Future<List<Animation>> loadAnimations()
	{
		//need to get background images from some server for each player based on name
		animations['idle'] = new Animation("assets/sprites/idle.png",'idle');
		animations['base'] = new Animation("assets/sprites/base.png",'base');
		animations['jump'] = new Animation("assets/sprites/jump.png",'jump');
		animations['stillframe'] = new Animation("assets/sprites/base.png",'stillframe');
		
		List<Future> futures = new List();
		animations.forEach((String name,Animation animation) => futures.add(animation.load()));
		
		return Future.wait(futures);
	}
  
	update(double dt)
	{
		//should be more general value 'speed'
		if (playerInput.rightKey == true)
		{
			posX += CurrentPlayer.speed;
			facingRight = true;
			moving = true;
		}
		else if (playerInput.leftKey == true)
		{
			posX -= CurrentPlayer.speed;
			facingRight = false;
			moving = true;
		}
		else
			moving = false;
			
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
	    if (posY > currentStreet.bounds.height - canvasHeight)
		{
			posY = currentStreet.bounds.height - canvasHeight;
			yVel = 0;
			jumping = false;
		}
	    if (posY < 0)
			posY = 0;
			
		if(!moving && !jumping)
			currentAnimation = animations['idle'];
		else if(moving && !jumping)
			currentAnimation = animations['base'];
		else if(jumping)
			currentAnimation = animations['jump'];
		else
			currentAnimation = animations['stillframe'];
		
		if(!avatar.style.backgroundImage.contains(currentAnimation.backgroundImage))
		{
			avatar.style.backgroundImage = 'url('+currentAnimation.backgroundImage+')';
			avatar.style.width = currentAnimation.width.toString()+'px';
			avatar.style.height = currentAnimation.height.toString()+'px';
			avatar.style.animation = currentAnimation.animationStyleString;
			canvasHeight = currentAnimation.height+50;
		}
						
		num translateX = posX, translateY = ui.gameScreenHeight - canvasHeight;
		num camX = camera.getX(), camY = camera.getY();
		if(posX > currentStreet.bounds.width - width/2 - ui.gameScreenWidth/2)
		{
			camX = currentStreet.bounds.width - ui.gameScreenWidth;
			translateX = posX - currentStreet.bounds.width + ui.gameScreenWidth; //allow character to move to screen right
		}
		else if(posX + width/2 > ui.gameScreenWidth/2)
		{
			camX = posX + width/2 - ui.gameScreenWidth/2;
			translateX = ui.gameScreenWidth/2 - width/2; //keep character in center of screen
		}
		else
			camX = 0;
		
		if(posY + canvasHeight/2 < ui.gameScreenHeight/2)
		{
			camY = 0;
			translateY = posY;
		}
		else if(posY < currentStreet.bounds.height - canvasHeight/2 - ui.gameScreenHeight/2)
		{
			num yDistanceFromBottom = currentStreet.bounds.height - posY - canvasHeight/2;
			camY = currentStreet.bounds.height - (yDistanceFromBottom + ui.gameScreenHeight/2);
			translateY = ui.gameScreenHeight/2 - canvasHeight/2;
		}
		else
		{
			camY = currentStreet.bounds.height - ui.gameScreenHeight;
			translateY = ui.gameScreenHeight - (currentStreet.bounds.height - posY);
		}
		
		camera.setCamera(camX.toString()+','+camY.toString());
		
		//translateZ forces the whole operation to be gpu accelerated (which is very good)
		String transform = 'translateZ(0) translateX('+translateX.toString()+'px) translateY('+translateY.toString()+'px)';
		if(!facingRight)
		{
			transform += ' scale(-1,1)';
			playerName.style.transform = 'scale(-1,1)';
		}
		else
			playerName.style.transform = 'scale(1,1)';
		playerCanvas.style.transform = transform;
	}
  
	render()
	{
		//Need scaling; some levels change player's apparent size
		//scaling should be done as needed, not in render cycle
		//CurrentPlayer.playerCanvas.context2D.clearRect(0, 0, width, height);
		//CurrentPlayer.playerCanvas.context2D.drawImage(avatar, 0, 0);
	}
}