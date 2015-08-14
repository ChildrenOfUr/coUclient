part of couclient;

Player CurrentPlayer;

class Player {
	int width = 116, height = 137, speed = 300;
	num posX, posY;
	num yVel = 0, yAccel = -2400;
	bool jumping = false, moving = false, climbingUp = false, climbingDown = false;
	bool activeClimb = false, lastClimbStatus = false, facingRight = true, firstRender = true;
	Map<String, Animation> animations = new Map();
	Animation currentAnimation;
	ChatBubble chatBubble = null;
	Random rand = new Random();
	Map<String, Rectangle> intersectingObjects = {};
	String username;
	int jumpcount = 0;
	Timer jumpTimer;
	MutableRectangle avatarRect = new MutableRectangle(0, 0, 0, 0);

	//for testing purposes
	//if false, player can move around with wasd and arrows, no falling
	bool doPhysicsApply = true;

	DivElement playerParentElement;
	CanvasElement playerCanvas;
	DivElement playerName;

	Player(this.username) {
		posX = metabolics.currentStreetX;
		posY = metabolics.currentStreetY;

		if (posX == 1.0 && posY == 0.0) {
			bool found = false;
			Platform leftmost = null;

			for (Platform platform in currentStreet.platforms) {
				if (leftmost == null || platform.start.x < leftmost.start.x)
					leftmost = platform;

				if (platform.start.x == 1) {
					found = true;
					posY = platform.start.y - height;
				}
			}

			if (!found)
				posY = 0.0;
		}

		playerCanvas = new CanvasElement()
			..className = "playerCanvas"
			..style.overflow = "auto"
			..style.margin = "auto";

		playerName = new DivElement()
			..classes.add("playerName")
			..text = username;

		playerParentElement = new DivElement()
			..classes.add("playerParent")
			..id = "pc-player-$username"
			..style.width = width.toString() + "px"
			..style.height = height.toString() + "px";

		if (username != game.username) {
			playerParentElement.append(playerName);
		}
		playerParentElement.append(playerCanvas);
		view.worldElement.append(playerParentElement);
	}

	Future<List<Animation>> loadAnimations() {
		//need to get background images from some server for each player based on name
		List<int> idleFrames = [], baseFrames = [], jumpUpFrames = [], fallDownFrames, landFrames, climbFrames = [];
		for (int i = 0; i < 57; i++) {
			idleFrames.add(i);
		}
		for (int i = 0; i < 12; i++) {
			baseFrames.add(i);
		}
		for (int i = 0; i < 16; i++) {
			jumpUpFrames.add(i);
		}
		for (int i = 0; i < 19; i++) {
			climbFrames.add(i);
		}
		fallDownFrames = [16, 17, 18, 19, 20, 21, 22, 23];
		landFrames = [24, 25, 26, 27, 28, 29, 30, 31, 32];

		List<Future> futures = new List();

		futures.add(HttpRequest.requestCrossOrigin('http://${Configs.utilServerAddress}/getSpritesheets?username=$username')
		.then((String response) {
			Map spritesheets = JSON.decode(response);
			String idle, base, jump, climb;
			if (spritesheets['base'] == null) {
				idle = 'files/sprites/idle.png';
				base = 'files/sprites/base.png';
				jump = 'files/sprites/jump.png';
				climb = 'files/sprites/climb.png';
			}
			else {
				idle = spritesheets['idle2'];
				base = spritesheets['base'];
				jump = spritesheets['jump'];
				climb = spritesheets['climb'];
			}
			animations['idle'] = new Animation(idle, "idle", 2, 29, idleFrames, loopDelay:new Duration(seconds:10), delayInitially:true);
			animations['base'] = new Animation(base, "base", 1, 15, baseFrames);
			animations['die'] = new Animation(base, "die", 1, 15, [12, 13], loops:false);
			animations['jumpup'] = new Animation(jump, "jumpup", 1, 33, jumpUpFrames);
			animations['falldown'] = new Animation(jump, "falldown", 1, 33, fallDownFrames);
			animations['land'] = new Animation(jump, "land", 1, 33, landFrames);
			animations['climb'] = new Animation(climb, "climb", 1, 19, climbFrames);

			animations.forEach((String name, Animation animation) => futures.add(animation.load()));
		}));

		return Future.wait(futures);
	}

