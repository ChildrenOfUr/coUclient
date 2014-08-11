part of couclient;

Player CurrentPlayer;

class Player
{
	int width = 116, height = 137, speed = 300;
	num posX = 1.0, posY = 0.0;
	num yVel = 0, yAccel = -2400;
	bool jumping = false, moving = false, climbingUp = false, climbingDown = false;
	bool activeClimb = false, facingRight = true, firstRender = true;
	Map<String,Animation> animations = new Map();
	Animation currentAnimation;
	ChatBubble chatBubble = null;
	Random rand = new Random();
	Map<String,Rectangle> intersectingObjects = {};
  		
	//for testing purposes
	//if false, player can move around with wasd and arrows, no falling
	bool doPhysicsApply = true;
  
	DivElement playerParentElement;
	CanvasElement playerCanvas;
	DivElement playerName;
  
	Player([String name])
	{
		bool found = false;
		Platform leftmost = null;
		
		for(Platform platform in currentStreet.platforms)
		{
			if(leftmost == null || platform.start.x < leftmost.start.x)
				leftmost = platform;
			
			if(platform.start.x == 1)
			{
				found = true;
				posY = platform.start.y-height;
			}
		}
		
		if(!found)
			posY = leftmost.start.y-height;

		playerCanvas = new CanvasElement()
			..style.overflow = "auto"
			..style.margin = "auto"
			..style.transform = "translateZ(0)";
		
		playerName = new DivElement()
			..classes.add("playerName")
			..text = name != null ? name : ui.username;
				
		playerParentElement = new DivElement()
			..classes.add("playerParent")
			..style.width = width.toString() + "px"
			..style.height = height.toString() + "px";
		
		playerParentElement.append(playerName);
		playerParentElement.append(playerCanvas);
		ui.worldElement.append(playerParentElement);
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
				
		animations['idle'] = new Animation("packages/couclient/sprites/idle.png","idle",2,29,idleFrames,loopDelay:new Duration(seconds:10),delayInitially:true);
		animations['base'] = new Animation("packages/couclient/sprites/base.png","base",1,15,baseFrames);
		animations['jumpup'] = new Animation("packages/couclient/sprites/jump.png","jumpup",1,33,jumpUpFrames);
		animations['falldown'] = new Animation("packages/couclient/sprites/jump.png","falldown",1,33,fallDownFrames);
		animations['land'] = new Animation("packages/couclient/sprites/jump.png","land",1,33,landFrames);
		animations['climb'] = new Animation("packages/couclient/sprites/climb.png","climb",1,19,climbFrames);
				
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
		
		if(doPhysicsApply && inputManager.upKey == true)
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
					jumping = false;
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
		
		if(doPhysicsApply && inputManager.downKey == true)
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
					jumping = false;
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
		
		if(doPhysicsApply && inputManager.downKey == false && inputManager.upKey == false)
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
		
		if(inputManager.rightKey == true)
		{
			posX += speed * dt;
			facingRight = true;
			moving = true;
		}
		else if(inputManager.leftKey == true)
		{
			posX -= speed * dt;
			facingRight = false;
			moving = true;
		}
		else
			moving = false;
			
	    //primitive jumping
		if (inputManager.jumpKey == true && !jumping && !climbingUp && !climbingDown)
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
			if(inputManager.downKey == true)
				posY += speed * dt;
			if(inputManager.upKey == true)
				posY -= speed * dt;
	    }
	    
	    if(posX < 0)
			posX = 0.0;
	    if(posX > currentStreet.bounds.width - width)
			posX = currentStreet.bounds.width - width;
	    
	    //check for collisions with platforms
	    if(doPhysicsApply && !climbingDown && yVel >= 0)
		{
			num x = posX+width/2;
			Platform bestPlatform = _getBestPlatform(cameFrom);
			
			if(bestPlatform != null)
			{
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
		}
	    
	    if(posY < 0)
			posY = 0.0;
	    
	    updateAnimation(dt);
						
		updateTransform();
		
		//check for collision with quoins
		Rectangle avatarRect = new Rectangle(posX,posY,width,height);
		querySelectorAll(".quoin").forEach((Element element)
		{
			checkCollision(element);
		});
		
		intersectingObjects = {};
		querySelectorAll(".entity").forEach((Element element)
		{
			num left = num.parse(element.attributes['translatex'].replaceAll("px", ""));
    		num top = num.parse(element.attributes['translatey'].replaceAll("px", ""));
    		num width = num.parse(element.attributes['width']);
    		num height = num.parse(element.attributes['height']);
    		Rectangle entityRect = new Rectangle(left,top,width,height);
                		
			if(intersect(avatarRect,entityRect))
			{
				if(entities[element.id] != null)
					entities[element.id].updateGlow(true);
				
				intersectingObjects[element.id] = entityRect;
			}
			else
			{
				if(entities[element.id] != null)
					entities[element.id].updateGlow(false);
			}
		});
	}
  
