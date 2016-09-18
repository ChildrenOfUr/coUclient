part of couclient;

Player CurrentPlayer;

class Player extends Entity {
	static final num MIN_SCALE = 0.2;

	static final List<Action> PLAYER_ACTIONS = [
		new Action.withName('follow')
			..description = "We already know it's buggy, but we thought you'd have fun with it.",
		new Action.withName('profile')
	];

	Physics physics = Physics.get('normal');
	int streetZ = 0;

	void updatePhysics([Map street = const {}]) {
		physics = Physics.getStreet(street['label']);
		streetZ = mapData.checkIntSetting('depth', defaultValue: 0);
	}

	num yVel = 0;
	num yAccel = -2400;

	bool activeClimb = false;
	bool climbingDown = false;
	bool climbingUp = false;
	bool facingRight = true;
	bool firstRender = true;
	bool isGuide = false;
	bool jumping = false;
	bool lastClimbStatus = false;
	bool moving = false;

	Map<String, Animation> animations = new Map();
	Animation currentAnimation;

	Map<String, Rectangle> intersectingObjects = {};

	int jumpcount = 0;
	Timer jumpTimer;

	Player followingPlayer = null;

	//for testing purposes
	//if false, player can move around with wasd and arrows, no falling
	bool doPhysicsApply = true;

	DivElement playerName;
	DivElement playerParentElement;
	DivElement superParentElement;

	bool get climbing {
		if (id == game.username) {
			return climbingUp || climbingDown;
		} else {
			return currentAnimation.animationName == 'climb';
		}
	}

	Player(String username) {
		id = username;

		left = metabolics.currentStreetX;
		top = metabolics.currentStreetY;

		width = 116;
		height = 137;

		if (left == 1.0 && top == 0.0) {
			bool found = false;
			Platform leftmost = null;

			for (Platform platform in currentStreet.platforms) {
				if (leftmost == null || platform.start.x < leftmost.start.x) {
					leftmost = platform;
				}

				if (platform.start.x == 1) {
					found = true;
					top = platform.start.y - height;
				}
			}

			if (!found) {
				top = 0.0;
			}
		}

		canvas = new CanvasElement()
			..className = 'canvas'
			..style.position = 'absolute'
			..style.overflow = 'auto'
			..style.margin = 'auto';

		playerName = new DivElement()
			..classes.add('playerName')
			..text = id;

		playerParentElement = new DivElement()
			..classes.add('playerParent')
			..id = 'pc-player-$id'
			..style.width = width.toString() + 'px'
			..style.height = height.toString() + 'px';

		superParentElement = new DivElement()
			..classes.add('playerParent');
		superParentElement.append(playerParentElement);

		if (id != game.username) {
			playerParentElement.append(playerName);

			actions = PLAYER_ACTIONS;
		}
		playerParentElement.append(canvas);
		view.worldElement.append(superParentElement);

		updatePhysics();
		new Service(['streetLoaded'], (_) => updatePhysics());
	}

	Future<List<Animation>> loadAnimations() {
		//need to get background images from some server for each player based on name
		List<int> idleFrames = [],
			baseFrames = [],
			jumpUpFrames = [],
			fallDownFrames,
			landFrames,
			climbFrames = [];
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

		futures
			.add(HttpRequest.requestCrossOrigin('http://${Configs.utilServerAddress}/getSpritesheets?username=$id')
			.then((String response) {

			Map spritesheets = JSON.decode(response);
			String idle, base, jump, climb;

			if (spritesheets['base'] == null) {
				idle = 'files/sprites/idle.png';
				base = 'files/sprites/base.png';
				jump = 'files/sprites/jump.png';
				climb = 'files/sprites/climb.png';
			} else {
				idle = spritesheets['idle2'];
				base = spritesheets['base'];
				jump = spritesheets['jump'];
				climb = spritesheets['climb'];
			}

			animations
				..['idle'] = new Animation(idle, 'idle', 2, 29, idleFrames, loopDelay: new Duration(seconds: 10), delayInitially: true)
				..['base'] = new Animation(base, 'base', 1, 15, baseFrames)
				..['die'] = new Animation(base, 'die', 1, 15, [12, 13], loops: false)
				..['jumpup'] = new Animation(jump, 'jumpup', 1, 33, jumpUpFrames)
				..['falldown'] = new Animation(jump, 'falldown', 1, 33, fallDownFrames)
				..['land'] = new Animation(jump, 'land', 1, 33, landFrames)
				..['climb'] = new Animation(climb, 'climb', 1, 19, climbFrames);

			animations.forEach((String name, Animation animation) => futures.add(animation.load()));
		}));

		return Future.wait(futures);
	}