	update(double dt) {
		if(!currentStreet.loaded) {
			return;
		}

		num cameFrom = posY;

		//show chat message if it exists and decrement it's timeToLive
		if (chatBubble != null) {
			chatBubble.update(dt);
		}

		updateLadderStatus(dt);

		if (doPhysicsApply && inputManager.downKey == false && inputManager.upKey == false) {
			// not moving up or down

			bool found = false;
			Rectangle playerRect = new Rectangle(posX, posY + currentStreet.groundY, width, height);
			for (Ladder ladder in currentStreet.ladders) {
				if (intersect(ladder.bounds, playerRect)) {
					// touching a ladder
					found = true;
					break;
				}
			}
			if (!found) {
				// not touching a ladder
				climbingDown = false;
				climbingUp = false;
			}
			activeClimb = false;
		}

		if (inputManager.rightKey == true) {
			// moving right
			posX += speed * dt;
			facingRight = true;
			moving = true;
			updateLadderStatus(dt);
		}
		else if (inputManager.leftKey == true) {
			// moving left
			posX -= speed * dt;
			facingRight = false;
			moving = true;
			updateLadderStatus(dt);
		}
		else {
			// not moving
			moving = false;
		}

		//primitive jumping
		if (inputManager.jumpKey == true && !jumping && !climbingUp && !climbingDown) {
			num jumpMultiplier;
			if (querySelector("#buff-pie") != null) {
				jumpMultiplier = 0.65;
			} else if (querySelector("#buff-spinach") != null) {
				jumpMultiplier = 1.65;
			} else {
				jumpMultiplier = 1;
			}

			if (jumpTimer == null) {
				// start timer
				jumpTimer = new Timer(new Duration(seconds:3), () {
					// normal jump
					jumpcount = 0;
					jumpTimer.cancel();
					jumpTimer = null;
				});
			}
			if (jumpcount == 2) {
				// triple jump
				yVel = -1560 * jumpMultiplier;
				jumpcount = 0;
				jumpTimer.cancel();
				jumpTimer = null;
				if (!activeClimb) {
					audio.playSound('tripleJump');
				}
			}
			else {
				// normal jump
				jumpcount++;
				yVel = -1000 * jumpMultiplier;
			}
			jumping = true;
		}

		//needs acceleration, some gravity const somewhere
		//for jumps/falling
		if (doPhysicsApply && !climbingUp && !climbingDown) {
			// walking
			yVel -= yAccel * dt;
			posY += yVel * dt;
		} else {
			// climbing
			if (inputManager.downKey == true)
				posY += speed * dt;
			if (inputManager.upKey == true)
				posY -= speed * dt;
		}

		if (posX < 0) {
			posX = 0.0;
			moving = false;
		} else if (posX > currentStreet.bounds.width - width) {
			posX = currentStreet.bounds.width - width;
			moving = false;
		} else if (inputManager.leftKey == true || inputManager.rightKey == true) {
			moving = true;
		}

		Rectangle collisionsRect;
		if(facingRight) {
			collisionsRect = new Rectangle(posX+width/2, posY + currentStreet.groundY + height/4, width/2, height*3/4 - 35);
		} else {
			collisionsRect = new Rectangle(posX, posY + currentStreet.groundY + height/4, width/2, height*3/4 - 35);
		}
		//check for collisions with walls
		if(doPhysicsApply && (inputManager.leftKey == true || inputManager.rightKey == true)) {
			for(Wall wall in currentStreet.walls) {
				if(collisionsRect.intersects(wall.bounds)) {
					if(facingRight) {
						if(collisionsRect.right >= wall.bounds.left) {
							posX = wall.bounds.left - width - 1;
						}
					} else {
						if(collisionsRect.left < wall.bounds.left) {
							posX = wall.bounds.right + 1;
						}
					}
				}
			}
		}

		//check for collisions with platforms
		if (doPhysicsApply && !climbingDown && !climbingUp && yVel >= 0) {
			num x = posX + width / 2;
			Platform bestPlatform = _getBestPlatform(cameFrom);
			if (bestPlatform != null) {
				num goingTo = posY + height + currentStreet.groundY;
				num slope = (bestPlatform.end.y - bestPlatform.start.y) / (bestPlatform.end.x - bestPlatform.start.x);
				num yInt = bestPlatform.start.y - slope * bestPlatform.start.x;
				num lineY = slope * x + yInt;

				if (goingTo >= lineY) {
					posY = lineY - height - currentStreet.groundY;
					yVel = 0;
					jumping = false;
				}
			}
		}

		//check for collisions with ceilings
		if (doPhysicsApply && !climbingDown && !climbingUp && yVel < 0) {
			for(Platform platform in currentStreet.platforms) {
				if(platform.ceiling && intersect(platform.bounds,collisionsRect)) {
					num x = posX + width / 2;
					num slope = (platform.end.y - platform.start.y) / (platform.end.x - platform.start.x);
					num yInt = platform.start.y - slope * platform.start.x;
					num lineY = slope * x + yInt;

					posY = lineY - currentStreet.groundY;
					yVel = 0;

					break;
				}
			}
		}

		updateAnimation(dt);
		updateTransform();

		//update the avatarRect so that other entities know if the player is colliding with them
		avatarRect
			..left = posX
			..top = posY
			..width = width
			..height = height;
	}

