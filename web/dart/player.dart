part of coUclient;

Player CurrentPlayer;

class Player
{
	int width = 116, height = 137, speed = 300;
	num posX = 1.0, posY = 0.0;
	num yVel = 0, yAccel = -2400;
	bool jumping = false, moving = false, climbingUp = false, climbingDown = false, activeClimb = false, facingRight = true;
	Map<String,Animation> animations = new Map();
	Animation currentAnimation;
	ChatBubble chatBubble = null;
	Random rand = new Random();
	String intersectingObject = null;
  		
	//for testing purposes
	//if false, player can move around with wasd and arrows, no falling
	bool doPhysicsApply = true;
  
	DivElement playerParentElement;
	CanvasElement playerCanvas;
	DivElement playerName;
  
	Player([String name])
	{
		for(Platform platform in currentStreet.platforms)
		{
			if(platform.start.x == 1)
				posY = platform.start.y-height;
		}

		playerCanvas = new CanvasElement();
		
		playerName = new DivElement()
			..classes.add("playerName")
			..text = name != null ? name : chat.username;
				
		playerParentElement = new DivElement()
			..classes.add("playerParent")
			..style.width = width.toString() + "px"
			..style.height = height.toString() + "px";
		
		playerParentElement.append(playerName);
		playerParentElement.append(playerCanvas);
		gameScreen.append(playerParentElement);
	}
	
	Future<List<Animation>> loadAnimations()
	{
		//need to get background images from some server for each player based on name
		List<int> idleFrames=[], baseFrames=[], jumpUpFrames=[], fallDownFrames, landFrames, climbFrames=[];
		for(int i=0; i<57; i++)
			idleFrames.add(i);
		for(int i=0; i<12; i++)
        	baseFrames.add(i);
		for(int i=0; i<16; i++)
            jumpUpFrames.add(i);
		for(int i=0; i<19; i++)
			climbFrames.add(i);
		fallDownFrames = [16,17,18,19,20,21,22,23];
		landFrames = [24,25,26,27,28,29,30,31,32];
		animations['idle'] = new Animation("assets/sprites/idle.png","idle",2,29,idleFrames,loopDelay:new Duration(seconds:10),delayInitially:true);
		animations['base'] = new Animation("assets/sprites/base.png","base",1,15,baseFrames);
		animations['jumpup'] = new Animation("assets/sprites/jump.png","jumpup",1,33,jumpUpFrames);
		animations['falldown'] = new Animation("assets/sprites/jump.png","falldown",1,33,fallDownFrames);
		animations['land'] = new Animation("assets/sprites/jump.png","land",1,33,landFrames);
		animations['climb'] = new Animation("assets/sprites/climb.png","climb",1,19,climbFrames);
		
		List<Future> futures = new List();
		animations.forEach((String name,Animation animation) => futures.add(animation.load()));
		
		return Future.wait(futures);
	}
  