	bool lostFocus = false;

	update(double dt, [bool partial = false]) {
		if (!currentStreet.loaded) {
			return;
		}

		if (glow) {
			canvas.context2D
				..shadowBlur = 2
				..shadowColor = 'cyan'
				..shadowOffsetX = 0
				..shadowOffsetY = 1;
		} else {
			canvas.context2D
				..shadowColor = '0'
				..shadowBlur = 0
				..shadowOffsetX = 0
				..shadowOffsetY = 0;
		}

		if (!partial) {
			num cameFrom = top;

			//show chat message if it exists and decrement its timeToLive
			if (chatBubble != null) {
				chatBubble.update(dt);
			}

			updateLadderStatus(dt);

			if (!inputManager.windowFocused && (moving || jumping || activeClimb) && !lostFocus) {
				lostFocus = true;

				// reset all input controls.
				for (Map control in inputManager.controlCounts.values) {
					control['keyBool'].value = false;
				}
			}

			if (inputManager.windowFocused && lostFocus) {
				lostFocus = false;
			}

			if (doPhysicsApply && inputManager.downKey == false && inputManager.upKey == false) {
				// not moving up or down

				bool found = false;
				Rectangle playerRect = new Rectangle(left, top + currentStreet.groundY, width, height);

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
				left += physics.speed * dt * scale;
				facingRight = true;
				moving = true;
				updateLadderStatus(dt);
			} else if (inputManager.leftKey == true) {
				// moving left
				left -= physics.speed * dt * scale;
				facingRight = false;
				moving = true;
				updateLadderStatus(dt);
			} else {
				// not moving
				moving = false;
			}

			if (!activeClimb && streetZ != 0) {
				// Not near a ladder, and this street is 3d
				if (inputManager.upKey == true && scale > MIN_SCALE) {
					// moving back
					z += physics.zSpeed * scale * dt;
					moving = true;
				} else if (inputManager.downKey == true && scale < 1) {
					// moving foward
					z -= physics.zSpeed * scale * dt;
					moving = true;
				} else {
					// not moving
					moving = false;
				}
			}

			//primitive jumping
			if (inputManager.jumpKey == true && (!jumping || physics.infiniteJump) && !climbingUp && !climbingDown) {
				num jumpMultiplier;
				bool spinachBuff = Buff.isRunning('spinach');
				bool pieBuff = Buff.isRunning('full_of_pie');

				if (physics.jumpMultiplier != Physics
					.get(Physics.DEFAULTID)
					.jumpMultiplier) {
					// Not normal jumping
					jumpMultiplier = physics.jumpMultiplier;
				} else if (spinachBuff) {
					jumpMultiplier = 1.65;
				} else if (pieBuff) {
					jumpMultiplier = 0.65;
				} else {
					jumpMultiplier = 1;
				}

				jumping = true;
				if (physics.canTripleJump && !pieBuff) {
					if (jumpTimer == null) {
						// start timer
						jumpTimer = new Timer(new Duration(seconds: 3), () {
							// normal jump
							jumpcount = 0;
							jumpTimer.cancel();
							jumpTimer = null;
						});
					}

					if (jumpcount == 2) {
						// triple jump
						yVel = -(physics.yVelTripleJump * jumpMultiplier) * scale;
						jumpcount = 0;
						jumpTimer.cancel();
						jumpTimer = null;

						if (!activeClimb) {
							audio.playSound('tripleJump');
						}
					} else {
						// normal jump
						jumpcount++;
						yVel = -(physics.yVelJump * jumpMultiplier) * scale;
					}
				} else {
					// triple jumping disabled
					yVel = -(physics.yVelJump * jumpMultiplier) * scale;
				}
			}

			//needs acceleration, some gravity const somewhere
			//for jumps/falling
			if (doPhysicsApply && !climbingUp && !climbingDown) {
				// walking
				yVel -= yAccel * dt * scale;
				top += yVel * dt * scale;
			} else {
				// climbing
				if (inputManager.downKey == true) {
					top += physics.speed * dt * scale;
				}

				if (inputManager.upKey == true) {
					top -= physics.speed * dt * scale;
				}
			}

			if (left < 0) {
				left = 0.0;
				moving = false;
			} else if (left > currentStreet.bounds.width - width) {
				left = currentStreet.bounds.width - width;
				moving = false;
			} else if (inputManager.leftKey == true || inputManager.rightKey == true) {
				moving = true;
			}

			Rectangle collisionsRect;
			if (facingRight) {
				collisionsRect = new Rectangle(left + width / 2, top + currentStreet.groundY + height / 4, width / 2, height * 3 / 4 - 35);
			} else {
				collisionsRect = new Rectangle(left, top + currentStreet.groundY + height / 4, width / 2, height * 3 / 4 - 35);
			}

			//check for collisions with walls
			if (doPhysicsApply && (inputManager.leftKey == true || inputManager.rightKey == true)) {
				for (Wall wall in currentStreet.walls) {
					if (collisionsRect.intersects(wall.bounds)) {
						if (facingRight) {
							if (collisionsRect.right >= wall.bounds.left) {
								left = wall.bounds.left - width - 1;
							}
						} else {
							if (collisionsRect.left < wall.bounds.left) {
								left = wall.bounds.right + 1;
							}
						}
					}
				}
			}

			//check for collisions with platforms
			if (doPhysicsApply && !climbingDown && !climbingUp && yVel >= 0) {
				num x = left + width / 2;
				Platform bestPlatform = _getBestPlatform(cameFrom);
				if (bestPlatform != null) {
					num goingTo = top + height + currentStreet.groundY;
					num slope = (bestPlatform.end.y - bestPlatform.start.y) / (bestPlatform.end.x - bestPlatform.start.x);
					num yInt = bestPlatform.start.y - slope * bestPlatform.start.x;
					num lineY = slope * x + yInt;

					if (goingTo >= lineY) {
						top = lineY - height - currentStreet.groundY;
						yVel = 0;
						jumping = false;
					}
				}
			}

			//check for collisions with ceilings
			if (doPhysicsApply && !climbingDown && !climbingUp && yVel < 0) {
				for (Platform platform in currentStreet.platforms) {
					if (platform.ceiling && intersect(platform.bounds, collisionsRect)) {
						num x = left + width / 2;
						num slope = (platform.end.y - platform.start.y) / (platform.end.x - platform.start.x);
						num yInt = platform.start.y - slope * platform.start.x;
						num lineY = slope * x + yInt;

						top = lineY - currentStreet.groundY;
						yVel = 0;

						break;
					}
				}
			}

			z = z.clamp(0, streetZ);

			updateAnimation(dt);
			updateTransform();

			//update the _entityRect so that other entities know if the player is colliding with them
			_entityRect
				..left = left
				..top = top
				..width = width
				..height = height;

			// If following a player, go to them
			if (id == CurrentPlayer.id && followingPlayer != null) {
				// Turn to face the same direction
				facingRight = followingPlayer.facingRight;

				// Copy their animation state
				updateAnimation(dt, followingPlayer.currentAnimation.animationName);

				// Go to their X coordinate (+/- a body width or so if on a platform)
				num xOffset = (followingPlayer.climbing ? 0 : (facingRight ? -1 : 1) * _entityRect.width);
				left = followingPlayer.left + xOffset;

				// Go to their Y coordinate (if not on a platform)
				if (followingPlayer.jumping || followingPlayer.climbing) {
					top = followingPlayer.top;
				}
			}
		}

		super.update(dt);
	}