	updateLadderStatus(double dt) {
		if (doPhysicsApply && inputManager.upKey == true) {
			// moving up

			bool found = false;
			Rectangle playerRect = new Rectangle(posX, posY + currentStreet.groundY, width, height - 15);
			for (Ladder ladder in currentStreet.ladders) {
				if (intersect(ladder.bounds, playerRect)) {
					// touching a ladder

					if (playerRect.top + playerRect.height < ladder.bounds.top) {
						//if our feet are above the ladder, stop climbing
						break;
					}

					posY -= speed / 4 * dt;
					climbingUp = true;
					activeClimb = true;
					jumping = false;
					found = true;
					break;
				}
			}
			if (!found) {
				// not touching a ladder
				climbingUp = false;
				climbingDown = false;
				activeClimb = false;
			}
		}

		if (doPhysicsApply && inputManager.downKey == true) {
			// moving down

			bool found = false;
			Rectangle playerRect = new Rectangle(posX, posY + currentStreet.groundY, width, height);
			for (Ladder ladder in currentStreet.ladders) {
				if (intersect(ladder.bounds, playerRect)) {
					// touching a ladder

					if (playerRect.top + playerRect.height > ladder.bounds.top + ladder.bounds.height) {
						//if our feet are below the ladder, stop climbing
						break;
					}

					posY += speed / 4 * dt;
					climbingDown = true;
					activeClimb = true;
					jumping = false;
					found = true;
					break;
				}
			}
			if (!found) {
				// not touching a ladder
				climbingDown = false;
				climbingUp = false;
				activeClimb = false;
			}
		}

		if (inputManager.rightKey == true || inputManager.leftKey == true) {
			// left or right on a ladder
			Rectangle playerRect = new Rectangle(posX, posY + currentStreet.groundY, width + 20, height + 20);
			for (Ladder ladder in currentStreet.ladders) {
				if (!intersect(ladder.bounds, playerRect)) {
					climbingDown = false;
					climbingUp = false;
					activeClimb = false;
				}
			}
		}
	}

	void render() {
		if (currentAnimation != null && currentAnimation.loaded && currentAnimation.dirty) {
			if (!firstRender) {
				Rectangle avatarRect = new Rectangle(posX, posY, currentAnimation.width, currentAnimation.height);
				if (!intersect(camera.visibleRect, avatarRect))
					return;
			}

			firstRender = false;

			if (playerCanvas.width != currentAnimation.width || playerCanvas.height != currentAnimation.height) {
				playerCanvas.style.width = currentAnimation.width.toString() + "px";
				playerCanvas.style.height = currentAnimation.height.toString() + "px";
				playerCanvas.width = currentAnimation.width;
				playerCanvas.height = currentAnimation.height;
				int x = -((currentAnimation.width - width) ~/ 2);
				int y = -((currentAnimation.height - height));
				playerCanvas.style.transform = "translateX(${x}px) translateY(${y}px)";
			}
			else
				playerCanvas.context2D.clearRect(0, 0, currentAnimation.width, currentAnimation.height);

			Rectangle destRect = new Rectangle(0, 0, currentAnimation.width, currentAnimation.height);
			playerCanvas.context2D.drawImageToRect(currentAnimation.spritesheet, destRect, sourceRect: currentAnimation.sourceRect);
			currentAnimation.dirty = false;
		}
	}

