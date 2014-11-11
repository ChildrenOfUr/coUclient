part of couclient;

Player CurrentPlayer;

class Player
{
	int width = 116, height = 137, speed = 300;
	num posX = 1.0, posY = 0.0;
	num yVel = 0, yAccel = -2400;
	bool jumping = false, moving = false, climbingUp = false, climbingDown = false;
	bool activeClimb = false, lastClimbStatus = false, facingRight = true, firstRender = true;
	Map<String,Animation> animations = new Map();
	Animation currentAnimation;
	ChatBubble chatBubble = null;
	Random rand = new Random();
	Map<String,Rectangle> intersectingObjects = {};
	String username;
	int jumpcount = 0;
	Timer jumpTimer;

	//for testing purposes
	//if false, player can move around with wasd and arrows, no falling
	bool doPhysicsApply = true;

	DivElement playerParentElement;
	CanvasElement playerCanvas;
	DivElement playerName;

	Player(this.username)
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
			posY = 0.0;

		playerCanvas = new CanvasElement()
			..className = "playerCanvas"
			..style.overflow = "auto"
			..style.margin = "auto";

		playerName = new DivElement()
			..classes.add("playerName")
			..text = username;

		playerParentElement = new DivElement()
			..classes.add("playerParent")
			..style.width = width.toString() + "px"
			..style.height = height.toString() + "px";

		playerParentElement.append(playerName);
		playerParentElement.append(playerCanvas);
		view.worldElement.append(playerParentElement);
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

		List<Future> futures = new List();

		futures.add(HttpRequest.requestCrossOrigin('http://robertmcdermot.com:8181/getSpritesheets?username=$username')
			.then((String response)
			{
				Map spritesheets = JSON.decode(response);
				String idle, base, jump, climb;
				if(spritesheets['base'] == null)
				{
					idle = 'assets/sprites/idle.png';
					base = 'assets/sprites/base.png';
					jump = 'assets/sprites/jump.png';
					climb = 'assets/sprites/climb.png';
				}
				else
				{
					idle = spritesheets['idle2'];
					base = spritesheets['base'];
					jump = spritesheets['jump'];
					climb = spritesheets['climb'];
				}
				animations['idle'] = new Animation(idle,"idle",2,29,idleFrames,loopDelay:new Duration(seconds:10),delayInitially:true);
	    		animations['base'] = new Animation(base,"base",1,15,baseFrames);
	    		animations['jumpup'] = new Animation(jump,"jumpup",1,33,jumpUpFrames);
	    		animations['falldown'] = new Animation(jump,"falldown",1,33,fallDownFrames);
	    		animations['land'] = new Animation(jump,"land",1,33,landFrames);
	    		animations['climb'] = new Animation(climb,"climb",1,19,climbFrames);

	    		animations.forEach((String name,Animation animation) => futures.add(animation.load()));
			}));