	void render()
	{
		if(currentAnimation != null && currentAnimation.dirty)
		{
			if(!firstRender)
			{
				Rectangle avatarRect = new Rectangle(posX,posY,currentAnimation.width,currentAnimation.height);
    			if(!intersect(camera.visibleRect,avatarRect))
    				return;
			}
			
			firstRender = false;
			
			//it's not obvious, but setting the width and/or height erases the current canvas as well
			//it is necessary to do this in order to prevent the player from moving within the frame
			//because the aniation sizes are different (walk vs idle, etc.)
			if(playerCanvas.width != currentAnimation.width || playerCanvas.height != currentAnimation.height)
			{
				playerCanvas.style.width = currentAnimation.width.toString()+"px";
				playerCanvas.style.height = currentAnimation.height.toString()+"px";
				playerCanvas.width = currentAnimation.width;
				playerCanvas.height = currentAnimation.height;
			}
			else
				playerCanvas.context2D.clearRect(0, 0, currentAnimation.width, currentAnimation.height);
			
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
		String xattr = playerParentElement.attributes['translateX'];
		String yattr = playerParentElement.attributes['translateY'];
		num prevX, prevY, prevCamX = camera.getX(), prevCamY = camera.getY();
		if(xattr != null)
			prevX = num.parse(xattr);
		else
			prevX = 0;
		if(yattr != null)
			prevY = num.parse(yattr);
		else
			prevY = 0;
				
		num translateX = posX, translateY = ui.worldHeight - height;
		num camX = camera.getX(), camY = camera.getY();
		if(posX > currentStreet.bounds.width - width/2 - ui.worldWidth/2)
		{
			camX = currentStreet.bounds.width - ui.worldWidth;
			translateX = posX - currentStreet.bounds.width + ui.worldWidth; //allow character to move to screen right
		}
		else if(posX + width/2 > ui.worldWidth/2)
		{
			camX = posX + width/2 - ui.worldWidth/2;
			translateX = ui.worldWidth/2 - width/2; //keep character in center of screen
		}
		else
			camX = 0;
		
		if(posY + height/2 < ui.worldHeight/2)
		{
			camY = 0;
			translateY = posY;
		}
		else if(posY < currentStreet.bounds.height - height/2 - ui.worldHeight/2)
		{
			num yDistanceFromBottom = currentStreet.bounds.height - posY - height/2;
			camY = currentStreet.bounds.height - (yDistanceFromBottom + ui.worldHeight/2);
			translateY = ui.worldHeight/2 - height/2;
		}
		else
		{
			camY = currentStreet.bounds.height - ui.worldHeight;
			translateY = ui.worldHeight - (currentStreet.bounds.height - posY);
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
		playerParentElement.attributes['translateX'] = translateX.toString();
		playerParentElement.attributes['translateY'] = translateY.toString();
		num diffX = translateX-prevX, diffY = translateY-prevY;
	}
	
	void checkCollision(Element element)
	{
		//if the main screen is hidden don't check for quoin collection
		//this should avoid a bug where the player can pick up all the quoins
		//on a street at once because the bounding boxes all squish together
		if(ui.mainElement.hidden == true)
			return;
		
		if(element.attributes['collected'] == "true")
			return;
		
		CanvasElement canvas = element as CanvasElement;
		num left = num.parse(canvas.style.left.replaceAll("px", ""));
		num top = currentStreet.bounds.height - num.parse(canvas.style.bottom.replaceAll("px", "")) - canvas.height;
		Rectangle quoinRect = new Rectangle(left,top,canvas.width,canvas.height);
		
		Rectangle avatarRect = new Rectangle(posX,posY,width,height);
		
		if(intersect(avatarRect,quoinRect))
		{
			soundManager.playSound('quoinSound');
			
			element.attributes['collected'] = "true";
			
			int amt = rand.nextInt(4)+1;
			Element quoinText = querySelector("#qq"+element.id+" .quoinString");
			if(element.classes.contains("currant"))
			{
				quoinText.text = "+" + amt.toString() + "\u20a1";
				metabolics.setCurrants(metabolics.getCurrants()+amt);
			}
			else if(element.classes.contains("mood"))
			{
				quoinText.text = "+" + amt.toString() + " mood";
				metabolics.setMood(metabolics.getMood()+amt);
			}
			else if(element.classes.contains("energy"))
			{
            	quoinText.text = "+" + amt.toString() + " energy";
            	metabolics.setEnergy(metabolics.getEnergy()+amt);
			}
			else if(element.classes.contains("img"))
			{
            	quoinText.text = "+" + amt.toString() + " iMG";
            	metabolics.setImg(metabolics.getImg()+amt);
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

bool intersect(Rectangle a, Rectangle b) 
{
	return (a.left <= b.right &&
			b.left <= a.right &&
			a.top <= b.bottom &&
			b.top <= a.bottom);
}