	void updateAnimation(double dt) {
		Animation previous = currentAnimation;
		bool climbing = climbingUp || climbingDown;
		if (!moving && !jumping && !climbing)
			currentAnimation = animations['idle'];
		else {
			//reset idle so that the 10 second delay starts over
			animations['idle'].reset();

			if (climbing) {
				if (activeClimb != lastClimbStatus) {
					lastClimbStatus = activeClimb;
				}
				currentAnimation = animations['climb'];
				currentAnimation.paused = !activeClimb;
			}
			else {
				if (moving && !jumping)
					currentAnimation = animations['base'];
				else if (jumping && yVel < 0) {
					currentAnimation = animations['jumpup'];
					animations['falldown'].reset();
				}
				else if (jumping && yVel >= 0) {
					currentAnimation = animations['falldown'];
					animations['jumpup'].reset();
				}
			}
		}

		currentAnimation.updateSourceRect(dt, holdAtLastFrame:jumping);

		if (previous != currentAnimation) {
			//force a player update to be sent right now
			timeLast = 5.0;
		}
	}

	void updateTransform() {
		num translateX = posX, translateY = view.worldElementWidth - height;

		num camX = camera.getX(), camY = camera.getY();
		if (posX > currentStreet.bounds.width - width / 2 - view.worldElementWidth / 2) {
			camX = currentStreet.bounds.width - view.worldElementWidth;
			translateX = posX - currentStreet.bounds.width + view.worldElementWidth;
			//allow character to move to screen right
		}
		else if (posX + width / 2 > view.worldElementWidth / 2) {
			camX = posX + width / 2 - view.worldElementWidth / 2;
			translateX = view.worldElementWidth / 2 - width / 2;
			//keep character in center of screen
		}
		else
			camX = 0;

		if (posY + height / 2 < view.worldElementHeight / 2) {
			camY = 0;
			translateY = posY;
		}
		else if (posY < currentStreet.bounds.height - height / 2 - view.worldElementHeight / 2) {
			num yDistanceFromBottom = currentStreet.bounds.height - posY - height / 2;
			camY = currentStreet.bounds.height - (yDistanceFromBottom + view.worldElementHeight / 2);
			translateY = view.worldElementHeight / 2 - height / 2;
		}
		else {
			camY = currentStreet.bounds.height - view.worldElementHeight;
			translateY = view.worldElementHeight - (currentStreet.bounds.height - posY);
		}

		camera.setCameraPosition(camX ~/ 1, camY ~/ 1);

		//translateZ forces the whole operation to be gpu accelerated
		String transform = 'translateX(' + translateX.toString() + 'px) translateY(' + translateY.toString() + 'px) translateZ(0)';
		if (!facingRight) {
			transform += ' scale3d(-1,1,1)';
			playerName.style.transform = 'translateY(-100%) translateY(-34px) scale3d(-1,1,1)';

			if (chatBubble != null)
				chatBubble.textElement.style.transform = 'scale3d(-1,1,1)';
		}
		else {
			playerName.style.transform = 'translateY(-100%) translateY(-34px) scale3d(1,1,1)';

			if (chatBubble != null)
				chatBubble.textElement.style.transform = 'scale3d(1,1,1)';
		}

		playerParentElement.style.transform = transform;
		playerParentElement.attributes['translateX'] = translateX.toString();
		playerParentElement.attributes['translateY'] = translateY.toString();
	}

	//ONLY WORKS IF PLATFORMS ARE SORTED WITH
	//THE HIGHEST (SMALLEST Y VALUE) FIRST IN THE LIST
	Platform _getBestPlatform(num cameFrom) {
		Platform bestPlatform;
		num x = posX + width / 2;
		num feetY = cameFrom + height + currentStreet.groundY;
		num bestDiffY = double.INFINITY;

		for (Platform platform in currentStreet.platforms) {
			if(platform.ceiling) {
				continue;
			}

			if (x >= platform.start.x && x <= platform.end.x) {
				num slope = (platform.end.y - platform.start.y) / (platform.end.x - platform.start.x);
				num yInt = platform.start.y - slope * platform.start.x;
				num lineY = slope * x + yInt;
				num diffY = (feetY - lineY).abs();

				if (bestPlatform == null) {
					bestPlatform = platform;
					bestDiffY = diffY;
				}
				else {
					if ((lineY >= feetY || !jumping && feetY > lineY && feetY - (height / 2) < lineY) && diffY < bestDiffY) {
						bestPlatform = platform;
						bestDiffY = diffY;
					}
				}
			}
		}

		return bestPlatform;
	}
}