		return Future.wait(futures);
	}

	update(double dt)
	{
		num cameFrom = posY;

		//show chat message if it exists and decrement it's timeToLive
		if(chatBubble != null)
			chatBubble.update(dt);

		if(doPhysicsApply && inputManager.upKey == true)
		{
			bool found = false;
			Rectangle playerRect = new Rectangle(posX,posY+currentStreet.streetData['dynamic']['ground_y'],width,height-15);
			for(Ladder ladder in currentStreet.ladders)
			{
				if(intersect(ladder.bounds,playerRect))
				{
					//if our feet are above the ladder, stop climbing
					if(playerRect.top+playerRect.height < ladder.bounds.top)
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
			Rectangle playerRect = new Rectangle(posX,posY+currentStreet.streetData['dynamic']['ground_y'],width,height);
			for(Ladder ladder in currentStreet.ladders)
			{
				if(intersect(ladder.bounds,playerRect))
				{
					//if our feet are below the ladder, stop climbing
					if(playerRect.top+playerRect.height > ladder.bounds.top+ladder.bounds.height)
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
			Rectangle playerRect = new Rectangle(posX,posY+currentStreet.streetData['dynamic']['ground_y'],width,height);
			for(Ladder ladder in currentStreet.ladders)
			{
				if(intersect(ladder.bounds,playerRect))
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
			if(jumpTimer != null)
				jumpTimer.cancel();
			if(jumpcount == 2)
			{
				yVel = -1500;
				jumpcount = 0;
			}
			else
			{
				jumpcount++;
				jumpTimer = new Timer(new Duration(seconds:4), () => jumpcount = 0);
				yVel = -1000;
			}
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
		if(doPhysicsApply && !climbingDown && !climbingUp && yVel >= 0)
		{
			num x = posX+width/2;
			Platform bestPlatform = _getBestPlatform(cameFrom);

			if(bestPlatform != null)
			{
				num goingTo = posY+height+currentStreet.streetData['dynamic']['ground_y'];
				num slope = (bestPlatform.end.y-bestPlatform.start.y)/(bestPlatform.end.x-bestPlatform.start.x);
				num yInt = bestPlatform.start.y - slope*bestPlatform.start.x;
				num lineY = slope*x+yInt;

				if(goingTo >= lineY)
				{
					posY = lineY-height-currentStreet.streetData['dynamic']['ground_y'];
					yVel = 0;
					jumping = false;
				}
			}
		}

		updateAnimation(dt);
		updateTransform();

		//check for collision with quoins
		Rectangle avatarRect = new Rectangle(posX,posY,width,height);
		querySelectorAll(".quoin").forEach((Element element) => checkCollision(element));

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
		if(currentAnimation != null && currentAnimation.loaded && currentAnimation.dirty)
		{
			if(!firstRender)
			{
				Rectangle avatarRect = new Rectangle(posX,posY,currentAnimation.width,currentAnimation.height);
				if(!intersect(camera.visibleRect,avatarRect))
					return;
			}

			firstRender = false;

			if(playerCanvas.width != currentAnimation.width || playerCanvas.height != currentAnimation.height)
			{
				playerCanvas.style.width = currentAnimation.width.toString()+"px";
				playerCanvas.style.height = currentAnimation.height.toString()+"px";
				playerCanvas.width = currentAnimation.width;
				playerCanvas.height = currentAnimation.height;
				int x = -((currentAnimation.width-width)~/2);
                int y = -((currentAnimation.height-height));
                playerCanvas.style.transform = "translateX(${x}px) translateY(${y}px)";
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
				if(activeClimb != lastClimbStatus)
				{
					//force a player update to be sent right now
					timeLast = 5.0;
					lastClimbStatus = activeClimb;
				}
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

		num translateX = posX, translateY = view.worldElement.clientWidth - height;

		num camX = camera.getX(), camY = camera.getY();
		if(posX > currentStreet.bounds.width - width/2 - view.worldElement.clientWidth/2)
		{
			camX = currentStreet.bounds.width - view.worldElement.clientWidth;
			translateX = posX - currentStreet.bounds.width + view.worldElement.clientWidth; //allow character to move to screen right
		}
		else if(posX + width/2 > view.worldElement.clientWidth/2)
		{
			camX = posX + width/2 - view.worldElement.clientWidth/2;
			translateX = view.worldElement.clientWidth/2 - width/2; //keep character in center of screen
		}
		else
			camX = 0;

		if(posY + height/2 < view.worldElement.clientWidth/2)
		{
			camY = 0;
			translateY = posY;
		}
		else if(posY < currentStreet.bounds.height - height/2 - view.worldElement.clientHeight/2)
		{
			num yDistanceFromBottom = currentStreet.bounds.height - posY - height/2;
			camY = currentStreet.bounds.height - (yDistanceFromBottom + view.worldElement.clientHeight/2);
			translateY = view.worldElement.clientHeight/2 - height/2;
		}
		else
		{
			camY = currentStreet.bounds.height - view.worldElement.clientHeight;
			translateY = view.worldElement.clientHeight - (currentStreet.bounds.height - posY);
		}

		camera.setCameraPosition(camX~/1,camY~/1);

		//translateZ forces the whole operation to be gpu accelerated (which is very good)
		String transform = 'translateX('+translateX.toString()+'px) translateY('+translateY.toString()+'px)';
		if(!facingRight)
		{
			transform += ' scale(-1,1)';
			playerName.style.transform = 'translateY(calc(-100% - 34px)) scale(-1,1)';

			if(chatBubble != null)
			chatBubble.textElement.style.transform = 'scale(-1,1)';
		}
		else
		{
			playerName.style.transform = 'translateY(calc(-100% - 34px)) scale(1,1)';

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
		//if(querySelector('#MainScreen').hidden == true)
		//return;

		if(element.attributes['collected'] == "true")
		return;

		CanvasElement canvas = element as CanvasElement;
		num left = num.parse(canvas.style.left.replaceAll("px", ""));
		num top = currentStreet.bounds.height - num.parse(canvas.style.bottom.replaceAll("px", "")) - canvas.height;
		Rectangle quoinRect = new Rectangle(left,top,canvas.width,canvas.height);

		Rectangle avatarRect = new Rectangle(posX,posY,width,height);

		if(intersect(avatarRect,quoinRect))
		{
			audio.playSound('quoinSound');

			element.attributes['collected'] = "true";

			int amt = rand.nextInt(4)+1;
			int quoinMultiplier = 1;
			// TODO: change 1 to the real quoin multiplier
			amt = amt * quoinMultiplier;
			Element quoinText = querySelector("#qq"+element.id+" .quoinString");

			var quoinType = "";

			if (element.classes.contains("currant")) {
				quoinType = "currant";
			}
			else if (element.classes.contains("mood")) {
				quoinType = "mood";
			}
			else if (element.classes.contains("energy")) {
				quoinType = "energy";
			}
			else if (element.classes.contains("img")) {
				quoinType = "img";
			}
			else if (element.classes.contains("favor")) {
				quoinType = "favor";
			}
			else if (element.classes.contains("time")) {
				quoinType = "time";
			}
			else if (element.classes.contains("mystery")) {
				quoinType = "mystery";
			}
			else if (element.classes.contains("quarazy")) {
				quoinType = "quarazy";
			}

			switch (quoinType) {
				case "currant" :
				if (amt == 1) {
					quoinText.text = "+" + amt.toString() + " currant";
				}
				else {
					quoinText.text = "+" + amt.toString() + " currants";
				}
				metabolics.setCurrants(metabolics.getCurrants()+amt);
				break;

				case "mood" :
				quoinText.text = "+" + amt.toString() + " mood";
				metabolics.setMood(metabolics.getMood()+amt);
				break;

				case "energy" :
				quoinText.text = "+" + amt.toString() + " energy";
				metabolics.setEnergy(metabolics.getEnergy()+amt);
				break;

				case "img" :
				quoinText.text = "+" + amt.toString() + " iMG";
				metabolics.setImg(metabolics.getImg()+amt);
				break;

				case "favor" :
				// TODO : add code for favor
				break;

				case "time" :
				// TODO : what DOES time do?
				break;

				case "mystery" :
				var mystType = "";
				var mystTypeNum = rand.nextInt(2);
				switch (mystTypeNum) {
					case 0 :
					mystType = "mood";
					quoinText.text = "+" + amt.toString() + " " + mystType;
					metabolics.setMood(metabolics.getMood()+amt);
					break;

					case 1 :
					mystType = "energy";
					quoinText.text = "+" + amt.toString() + " " + mystType;
					metabolics.setEnergy(metabolics.getEnergy()+amt);
					break;

					case 2 :
					mystType = "iMG";
					quoinText.text = "+" + amt.toString() + " " + mystType;
					metabolics.setImg(metabolics.getImg()+amt);
					break;

					// TODO : add favor when favor is a thing
					// TODO : add time when time is a thing
					// TODO : increase random number range to include these two
				}
				break;

				case "quarazy" :
				amt = amt * 7;
				quoinText.text = "+" + amt.toString() + " iMG";
				metabolics.setImg(metabolics.getImg()+amt);
				break;
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
		num feetY = cameFrom+height+currentStreet.streetData['dynamic']['ground_y'];
		num bestDiffY = 1000;

		for(Platform platform in currentStreet.platforms)
		{
			if(x >= platform.start.x && x <= platform.end.x)
			{
				num slope = (platform.end.y-platform.start.y)/(platform.end.x-platform.start.x);
				num yInt = platform.start.y - slope*platform.start.x;
				num lineY = slope*x+yInt;
				num diffY = (feetY-lineY).abs();

				if(bestPlatform == null)
				bestPlatform = platform;
				else
				{
					if((lineY >= feetY || !jumping && feetY > lineY && feetY-(height/2) < lineY) && diffY < bestDiffY)
					{
						bestPlatform = platform;
						bestDiffY = diffY;
					}
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