	void updateLadderStatus(double dt) {
		if (doPhysicsApply && inputManager.upKey == true) {
			// moving up

			bool found = false;
			Rectangle playerRect = new Rectangle(left, top + currentStreet.groundY, width, height - 15);
			for (Ladder ladder in currentStreet.ladders) {
				if (intersect(ladder.bounds, playerRect)) {
					// touching a ladder

					if (playerRect.top + playerRect.height < ladder.bounds.top) {
						//if our feet are above the ladder, stop climbing
						break;
					}

					top -= physics.speed / 4 * dt;
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
			Rectangle playerRect = new Rectangle(left, top + currentStreet.groundY, width, height);

			for (Ladder ladder in currentStreet.ladders) {
				if (intersect(ladder.bounds, playerRect)) {
					// touching a ladder

					if (playerRect.top + playerRect.height > ladder.bounds.top + ladder.bounds.height) {
						//if our feet are below the ladder, stop climbing
						break;
					}

					top += physics.speed / 4 * dt;
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
			Rectangle playerRect = new Rectangle(left, top + currentStreet.groundY, width + 20, height + 20);

			for (Ladder ladder in currentStreet.ladders) {
				if (!intersect(ladder.bounds, playerRect)) {
					climbingDown = false;
					climbingUp = false;
					activeClimb = false;
				}
			}
		}
	}

	void updateAnimation(double dt, [String override]) {
		Animation previous = currentAnimation;

		if (override != null) {
			currentAnimation = animations[override];
		} else {
			bool climbing = climbingUp || climbingDown;

			if (!moving && !jumping && !climbing) {
				currentAnimation = animations['idle'];
			} else {
				//reset idle so that the 10 second delay starts over
				animations['idle'].reset();

				if (climbing) {
					if (activeClimb != lastClimbStatus) {
						lastClimbStatus = activeClimb;
					}

					currentAnimation = animations['climb'];
					currentAnimation.paused = !activeClimb;
				} else {
					if (moving && !jumping) {
						currentAnimation = animations['base'];
					} else if (jumping && yVel < 0) {
						currentAnimation = animations['jumpup'];
						animations['falldown'].reset();
					} else if (jumping && yVel >= 0) {
						currentAnimation = animations['falldown'];
						animations['jumpup'].reset();
					}
				}
			}
		}

		currentAnimation.updateSourceRect(dt, holdAtLastFrame: jumping);

		if (previous != currentAnimation) {
			//force a player update to be sent right now
			timeLast = 5.0;
		}
	}

	void updateTransform() {
		num translateX = left,
			translateY = view.worldElementWidth - height;

		num camX = camera.getX(),
			camY = camera.getY();

		if (left > currentStreet.bounds.width - width / 2 - view.worldElementWidth / 2) {
			camX = currentStreet.bounds.width - view.worldElementWidth;
			translateX = left - currentStreet.bounds.width + view.worldElementWidth;
			//allow character to move to screen right
		} else if (left + width / 2 > view.worldElementWidth / 2) {
			camX = left + width / 2 - view.worldElementWidth / 2;
			translateX = view.worldElementWidth / 2 - width / 2;
			//keep character in center of screen
		} else {
			camX = 0;
		}

		if (top + height / 2 < view.worldElementHeight / 2) {
			camY = 0;
			translateY = top;
		} else if (top < currentStreet.bounds.height - height / 2 - view.worldElementHeight / 2) {
			num yDistanceFromBottom = currentStreet.bounds.height - top - height / 2;
			camY = currentStreet.bounds.height - (yDistanceFromBottom + view.worldElementHeight / 2);
			translateY = view.worldElementHeight / 2 - height / 2;
		} else {
			camY = currentStreet.bounds.height - view.worldElementHeight;
			translateY = view.worldElementHeight - (currentStreet.bounds.height - top);
		}

		// Move up to simulate moving back
		translateY -= z;

		camera.setCameraPosition(camX ~/ 1, camY ~/ 1);

		//translateZ forces the whole operation to be gpu accelerated
		String transform = 'translateX(' + translateX.toString() + 'px) translateY(' + translateY.toString() + 'px) translateZ(0)';

		if (!facingRight) {
			transform += ' scale3d(-$scale, $scale, $scale)';

			playerParentElement.classes
				..add('facing-left')
				..remove('facing-right');

			playerName.style.transform = 'translateY(-100%) translateY(-34px) scale3d(-1,1,1)';

			if (chatBubble != null) {
				chatBubble.textElement.style.transform = 'scale3d(-1,1,1)';
			}
		} else {
			transform += ' scale3d($scale, $scale, $scale)';

			playerName.style.transform = 'translateY(-100%) translateY(-34px) scale3d(1,1,1)';

			playerParentElement.classes
				..add('facing-right')
				..remove('facing-left');

			if (chatBubble != null) {
				chatBubble.textElement.style.transform = 'scale3d(1,1,1)';
			}
		}

		playerParentElement
			..style.transform = transform
			..attributes['translateX'] = translateX.toString()
			..attributes['translateY'] = translateY.toString();
	}

	num get scale {
		if (z == 0) {
			return 1;
		} else {
			num scale = streetZ / z;
			scale = 0.01 * scale;
			scale = scale.clamp(MIN_SCALE, 1);
			return scale;
		}
	}

	void render() {
		if (currentAnimation != null && currentAnimation.loaded && currentAnimation.dirty) {
			if (!firstRender) {
				Rectangle _entityRect = new Rectangle(left, top, currentAnimation.width, currentAnimation.height);
				if (!intersect(camera.visibleRect, _entityRect)) {
					return;
				}
			}

			firstRender = false;

			if (canvas.width != currentAnimation.width || canvas.height != currentAnimation.height) {
				canvas.style.width = currentAnimation.width.toString() + 'px';
				canvas.style.height = currentAnimation.height.toString() + 'px';
				canvas.width = currentAnimation.width;
				canvas.height = currentAnimation.height;
				int x = -(currentAnimation.width ~/ 2);
				int y = -((currentAnimation.height - height));

				if (Buff.isRunning('grow')) {
					y -= 30;
				}

				canvas.style.transform = 'translateX(${x}px) translateY(${y}px)';

				if (Buff.isRunning('grow')) {
					canvas.style.transform += ' scale(1.5)';
				} else if (Buff.isRunning('shrink')) {
					canvas.style.transform += ' scale(0.75)';
				}
			} else {
				canvas.context2D.clearRect(0, 0, currentAnimation.width, currentAnimation.height);
			}

			Rectangle destRect = new Rectangle(0, 0, currentAnimation.width, currentAnimation.height);
			canvas.context2D.drawImageToRect(currentAnimation.spritesheet, destRect, sourceRect: currentAnimation.sourceRect);
			currentAnimation.dirty = false;
		}
	}

	String followPlayer([String toFollow]) {
		// Running follow() on yourself?
		if (id != game.username) {
			return 'You cannot make people follow each other!';
		}

		if (toFollow == null || toFollow == '' || toFollow == CurrentPlayer.id) {
			// Unset or follow yourself to cancel following
			followingPlayer = null;
			return 'You no longer follow anyone.';
		} else {
			// Player exsits/is loaded?
			if (otherPlayers[toFollow] == null) {
				return 'You can only follow players on the same street as you!';
			}

			// Unfollow the current one first
			if (followingPlayer != null) {
				followPlayer();
			}

			// Follow another player
			followingPlayer = otherPlayers[toFollow];
			return 'You now follow $toFollow. Move to stop.';
		}
	}

	//ONLY WORKS IF PLATFORMS ARE SORTED WITH
	//THE HIGHEST (SMALLEST Y VALUE) FIRST IN THE LIST
	Platform _getBestPlatform(num cameFrom) {
		Platform bestPlatform;
		num x = left + width / 2;
		num feetY = cameFrom + height + currentStreet.groundY;
		num bestDiffY = double.INFINITY;

		for (Platform platform in currentStreet.platforms) {
			if (platform.ceiling) {
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
