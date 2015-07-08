part of couclient;

String multiplayerServer = "ws://${Configs.websocketServerAddress}/playerUpdate";
String streetEventServer = "ws://${Configs.websocketServerAddress}/streetUpdate";
String joined = "", creatingPlayer = "";
WebSocket streetSocket, playerSocket;
bool reconnect = true, firstConnect = true, serverDown = false;
Map<String, Player> otherPlayers = new Map();
Map<String, Quoin> quoins = new Map();
Map<String, Entity> entities = new Map();

multiplayerInit() {
	_setupPlayerSocket();
	_setupStreetSocket(currentStreet.label);
}

void sendLeftMessage(String streetName) {
	if(streetSocket != null && streetSocket.readyState == WebSocket.OPEN) {
		Map map = new Map();
		map["username"] = game.username;
		map["streetName"] = streetName;
		map["message"] = "left";
		streetSocket.send(JSON.encode(map));
	}
}

void sendJoinedMessage(String streetName, [String tsid]) {
	if(joined != streetName && streetSocket != null && streetSocket.readyState == WebSocket.OPEN) {
		Map map = new Map();
		map['clientVersion'] = Configs.clientVersion;
		map["username"] = game.username;
		map['email'] = game.email;
		map["streetName"] = streetName;
		map["tsid"] = tsid == null ? currentStreet.streetData['tsid'] : tsid;
		map["message"] = "joined";
		map['firstConnect'] = firstConnect;
		streetSocket.send(JSON.encode(map));
		joined = streetName;
		if(firstConnect) {
			firstConnect = false;
		}
	}
}

_setupStreetSocket(String streetName) {
	//start a timer for a few seconds and then show the server down message if not canceled
	Timer serverDownTimer = new Timer(new Duration(seconds:2), () {
		querySelector('#server-down').hidden = false;
		serverDown = true;
	});
	streetSocket = new WebSocket(streetEventServer);

	streetSocket.onOpen.listen((_) {
		querySelector('#server-down').hidden = true;
		serverDownTimer.cancel();
		if(serverDown) {
			window.location.reload();
		}
		sendJoinedMessage(streetName);
	});
	streetSocket.onMessage.listen((MessageEvent event) {
		Map map = JSON.decode(event.data);
		if(map['error'] != null) {
			reconnect = false;
			print(map['error']);
			log('[Multiplayer (Street)] Error ${map['error']}');
			streetSocket.close();
			return;
		}

		if(map['label'] != null && currentStreet.label != map['label']) {
			return;
		}

		//check if we are receiving our inventory
		if(map['inventory'] != null) {
			Map items = map['items'] as Map<String, Map>;
			items.forEach((String name, Map item) {
				for(int i = 0; i < item['count']; i++) {
					addItemToInventory({'item': item['item']});
				}
			});
			return;
		}
		//check if we are receiving an item
		if(map['giveItem'] != null) {
			print(map);
			for(int i = 0; i < map['num']; i++)
				addItemToInventory(map);
			return;
		}
		if(map['takeItem'] != null) {
			subtractItemFromInventory(map);
			return;
		}
		if(map['vendorName'] == 'Auctioneer') {
			new AuctionWindow().open();
			return;
		}
		if(map['openWindow'] != null) {
			if(map['openWindow'] == 'vendorSell') new VendorWindow().call(map, sellMode: true);
			if(map['openWindow'] == 'mailbox') new MailboxWindow().open();
			return;
		}
		if(map['itemsForSale'] != null) {
			new VendorWindow().call(map);
			return;
		}
		if(map['giantName'] != null) {
			new ShrineWindow(map['giantName'], map['favor'], map['maxFavor'], map['id']).open();
			return;
		}
		if(map['favorUpdate'] != null) {
			transmit('favorUpdate', map);
			return;
		}

		(map["quoins"] as List).forEach((Map quoinMap) {
			if(quoinMap["remove"] == "true") {
				Element objectToRemove = querySelector("#${quoinMap["id"]}");
				if(objectToRemove != null) objectToRemove.style.display =
				"none";
				//.remove() is very slow
			} else {
				String id = quoinMap["id"];
				Element element = querySelector("#$id");
				if(element == null) addQuoin(quoinMap);
				else if(element.style.display == "none") {
					element.style.display = "block";
					quoins[id].collected = false;
				}
			}
		});
		(map["plants"] as List).forEach((Map plantMap) {
			String id = plantMap["id"];
			Element element = querySelector("#$id");
			Plant plant = entities[plantMap["id"]];
			if(element == null) addPlant(plantMap);
			else {
				element.attributes['actions'] = JSON.encode(plantMap['actions']);
				if(plant != null && plant.state != plantMap['state']) plant
				.updateState(plantMap['state']);

				_updateChatBubble(plantMap, plant);
			}
		});
		(map["npcs"] as List).forEach((Map npcMap) {
			String id = npcMap["id"];
			Element element = querySelector("#$id");
			NPC npc = entities[npcMap["id"]];
			if(element == null) addNPC(npcMap);
			else {
				element.attributes['actions'] = JSON.encode(npcMap['actions']);
				if(npc != null) {
					//new animation
					if(npc.animation.animationName != npcMap["animation_name"]) {
						npc.ready = false;

						List<int> frameList = [];
						for(int i = 0; i < npcMap['numFrames']; i++) {
							frameList.add(i);
						}

						npc.animation = new Animation(npcMap['url'], npcMap['animation_name'],
						                              npcMap['numRows'], npcMap['numColumns'], frameList,
						                              loops: npcMap['loops']);
						npc.animation.load().then((_) => npc.ready = true);
					}

					npc.facingRight = npcMap["facingRight"];
					_updateChatBubble(npcMap, npc);
				}
			}
		});
		(map['groundItems'] as List).forEach((Map itemMap) {
			String id = itemMap['id'];
			Element element = querySelector("#$id");
			if(element == null) {
				addItem(itemMap);
			} else {
				if(itemMap['onGround'] == false) {
					element.remove();
					entities.remove(id);
					CurrentPlayer.intersectingObjects.clear();
				} else {
					element.attributes['actions'] = JSON.encode(itemMap['actions']);
				}
			}
		});
	});
	streetSocket.onClose.listen((CloseEvent e) {
		log('[Multiplayer (Street)] Socket closed');
		if(!reconnect) {
			querySelector('#server-down').hidden = false;
			serverDown = true;
			reconnect = true;
			return;
		}

		joined = "";
		//wait 5 seconds and try to reconnect
		new Timer(new Duration(seconds: 5), () {
			_setupStreetSocket(currentStreet.label);
		});
	});
	streetSocket.onError.listen((Event e) {
		log('[Multiplayer (Street)] Error ${e}');
	});
}

