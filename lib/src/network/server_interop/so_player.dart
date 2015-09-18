part of couclient;

_setupPlayerSocket() {
	playerSocket = new WebSocket(multiplayerServer);
	playerSocket.onOpen.listen((_) {
		playerSocket.send(JSON.encode({'clientVersion': Configs.clientVersion}));
	});
	playerSocket.onMessage.listen((MessageEvent event) {
		Map map = JSON.decode(event.data);
		if (map['error'] != null) {
			reconnect = false;
			logmessage('[Multiplayer (Player)] Error ${map['error']}');
			playerSocket.close();
			return;
		}

		if (map['gotoStreet'] != null && map["tsid"].substring(1) != currentStreet.tsid.substring(1)) {
			String toTSID = map["tsid"];

			// Check dead/alive

			String toLabel = mapData.getLabel(toTSID);

			if (mapData.streetData[toLabel] != null &&
			    mapData.streetData[toLabel]["hub_id"] != null) {
				int toHubId = mapData.streetData[toLabel]["hub_id"];
				if (toHubId == 40 && currentStreet != null && currentStreet.hub_id != 40) {
					// Going to Naraka
					transmit("dead", true);
				} else if (currentStreet.hub_id == "40") {
					// Leaving Naraka
					transmit("dead", false);
				}
			}

			// Go to the street
			streetService.requestStreet(toTSID);
			return;
		}

		if (map['street'] != null &&
		    currentStreet.label != map['street'] &&
		    map['changeStreet'] == null) {
			return;
		}

		if (map['username'] == game.username) {
			return;
		}

		if (map["changeStreet"] != null) {
			//someone left this street
			if (map["changeStreet"] != currentStreet.label) {
				removeOtherPlayer(map["username"]);
			} else {
				createOtherPlayer(map);
			}
		} else if (map["disconnect"] != null) {
			removeOtherPlayer(map["username"]);
		} else if (otherPlayers[map["username"]] == null) {
			createOtherPlayer(map);
		} else {
			//update a current otherPlayer
			updateOtherPlayer(map, otherPlayers[map["username"]]);
		}
	});
	playerSocket.onClose.listen((_) {
		logmessage('[Multiplayer (Player)] Socket closed');
		if (!reconnect) {
			reconnect = true;
			return;
		}

		joined = "";
		//wait 5 seconds and try to reconnect
		new Timer(new Duration(seconds: 5), () {
			_setupPlayerSocket();
		});
	});
	playerSocket.onError.listen((Event e) {
		logmessage('[Multiplayer (Player)] Error ${e}');
	});
}

sendPlayerInfo() {
	String xy =
	CurrentPlayer.posX.toString() + "," + CurrentPlayer.posY.toString();
	Map map = new Map();
	map["username"] = CurrentPlayer.username;
	map["xy"] = xy;
	map["street"] = currentStreet.label;
	map['tsid'] = currentStreet.streetData['tsid'];
	map["facingRight"] = CurrentPlayer.facingRight;
	map['jumping'] = CurrentPlayer.jumping;
	map['climbing'] = CurrentPlayer.climbingDown || CurrentPlayer.climbingUp;
	map['activeClimb'] = CurrentPlayer.activeClimb;
	map["animation"] = CurrentPlayer.currentAnimation.animationName;
	if (CurrentPlayer.chatBubble != null) map["bubbleText"] =
	CurrentPlayer.chatBubble.text;
	playerSocket.send(JSON.encode(map));
}

void createOtherPlayer(Map map) {
	if (creatingPlayer == map['username']) {
		return;
	}

	creatingPlayer = map['username'];
	Player otherPlayer = new Player(map["username"]);
	otherPlayer.loadAnimations().then((_) {
		updateOtherPlayer(map, otherPlayer);

		otherPlayers[map["username"]] = otherPlayer;
		querySelector("#playerHolder").append(otherPlayer.playerParentElement);

		creatingPlayer = "";
	});
}

updateOtherPlayer(Map map, Player otherPlayer) {
	if (map == null || otherPlayer == null) {
		return;
	}

	if (otherPlayer.currentAnimation == null) {
		otherPlayer.currentAnimation = otherPlayer.animations[map["animation"]];
	}

	//set movement bools
	if (map['jumping'] != null) {
		otherPlayer.jumping = map['jumping'];
	}
	if (map['climbing'] == true) {
		otherPlayer.currentAnimation.paused = !map['activeClimb'];
	} else {
		otherPlayer.currentAnimation.paused = false;
	}

	//set animation state
	if (map["animation"] != otherPlayer.currentAnimation.animationName) {
		otherPlayer.currentAnimation.reset();
		otherPlayer.currentAnimation = otherPlayer.animations[map["animation"]];
	}

	otherPlayer.playerParentElement.id = "player-" + sanitizeName(map["username"].replaceAll(' ', '_'));
	otherPlayer.playerParentElement.style.position = "absolute";
	if (map['username'] != otherPlayer.username) {
		otherPlayer.username = map['username'];
		otherPlayer.loadAnimations();
	}

	//set player position
	otherPlayer.posX = double.parse(map["xy"].split(',')[0]);
	otherPlayer.posY = double.parse(map["xy"].split(',')[1]);

	if (map["bubbleText"] != null) {
		if (otherPlayer.chatBubble == null) {
			otherPlayer.chatBubble = new ChatBubble(map["bubbleText"], otherPlayer, otherPlayer.playerParentElement);
		}
		otherPlayer.playerParentElement.append(otherPlayer.chatBubble.bubble);
	} else if (otherPlayer.chatBubble != null) {
		otherPlayer.chatBubble.bubble.remove();
		otherPlayer.chatBubble = null;
	}

	bool facingRight = false;
	if (map["facingRight"] == "true" || map['facingRight'] == true) {
		facingRight = true;
	}
	otherPlayer.facingRight = facingRight;
}

void removeOtherPlayer(String username) {
	if (username == null) return;

	otherPlayers.remove(username);
	Element otherPlayer =
	querySelector("#player-" + sanitizeName(username.replaceAll(' ', '_')));
	if (otherPlayer != null) otherPlayer.remove();
}