	update(double dt)
	{	
		num cameFrom = posY;
		
		//show chat message if it exists and decrement it's timeToLive
		if(chatBubble != null)
		{
			if(chatBubble.timeToLive <= 0)
			{
				chatBubble.bubble.remove();
				chatBubble = null;
			}
			else
			{
				chatBubble.timeToLive -= dt;
				playerParentElement.append(chatBubble.bubble);
			}
		}
		
		if(playerInput.upKey == true)
		{
			bool found = false;
			Rectangle playerRect = new Rectangle(posX,posY+currentStreet._data['dynamic']['ground_y'],width,height-15);
			for(Ladder ladder in currentStreet.ladders)
			{
				if(intersect(ladder.boundary,playerRect))
				{
					//if our feet are above the ladder, stop climbing
					if(playerRect.top+playerRect.height < ladder.boundary.top)
						break;
					
					posY -= speed/4 * dt;
					climbingUp = true;
					activeClimb = true;
					found = true;
					break;
				}
			}
			if(!found)
			{
				climbingUp = false;
				climbingDown = false;
				activeClimb = false;
			}
		}
		
		if(playerInput.downKey == true)
		{
			bool found = false;
			Rectangle playerRect = new Rectangle(posX,posY+currentStreet._data['dynamic']['ground_y'],width,height);
			for(Ladder ladder in currentStreet.ladders)
			{
				if(intersect(ladder.boundary,playerRect))
				{
					//if our feet are below the ladder, stop climbing
					if(playerRect.top+playerRect.height > ladder.boundary.top+ladder.boundary.height)
						break;
					
					posY += speed/4 * dt;
					climbingDown = true;
					activeClimb = true;
					found = true;
					break;
				}
			}
			if(!found)
			{
				climbingDown = false;
				climbingUp = false;
				activeClimb = false;
			}
		}
		
		if(playerInput.downKey == false && playerInput.upKey == false)
		{
			bool found = false;
			Rectangle playerRect = new Rectangle(posX,posY+currentStreet._data['dynamic']['ground_y'],width,height);
			for(Ladder ladder in currentStreet.ladders)
			{
				if(intersect(ladder.boundary,playerRect))
				{
					found = true;
					break;
				}
			}
			if(!found)
			{
				climbingDown = false;
				climbingUp = false;
			}
			activeClimb = false;
		}
		
		if(playerInput.rightKey == true)
		{
			posX += speed * dt;
			facingRight = true;
			moving = true;
		}
		else if(playerInput.leftKey == true)
		{
			posX -= speed * dt;
			facingRight = false;
			moving = true;
		}
		else
			moving = false;
			
	    //primitive jumping
		if (playerInput.jumpKey == true && !jumping && !climbingUp && !climbingDown)
		{
			Random rand = new Random();
			if(rand.nextInt(4) == 3)
				yVel = -1200;
			else
				yVel = -900;
			jumping = true;
		}
	    
	    //needs acceleration, some gravity const somewhere
	    //for jumps/falling	    
		if(doPhysicsApply && !climbingUp && !climbingDown)
		{
			yVel -= yAccel * dt;
			posY += yVel * dt;
	    }
		else
		{
			if(playerInput.downKey == true)
				posY += speed * dt;
			if(playerInput.upKey == true)
				posY -= speed * dt;
	    }
	    
	    if(posX < 0)
			posX = 0.0;
	    if(posX > currentStreet.bounds.width - width)
			posX = currentStreet.bounds.width - width;
	    
	    //check for collisions with platforms
	    if(!climbingDown && yVel >= 0)
		{
			num x = posX+width/2;
			Platform bestPlatform = _getBestPlatform(cameFrom);
			
			num goingTo = posY+height+currentStreet._data['dynamic']['ground_y'];
			num slope = (bestPlatform.end.y-bestPlatform.start.y)/(bestPlatform.end.x-bestPlatform.start.x);
			num yInt = bestPlatform.start.y - slope*bestPlatform.start.x;
			num lineY = slope*x+yInt;
			
			if(goingTo >= lineY)
			{
				posY = lineY-height-currentStreet._data['dynamic']['ground_y'];
				yVel = 0;
				jumping = false;
			}
		}
	    
	    if(posY < 0)
			posY = 0.0;	    
			
	    updateAnimation(dt);
						
		updateTransform();
		
		//check for collision with quoins
		Rectangle avatarRect = playerParentElement.getBoundingClientRect();
		querySelectorAll(".quoin").forEach((Element element)
		{
			checkCollision(avatarRect,element);
		});
		
		intersectingObject = null;
		querySelectorAll(".npc").forEach((Element element)
		{
			Rectangle npcRect = element.getBoundingClientRect();
			if(intersect(avatarRect,npcRect))
			{
				if(npcs[element.id] != null)
					npcs[element.id].glow = true;
				
				intersectingObject = element.id;
			}
			else
			{
				if(npcs[element.id] != null)
					npcs[element.id].glow = false;
			}
		});
		querySelectorAll(".plant").forEach((Element element)
		{
			Rectangle plantRect = element.getBoundingClientRect();
			if(intersect(avatarRect,plantRect))
			{
				if(plants[element.id] != null)
					plants[element.id].updateGlow(true);
				
				intersectingObject = element.id;
			}
			else
			{
				if(plants[element.id] != null)
					plants[element.id].updateGlow(false);
			}});
		}
  
	void render()
	{
		if(currentAnimation != null && currentAnimation.dirty)
		{
			//it's not obvious, but setting the width and/or height erases the current canvas as well
			playerCanvas.width = currentAnimation.width;
			playerCanvas.height = currentAnimation.height;
    		Rectangle destRect = new Rectangle(0,0,currentAnimation.width,currentAnimation.height);
    		playerCanvas.context2D.drawImageToRect(currentAnimation.spritesheet, destRect, sourceRect: currentAnimation.sourceRect);
    		currentAnimation.dirty = false;
		}
	}
	
	void updateAnimation(double dt)
	{
		bool climbing = climbingUp || climbingDown;
		if(!moving && !jumping && !climbing)
			currentAnimation = animations['idle'];
		else
		{
			//reset idle so that the 10 second delay starts over
			animations['idle'].reset();
			
			if(climbing)
			{
				currentAnimation = animations['climb'];
				currentAnimation.paused = !activeClimb;
			}
			else
			{				
				if(moving && !jumping)
    				currentAnimation = animations['base'];
    			else if(jumping && yVel < 0)
        		{
        			currentAnimation = animations['jumpup'];
        			animations['falldown'].reset();
        		}
        		else if(jumping && yVel >= 0)
        		{
        			currentAnimation = animations['falldown'];
        			animations['jumpup'].reset();
        		}
			}
		}
		
		currentAnimation.updateSourceRect(dt,holdAtLastFrame:jumping);
	}
	
