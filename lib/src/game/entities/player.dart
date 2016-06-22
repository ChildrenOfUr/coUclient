part of couclient;

Player CurrentPlayer;

class Player extends Entity implements xl.Animatable {
	static final List<Action> PLAYER_ACTIONS = [
		new Action.withName('follow'),
		new Action.withName('profile')
	];

	static final String
		DEFAULT_PHYSICS = 'normal';

	static final int
		NORMAL_YVEL = 1000,
		WATER_YVEL = NORMAL_YVEL ~/ 2,
		JUMP_YVEL = 1000,
		TRIPLE_JUMP_YVEL = 1560,
		SPEED = 300;

	num
		yVel = 0,
		yAccel = -2400,
		translateX,
		translateY;

	bool
		activeClimb = false,
		climbingDown = false,
		climbingUp = false,
		facingRight = true,
		firstRender = true,
		isGuide = false,
		jumping = false,
		lastClimbStatus = false,
		moving = false;

	String physics;

	spine.SkeletonAnimation animation;
	String _currentAnimation = 'idle';
	String get currentAnimation => _currentAnimation ?? 'idle';
	void setCurrentAnimation(String newAnimation, {bool loop: true, restart: false}) {
		if (animation == null) {
			return;
		}

		if (!restart && newAnimation == _currentAnimation) {
			return;
		}

		_currentAnimation = newAnimation;
		animation.state.setAnimationByName(0, newAnimation, loop);
		width = animation.skeleton.data.width * animation.scaleX.abs();
		height = animation.skeleton.data.width * animation.scaleY.abs();
	}

	Map<String, Rectangle> intersectingObjects = {};

	int jumpcount = 0;
	Timer jumpTimer;

	Player followingPlayer = null;

	//for testing purposes
	//if false, player can move around with wasd and arrows, no falling
	bool doPhysicsApply = true;

	DivElement
		playerName,
		playerParentElement,
		superParentElement;

	int get speed => physics == 'normal' ? SPEED : SPEED ~/ 2;

	bool get canTripleJump => physics != 'water';

	bool get climbing {
		if (id == game.username) {
			return climbingUp || climbingDown;
		} else {
			return currentAnimation == 'climb';
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
				if (leftmost == null || platform.start.x < leftmost.start.x)
					leftmost = platform;

				if (platform.start.x == 1) {
					found = true;
					top = platform.start.y - height;
				}
			}

			if (!found)
				top = 0.0;
		}

		canvas = new CanvasElement()
			..className = 'canvas'
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

	void updatePhysics([Map street = const {}]) {
		if (
			mapData.hubData[street['hub_id'] ?? currentStreet.hub_id] != null &&
			mapData.hubData[street['hub_id'] ?? currentStreet.hub_id]['physics'] != null
		) {
			physics = mapData.hubData[street['hub_id'] ?? currentStreet.hub_id]['physics'];
		} else {
			physics = DEFAULT_PHYSICS;
		}
	}

	Future loadAnimations() async {
		resourceManager.addTextFile("glitchenSkeleton", 'http://${Configs.utilServerAddress}/getSpine?email=${game.email}&filename=skeleton.json');
		resourceManager.addTextureAtlas("glitchenAtlas", 'http://${Configs.utilServerAddress}/getSpine?email=${game.email}&filename=export_texture.atlas', xl.TextureAtlasFormat.LIBGDX);
		try {
			await resourceManager.load();
			// load Spine skeleton
			String spineJson = resourceManager.getTextFile("glitchenSkeleton");
			xl.TextureAtlas textureAtlas = resourceManager.getTextureAtlas("glitchenAtlas");
			spine.AttachmentLoader attachmentLoader = new spine.TextureAtlasAttachmentLoader(textureAtlas);
			spine.SkeletonLoader skeletonLoader = new spine.SkeletonLoader(attachmentLoader);
			spine.SkeletonData skeletonData = skeletonLoader.readSkeletonData(spineJson);

			animation = new spine.SkeletonAnimation(skeletonData);
			animation.scaleX = animation.scaleY = 0.7;
			setCurrentAnimation('idle', restart: true);
			view.playerStage.addChild(animation);
			view.playerStage.juggler.add(animation);
			view.playerStage.juggler.add(this);
		} catch (e) {
			print("couldn't load up the player skeleton: $e");
			print(resourceManager.failedResources);
		}
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

			//show chat message if it exists and decrement it's timeToLive
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
				left += speed * dt;
				facingRight = true;
				moving = true;
				updateLadderStatus(dt);
			}
			else if (inputManager.leftKey == true) {
				// moving left
				left -= speed * dt;
				facingRight = false;
				moving = true;
				updateLadderStatus(dt);
			}
			else {
				// not moving
				moving = false;
			}

