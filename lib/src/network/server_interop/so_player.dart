part of couclient;

_setupPlayerSocket() {
	playerSocket = new WebSocket(multiplayerServer);
	playerSocket.onOpen.listen((_) {
		playerSocket.send(jsonEncode({'clientVersion': Configs.clientVersion}));
	});
	playerSocket.onMessage.listen((MessageEvent event) {
		Map map = jsonDecode(event.data);
		if (map['error'] != null) {
			reconnect = false;
			logmessage('[Multiplayer (Player)] Error ${map['error']}');
			playerSocket.close();

			if (map['error'] == 'version too low') {
				window.alert(
					"Your game is outdated. Click OK and we'll"
					" try to fix that for you so you can play."
					"\n\n"
					"If you see this message after reloading,"
					" please contact Children of Ur for help."
				);
				hardReload();
			}

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
			if (map["letter"] != null) {
				attachPlayerLetter(map["letter"], CurrentPlayer);
			}
			return;
		}

		try {
			if (map["changeStreet"] != null) {
				//someone left this street
				if (map["changeStreet"] != currentStreet.label &&
					map['previousStreet'] == currentStreet.label) {
					removeOtherPlayer(map["username"]);
					new Toast('${map['username']} has left for ${map['changeStreet']}');
				} else if (map['changeStreet'] == currentStreet.label) {
					createOtherPlayer(map);
					new Toast('${map['username']} has arrived');
				}
			} else if (map["disconnect"] != null) {
				removeOtherPlayer(map["username"]);
			} else if (otherPlayers[map["username"]] == null) {
				createOtherPlayer(map);
			} else {
				//update a current otherPlayer
				updateOtherPlayer(map, otherPlayers[map["username"]]);
			}
		} catch (e) {
			logmessage("Could not update other player ${map["username"]}: $e");
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
		CurrentPlayer.left.toString() + "," + CurrentPlayer.top.toString();
	Map map = new Map();
	map['email'] = game.email;
	map["username"] = CurrentPlayer.id;
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
	playerSocket.send(jsonEncode(map));
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
	if (map['username'] != otherPlayer.id) {
		otherPlayer.id = map['username'];
		otherPlayer.loadAnimations();
	}

	//set player position
	otherPlayer.left = double.parse(map["xy"].split(',')[0]);
	otherPlayer.top = double.parse(map["xy"].split(',')[1]);

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

	attachPlayerLetter(map["letter"], otherPlayer);
}

void removeOtherPlayer(String username) {
	if (username == null) return;

	otherPlayers.remove(username);
	Element otherPlayer =
	querySelector("#player-" + sanitizeName(username.replaceAll(' ', '_')));
	if (otherPlayer != null) otherPlayer.remove();
}

void attachPlayerLetter(String letter, Player player) {
	if (letter == null || player == null) {
		return;
	}

	// Letters
	if (currentStreet.useLetters) {
		// Add
		DivElement letterDisplay = new DivElement()
			..classes.addAll(["letter", "letter-$letter"]);

		player.playerParentElement
			..children.removeWhere((Element e) => e.classes.contains("letter"))
			..append(letterDisplay);
	} else {
		// Remove
		player.playerParentElement.children.removeWhere((Element e) => e.classes.contains("letter"));
	}
}