	void updateTransform()
	{
		num translateX = posX, translateY = ui.gameScreenHeight - height;
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
		
		if(posY + height/2 < ui.gameScreenHeight/2)
		{
			camY = 0;
			translateY = posY;
		}
		else if(posY < currentStreet.bounds.height - height/2 - ui.gameScreenHeight/2)
		{
			num yDistanceFromBottom = currentStreet.bounds.height - posY - height/2;
			camY = currentStreet.bounds.height - (yDistanceFromBottom + ui.gameScreenHeight/2);
			translateY = ui.gameScreenHeight/2 - height/2;
		}
		else
		{
			camY = currentStreet.bounds.height - ui.gameScreenHeight;
			translateY = ui.gameScreenHeight - (currentStreet.bounds.height - posY);
		}
		
		camera.setCamera((camX~/1).toString()+','+(camY~/1).toString());
		
		//translateZ forces the whole operation to be gpu accelerated (which is very good)
		String transform = 'translateZ(0) translateX('+translateX.toString()+'px) translateY('+translateY.toString()+'px)';
		if(!facingRight)
		{
			transform += ' scale(-1,1)';
			playerName.style.transform = 'scale(-1,1)';
			
			if(chatBubble != null)
				chatBubble.textElement.style.transform = 'scale(-1,1)';
		}
		else
		{
			playerName.style.transform = 'scale(1,1)';
			
			if(chatBubble != null)
				chatBubble.textElement.style.transform = 'scale(1,1)';
		}
		
		playerParentElement.style.transform = transform;
	}
	
	void checkCollision(Rectangle avatarRect, Element element)
	{
		Rectangle quoinRect = element.getBoundingClientRect();
		if(intersect(avatarRect,quoinRect))
		{
			if(ASSET['drop'] != null && int.parse(prevVolume) > 0 && isMuted == '0')
			{
				AudioElement dropSound = ASSET['drop'].get();
    		    dropSound.volume = int.parse(prevVolume)/100;
    		    dropSound.play();
			}
			int amt = rand.nextInt(4)+1;
			Element quoinText = querySelector("#qq"+element.id+" .quoinString");
			if(element.classes.contains("currant"))
			{
				quoinText.text = "+" + amt.toString() + "\u20a1";
				setCurrants((getCurrants()+amt).toString());
			}
			else if(element.classes.contains("mood"))
			{
				quoinText.text = "+" + amt.toString() + " mood";
				setMood((getMood()+amt).toString());
			}
			else if(element.classes.contains("energy"))
			{
            	quoinText.text = "+" + amt.toString() + " energy";
            	setEnergy((getEnergy()+amt).toString());
			}
			else if(element.classes.contains("img"))
			{
            	quoinText.text = "+" + amt.toString() + " iMG";
            	setImg((getImg()+amt).toString());
			}
			querySelector("#q"+element.id).classes.add("circleExpand");
			querySelector("#qq"+element.id).classes.add("circleExpand");
			new Timer(new Duration(seconds:2), () => _removeCircleExpand(querySelector("#qq"+element.id)));
			new Timer(new Duration(milliseconds:800), () => _removeCircleExpand(querySelector("#q"+element.id)));
			element.style.display = "none"; //.remove() is very slow
			
			if(streetSocket != null && streetSocket.readyState == WebSocket.OPEN)
			{
				Map map = new Map();
    			map["remove"] = element.id;
    			map["type"] = "quoin";
    			map["streetName"] = currentStreet.label;
    			streetSocket.send(JSON.encode(map));
			}
		}
	}
	
	void _removeCircleExpand(Element element)
	{
		if(element != null)
			element.classes.remove("circleExpand");
	}
	
	bool intersect(Rectangle a, Rectangle b) 
	{
		return (a.left <= b.right &&
				b.left <= a.right &&
				a.top <= b.bottom &&
				b.top <= a.bottom);
    }
	
	//ONLY WORKS IF PLATFORMS ARE SORTED WITH
	//THE HIGHEST (SMALLEST Y VALUE) FIRST IN THE LIST
	Platform _getBestPlatform(num cameFrom)
	{
		Platform bestPlatform;
		num x = posX+width/2;
		num from = cameFrom+height+currentStreet._data['dynamic']['ground_y'];
		
		for(Platform platform in currentStreet.platforms)
		{
			if(x >= platform.start.x && x <= platform.end.x)
			{
				num slope = (platform.end.y-platform.start.y)/(platform.end.x-platform.start.x);
    			num yInt = platform.start.y - slope*platform.start.x;
    			num lineY = slope*x+yInt;
    			    			    			
    			if(bestPlatform == null)
					bestPlatform = platform;
				else
				{
					//+5 helps with upward slopes and not falling through things
					if(lineY+5 >= from)
						bestPlatform = platform;
				}
			}
		}
		
		return bestPlatform;
	}
}