			//primitive jumping
			if (inputManager.jumpKey == true && (!jumping || physics == 'water') && !climbingUp && !climbingDown) {
				num jumpMultiplier;
				bool spinachBuff = Buff.isRunning('spinach');
				bool pieBuff = Buff.isRunning('full_of_pie');
				if (physics == 'water') {
					jumpMultiplier = 0.5;
				} else if (spinachBuff) {
					jumpMultiplier = 1.65;
				} else if (pieBuff) {
					jumpMultiplier = 0.65;
				} else {
					jumpMultiplier = 1;
				}

				jumping = true;
				if (canTripleJump && !(pieBuff || spinachBuff)) {
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
						yVel = -(TRIPLE_JUMP_YVEL * jumpMultiplier);
						jumpcount = 0;
						jumpTimer.cancel();
						jumpTimer = null;
						if (!activeClimb) {
							audio.playSound('tripleJump');
						}
					} else {
						// normal jump
						jumpcount++;
						yVel = -(JUMP_YVEL * jumpMultiplier);
					}
				} else {
					// triple jumping disabled
					yVel = -(JUMP_YVEL * jumpMultiplier);
				}
			}

			//needs acceleration, some gravity const somewhere
			//for jumps/falling
			if (doPhysicsApply && !climbingUp && !climbingDown) {
				// walking
				yVel -= yAccel * dt;
				if (physics == 'water') {
					yVel /= 2;
				}
				top += yVel * dt;
			} else {
				// climbing
				if (inputManager.downKey == true)
					top += speed * dt;
				if (inputManager.upKey == true)
					top -= speed * dt;
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
				collisionsRect = new Rectangle(left, top + currentStreet.groundY + height/4, width/2, height*3/4 - 35);
			} else {
				collisionsRect = new Rectangle(left, top + currentStreet.groundY + height/4, width/2, height*3/4 - 35);
			}
			//check for collisions with walls
			if (doPhysicsApply && (inputManager.leftKey == true || inputManager.rightKey == true)) {
				for(Wall wall in currentStreet.walls) {
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
						if(jumping) {
							setCurrentAnimation('land', loop: false);
						}
						jumping = false;
					}
				}
			}

			//check for collisions with ceilings
			if (doPhysicsApply && !climbingDown && !climbingUp && yVel < 0) {
				for(Platform platform in currentStreet.platforms) {
					if (platform.ceiling && intersect(platform.bounds,collisionsRect)) {
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
				updateAnimation(dt, followingPlayer.currentAnimation);

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

	updateLadderStatus(double dt) {
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

					top -= speed / 4 * dt;
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

					top += speed / 4 * dt;
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

	void render() {}

	void updateAnimation(double dt, [String override]) {
		String previous = currentAnimation;

		if (override != null) {
			setCurrentAnimation(override);
		} else {
			bool climbing = climbingUp || climbingDown;
			if (!moving && !jumping && !climbing) {
				setCurrentAnimation('idle');
			} else {
				if (climbing) {
					if (activeClimb != lastClimbStatus) {
						lastClimbStatus = activeClimb;
					}
					setCurrentAnimation('climb');
//					currentAnimation.paused = !activeClimb;
				}
				else {
					if (moving && !jumping)
						setCurrentAnimation('walk');
					else if (jumping && yVel < 0) {
						setCurrentAnimation('jumpup', loop: false);
					}
					else if (jumping && yVel >= 0) {
						setCurrentAnimation('startfall', loop: false);
						animation.state.onTrackComplete.first.then((_) {
							setCurrentAnimation('falldown');
						});
					}
				}
			}
		}

		if (previous != currentAnimation) {
			//force a player update to be sent right now
			timeLast = 5.0;
		}
	}

	void updateTransform() {
		translateX = left;
		translateY = view.worldElementHeight - height;

		num camX = camera.getX(), camY = camera.getY();
		if (left + width / 2 > currentStreet.bounds.width - view.worldElementWidth / 2) {
			camX = currentStreet.bounds.width - view.worldElementWidth;
			translateX = left - currentStreet.bounds.width + view.worldElementWidth + width / 2;
			//allow character to move to screen right
		}
		else if (left + width / 2 > view.worldElementWidth / 2) {
			camX = left + width / 2 - view.worldElementWidth / 2;
			translateX = view.worldElementWidth / 2;
			//keep character in center of screen
		}
		else {
			camX = 0;
			translateX = left + width / 2;
		}

		if (top + height / 2 < view.worldElementHeight / 2) {
			camY = 0;
			translateY = top;
		}
		else if (top < currentStreet.bounds.height - height / 2 - view.worldElementHeight / 2) {
			num yDistanceFromBottom = currentStreet.bounds.height - top - height / 2;
			camY = currentStreet.bounds.height - (yDistanceFromBottom + view.worldElementHeight / 2);
			translateY = view.worldElementHeight / 2 - height / 2;
		}
		else {
			camY = currentStreet.bounds.height - view.worldElementHeight;
			translateY = view.worldElementHeight - (currentStreet.bounds.height - top);
		}

		camera.setCameraPosition(camX ~/ 1, camY ~/ 1);
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
			return 'You now follow $toFollow. Walk to stop.';
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
	@override
	bool advanceTime(num time) {
		if (Buff.isRunning("grow")) {
			animation.scaleX = animation.scaleY = .7 * 1.5;
		} else if (Buff.isRunning("shrink")) {
			animation.scaleX = animation.scaleY = .7 * .75;
		} else {
			animation.scaleX = animation.scaleY = .7;
		}

		if (!facingRight && animation.scaleX > 0) {
			animation.scaleX *= -1;
		} else if (facingRight && animation.scaleX < 0) {
			animation.scaleX *= -1;
		}

		animation.x = translateX;
		animation.y = translateY + height;

		return true;
	}
}