_updateChatBubble(Map map, Entity entity) {
	if(map["bubbleText"] != null) {
		if(entity.chatBubble == null) {
			String heightString = entity.canvas.height.toString();
			String translateY = entity.canvas.attributes['translateY'];

			if(entity.canvas.attributes['actualHeight'] != null) {
				heightString = entity.canvas.attributes['actualHeight'];
				int diff = entity.canvas.height - int.parse(heightString);
				translateY = (int.parse(translateY) + diff).toString();
			}

			DivElement bubbleParent = new DivElement()
				..style.position = 'absolute'
				..style.width = entity.canvas.width.toString() + 'px'
				..style.height = heightString + 'px'
				..style.transform =
			'translateX(${map['x']}px) translateY(${translateY}px)';
			view.playerHolder.append(bubbleParent);
			entity.chatBubble = new ChatBubble(
				map["bubbleText"], entity, bubbleParent,
				autoDismiss: false, removeParent: true, gains:map['gains']);
		}

		entity.chatBubble.update(1.0);
	} else if(entity.chatBubble != null) entity.chatBubble.removeBubble();
}

_setupPlayerSocket() {
	playerSocket = new WebSocket(multiplayerServer);
	playerSocket.onOpen.listen((_) {
		playerSocket.send(JSON.encode({'clientVersion': Configs.clientVersion}));
	});
	playerSocket.onMessage.listen((MessageEvent event) {
		Map map = JSON.decode(event.data);
		if(map['error'] != null) {
			reconnect = false;
			print(map['error']);
			log('[Multiplayer (Player)] Error ${map['error']}');
			playerSocket.close();
			return;
		}

		if(map['gotoStreet'] != null) {
			streetService.requestStreet(map['tsid']);
			return;
		}

		if(map['street'] != null &&
		   currentStreet.label != map['street'] &&
		   map['changeStreet'] == null) return;

		if(map['username'] == game.username) return;

		if(map["changeStreet"] != null) {
			//someone left this street
			if(map["changeStreet"] != currentStreet.label) {
				removeOtherPlayer(map["username"]);
			} else {
				createOtherPlayer(map);
			}
		} else if(map["disconnect"] != null) {
			removeOtherPlayer(map["username"]);
		} else if(otherPlayers[map["username"]] == null) {
			createOtherPlayer(map);
		} else {
			//update a current otherPlayer
			updateOtherPlayer(map, otherPlayers[map["username"]]);
		}
	});
	playerSocket.onClose.listen((_) {
		log('[Multiplayer (Player)] Socket closed');
		if(!reconnect) {
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
		log('[Multiplayer (Player)] Error ${e}');
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
	if(CurrentPlayer.chatBubble != null) map["bubbleText"] =
	CurrentPlayer.chatBubble.text;
	playerSocket.send(JSON.encode(map));
}

void createOtherPlayer(Map map) {
	if(creatingPlayer == map['username']) {
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
	if(otherPlayer.currentAnimation == null) {
		otherPlayer.currentAnimation = otherPlayer.animations[map["animation"]];
	}

	//set movement bools
	if(map['jumping'] != null) {
		otherPlayer.jumping = map['jumping'];
	}
	if(map['climbing'] == true) {
		otherPlayer.currentAnimation.paused = !map['activeClimb'];
	} else {
		otherPlayer.currentAnimation.paused = false;
	}

	//set animation state
	if(map["animation"] != otherPlayer.currentAnimation.animationName) {
		otherPlayer.currentAnimation.reset();
		otherPlayer.currentAnimation = otherPlayer.animations[map["animation"]];
	}

	otherPlayer.playerParentElement.id = "player-" + sanitizeName(map["username"].replaceAll(' ', '_'));
	otherPlayer.playerParentElement.style.position = "absolute";
	if(map['username'] != otherPlayer.username) {
		otherPlayer.username = map['username'];
		otherPlayer.loadAnimations();
	}

	//set player position
	otherPlayer.posX = double.parse(map["xy"].split(',')[0]);
	otherPlayer.posY = double.parse(map["xy"].split(',')[1]);

	if(map["bubbleText"] != null) {
		if(otherPlayer.chatBubble == null) {
			otherPlayer.chatBubble = new ChatBubble(map["bubbleText"], otherPlayer, otherPlayer.playerParentElement);
		}
		otherPlayer.playerParentElement.append(otherPlayer.chatBubble.bubble);
	} else if(otherPlayer.chatBubble != null) {
		otherPlayer.chatBubble.bubble.remove();
		otherPlayer.chatBubble = null;
	}

	bool facingRight = false;
	if(map["facingRight"] == "true" || map['facingRight'] == true) {
		facingRight = true;
	}
	otherPlayer.facingRight = facingRight;
}

void removeOtherPlayer(String username) {
	if(username == null) return;

	otherPlayers.remove(username);
	Element otherPlayer =
	querySelector("#player-" + sanitizeName(username.replaceAll(' ', '_')));
	if(otherPlayer != null) otherPlayer.remove();
}

void addQuoin(Map map) {
	if(currentStreet == null) return;

	quoins[map['id']] = new Quoin(map);
}

void addNPC(Map map) {
	if(currentStreet == null) return;

	entities[map['id']] = new NPC(map);
}

void addPlant(Map map) {
	if(currentStreet == null) return;

	entities[map['id']] = new Plant(map);
}

void addItem(Map map) {
	if(currentStreet == null) {
		return;
	}

	entities[map['id']] = new GroundItem(map);
}

void addItemToInventory(Map map) {
	ImageElement img = new ImageElement(src: map['item']['spriteUrl']);
	img.onLoad.first.then((_) {
		//do some fancy 'put in bag' animation that I can't figure out right now
		//animate(img,map).then((_) => putInInventory(img,map));

		putInInventory(img, map);
	});
}

void subtractItemFromInventory(Map map) {
	String cssName = map['itemType'].replaceAll(" ", "_");
	int remaining = map['count'];
	for(Element item in view.inventory.querySelectorAll(".item-$cssName")) {
		if(remaining < 1) break;

		int count = int.parse(item.attributes['count']);
		if(count > map['count']) {
			item.attributes['count'] = (count - map['count']).toString();
			item.parent
			.querySelector('.itemCount').text = (count - map['count']).toString();
		} else item.parent.children.clear();

		remaining -= count;
	}
}

Future animate(ImageElement i, Map map) {
	Completer c = new Completer();
	Element fromObject = querySelector("#${map['fromObject']}");
	DivElement item = new DivElement();

	num fromX = num.parse(fromObject.attributes['translatex']) - camera.getX();
	num fromY = num.parse(fromObject.attributes['translatey']) -
	            camera.getY() -
	            fromObject.clientHeight;
	item.className = "item";
	item.style.width = (i.naturalWidth / 4).toString() + "px";
	item.style.height = i.naturalHeight.toString() + "px";
	item.style.transformOrigin = "50% 50%";
	item.style.backgroundImage = 'url(${map['url']})';
	item.style.transform = "translate(${fromX}px,${fromY}px)";
	print("from: " + item.style.transform);
	querySelector("#GameScreen").append(item);

	//animation seems to happen instantaneously if there isn't a delay
	//between adding the element to the document and changing its properties
	//even this 1 millisecond delay seems to fix that - strange
	new Timer(new Duration(milliseconds: 1), () {
		Element playerParent = querySelector(".playerParent");
		item.style.transform =
		"translate(${playerParent.attributes['translatex']}px,${playerParent.attributes['translatey']}px) scale(2)";
		print("to: " + item.style.transform);
	});
	new Timer(new Duration(seconds: 2), () {
		item.style.transform =
		"translate(${CurrentPlayer.posX}px,${CurrentPlayer.posY}px) scale(.5)";

		//wait 1 second for animation to finish and then remove
		new Timer(new Duration(seconds: 1), () {
			item.remove();
			c.complete();
		});
	});

	return c.future;
}

void putInInventory(ImageElement img, Map map) {
	Map i = map['item'];
	String name = i['itemType'];
	int stacksTo = i['stacksTo'];
	Element item;
	bool found = false;

	String cssName = name.replaceAll(" ", "_");
	for(Element item in view.inventory.querySelectorAll(".item-$cssName")) {
		int count = int.parse(item.attributes['count']);

		if(count < stacksTo) {
			count++;
			int offset = count;
			if(i['iconNum'] != null && i['iconNum'] < count) {
				offset = i['iconNum'];
			}

			num width = img.width / i['iconNum'];
			item.style.backgroundPosition = "calc(100% / ${i['iconNum'] - 1} * ${offset - 1}";
			item.attributes['count'] = count.toString();

			Element itemCount = item.parent.querySelector(".itemCount");
			if(itemCount != null) {
				itemCount.text = count.toString();
			}
			else {
				SpanElement itemCount = new SpanElement()
					..text = count.toString()
					..className = "itemCount";
				item.parent.append(itemCount);
			}

			found = true;
			break;
		}
	}
	if(!found) {
		findNewSlot(item, map, img);
	}
}

findNewSlot(Element item, Map map, ImageElement img) {
	bool found = false;
	Map i = map['item'];
	int stacksTo = i['stacksTo'];

	//find first free item slot
	for(Element barSlot in view.inventory.children) {
		if(barSlot.children.length == 0) {
			String cssName = i['itemType'].replaceAll(" ", "_");
			item = new DivElement();

			//determine what we need to scale the sprite image to in order to fit
			num scale = 1;
			if(img.height > img.width / i['iconNum']) {
				scale = (barSlot.contentEdge.height - 10) / img.height;
			} else {
				scale = (barSlot.contentEdge.width - 10) / (img.width / i['iconNum']);
			}

			item.style.width = (barSlot.contentEdge.width - 10).toString() + "px";
			item.style.height = (barSlot.contentEdge.height - 10).toString() + "px";
			item.style.backgroundImage = 'url(${i['spriteUrl']})';
			item.style.backgroundRepeat = 'no-repeat';
			item.style.backgroundSize = "${img.width * scale}px ${img.height * scale}px";
			item.style.backgroundPosition = "0 50%";
			item.style.margin = "auto";
			item.className = 'item-$cssName inventoryItem';
			item.attributes['name'] = i['name'].replaceAll(' ', '');
			item.attributes['count'] = "1";
			item.attributes['itemMap'] = JSON.encode(i);

			item.onContextMenu.listen((MouseEvent event) {
				List<List> actions = [];
				if(i['actions'] != null) {
					List<Action> actionsList = decode(JSON.encode(i['actions']), type: const TypeHelper<List<Action>>().type);
					bool enabled = false;
					actionsList.forEach((Action action) {
						String error = "";
						List<Map> requires = [];
						action.itemRequirements.all.forEach((String item, int num) => requires.add({'num':num, 'of':[item]}));
						if(action.itemRequirements.any.length > 0) {
							requires.add({'num':1, 'of':action.itemRequirements.any});
						}
						enabled = hasRequirements(requires);
						if(enabled) {
							error = action.description;
						} else {
							error = getRequirementString(requires);
						}
						actions.add([
							            capitalizeFirstLetter(action.name) + '|' +
							            action.name + '|${action.timeRequired}|$enabled|$error',
							            i['itemType'],
							            "sendAction ${action.name} ${i['id']}",
							            getDropMap(i, 1)
						            ]);
					});
				}
				Element menu = RightClickMenu.create(event, i['name'], i['description'], actions, itemName: i['name']);
				document.body.append(menu);
			});
			barSlot.append(item);

			item.classes.add("bounce");
			//remove the bounce class so that it's not still there for a drag and drop event
			new Timer(new Duration(seconds: 1), () => item.classes.remove("bounce"));

			found = true;
			break;
		}
	}

	//there was no space in the player's pack, drop the item on the ground instead
	if(!found){
		sendAction("drop", i['itemType'], getDropMap(i, 1));
	}
}

Map getDropMap(Map item, int count) {
	Map dropMap = new Map()
		..['dropItem'] = item
		..['count'] = count
		..['x'] = CurrentPlayer.posX
		..['y'] = CurrentPlayer.posY + CurrentPlayer.height / 2
		..['streetName'] = currentStreet.label
		..['tsid'] = currentStreet.streetData['tsid'];

	return dropMap;
}
