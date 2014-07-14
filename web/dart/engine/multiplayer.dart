part of coUclient;

String multiplayerServer = "ws://vps.robertmcdermot.com:8080/playerUpdate";//"ws://couserver.herokuapp.com/playerUpdate";
String streetEventServer = "ws://vps.robertmcdermot.com:8080/streetUpdate";//"ws://couserver.herokuapp.com/streetUpdate";
String joined = "";
WebSocket streetSocket;
bool reconnect = true;
Map<String,Player> otherPlayers = new Map();
Map<String,NPC> npcs = new Map();
Map<String,Quoin> quoins = new Map();
Map<String,Plant> plants = new Map();

multiplayerInit()
{
	_setupPlayerSocket();
	_setupStreetSocket(currentStreet.label);
}

void sendLeftMessage(String streetName)
{
	if(streetSocket != null && streetSocket.readyState == WebSocket.OPEN)
    {
		Map map = new Map();
		map["username"] = chat.username;
		map["streetName"] = streetName;
		map["message"] = "left";
		streetSocket.send(JSON.encode(map));
    }
}

void sendJoinedMessage(String streetName)
{
	if(joined != streetName && streetSocket != null && streetSocket.readyState == WebSocket.OPEN)
	{
		Map map = new Map();
		map["username"] = chat.username;
		map["streetName"] = streetName;
		map["message"] = "joined";
		streetSocket.send(JSON.encode(map));
		joined = streetName;
	}
}

_setupStreetSocket(String streetName)
{
	streetSocket = new WebSocket(streetEventServer);
	
	streetSocket.onOpen.listen((_)
	{
		sendJoinedMessage(streetName);
	});
	streetSocket.onMessage.listen((MessageEvent event)
	{
		Map map = JSON.decode(event.data);
		//check if we are receiving an item
		if(map['giveItem'] != null)
		{
			addItemToInventory(map);
			return;
		}
		
		(map["quoins"] as List).forEach((Map quoinMap)
		{
			if(quoinMap["remove"] == "true")
    		{
    			Element objectToRemove = querySelector("#${quoinMap["remove"]}");
    			if(objectToRemove != null)
    				objectToRemove.style.display = "none"; //.remove() is very slow
    		}
			else
			{
				String id = quoinMap["id"];
				Element element = querySelector("#$id");
				if(element == null)
					addQuoin(quoinMap);
				else if(element.style.display == "none")
				{
					element.style.display = "block";
					element.attributes['collected'] = "false";
				}
			}
		});
		(map["npcs"] as List).forEach((Map npcMap)
		{
			String id = npcMap["id"];
            Element element = querySelector("#$id");
            NPC npc = npcs[npcMap["id"]];
			if(element == null)
				addNPC(npcMap);
			else if(npc != null)
			{
				if(npc.animation.url != npcMap["url"]) //new animation
				{
					npc.ready = false;
					
					List<int> frameList = [];
            		for(int i=0; i<npcMap['numFrames']; i++)
            			frameList.add(i);
            		
            		npc.animation = new Animation(npcMap['url'],"npc",npcMap['numRows'],npcMap['numColumns'],frameList);
            		npc.animation.load().then((_) => npc.ready = true);
					
				}
				
				npc.facingRight = npcMap["facingRight"];
			}
		});
		(map["plants"] as List).forEach((Map plantMap)
		{
			String id = plantMap["id"];
            Element element = querySelector("#$id");
            Plant plant = plants[plantMap["id"]];
			if(element == null)
				addPlant(plantMap);
			if(plant != null && plant.state != plantMap['state'])
				plant.updateState(plantMap['state']);
		});
	});
	streetSocket.onClose.listen((_)
	{
		if(!reconnect)
		{
			reconnect = true;
			return;
		}
		
		//wait 5 seconds and try to reconnect
		new Timer(new Duration(seconds:5),()
		{
			_setupStreetSocket(currentStreet.label);
		});
	});
}

_setupPlayerSocket()
{
	playerSocket = new WebSocket(multiplayerServer);
	playerSocket.onMessage.listen((MessageEvent event)
	{
		Map map = JSON.decode(event.data);
		if(map["changeStreet"] != null)
		{
			if(map["changeStreet"] != currentStreet.label) //someone left this street
			{
				removeOtherPlayer(map["username"]);
			}
			else //someone joined
			{
				createOtherPlayer(map);
			}
		}
		else if(map["disconnect"] != null)
		{
			removeOtherPlayer(map["username"]);
		}
		else if(otherPlayers[map["username"]] == null)
		{
			createOtherPlayer(map);
		}
		else //update a current otherPlayer
		{
			updateOtherPlayer(map,otherPlayers[map["username"]]);
		}
	});
	playerSocket.onClose.listen((_)
	{
		//wait 5 seconds and try to reconnect
		new Timer(new Duration(seconds:5),()
		{
			_setupPlayerSocket();
		});
	});
}

sendPlayerInfo()
{
	String xy = CurrentPlayer.posX.toString()+","+CurrentPlayer.posY.toString();
	timeLast = 0.0;
	Map map = new Map();
	map["username"] = chat.username;
	map["xy"] = xy;
	map["street"] = currentStreet.label;
	map["facingRight"] = CurrentPlayer.facingRight.toString();
	map["animation"] = CurrentPlayer.currentAnimation.animationName;
	if(CurrentPlayer.chatBubble != null)
		map["bubbleText"] = CurrentPlayer.chatBubble.text;
	playerSocket.send(JSON.encode(map));
}

void createOtherPlayer(Map map)
{
	Player otherPlayer = new Player(map["username"]);
	otherPlayer.loadAnimations().then((_)
	{
		updateOtherPlayer(map,otherPlayer);
        	
        otherPlayers[map["username"]] = otherPlayer;
        querySelector("#PlayerHolder").append(otherPlayer.playerParentElement);
	});
}

updateOtherPlayer(Map map, Player otherPlayer)
{
	otherPlayer.currentAnimation = otherPlayer.animations[map["animation"]];
	otherPlayer.playerParentElement.id = "player-"+map["username"];
	otherPlayer.playerParentElement.style.position = "absolute";
	
	double x = double.parse(map["xy"].split(',')[0]);
	double y = double.parse(map["xy"].split(',')[1]);

	otherPlayer.posX = x;
	otherPlayer.posY = y;
	
	if(map["bubbleText"] != null)
	{
		if(otherPlayer.chatBubble == null)
			otherPlayer.chatBubble = new ChatBubble(map["bubbleText"]);
		otherPlayer.playerParentElement.append(otherPlayer.chatBubble.bubble);
	}
	else if(otherPlayer.chatBubble != null)
	{
		otherPlayer.chatBubble.bubble.remove();
		otherPlayer.chatBubble = null;
	}
	
	bool facingRight = false;
	if(map["facingRight"] == "true")
		facingRight = true;
	otherPlayer.facingRight = facingRight;
}

void removeOtherPlayer(String username)
{
	if(username == null)
		return;
	
	otherPlayers.remove(username);
	Element otherPlayer = querySelector("#player-"+username);
	if(otherPlayer != null)
		otherPlayer.remove();
}

void addQuoin(Map map)
{
	if(currentStreet == null)
    	return;
	
	quoins[map['id']] = new Quoin(map);
}
void addNPC(Map map)
{
	if(currentStreet == null)
		return;
	
	npcs[map['id']] = new NPC(map);
}

void addPlant(Map map)
{
	if(currentStreet == null)
		return;
	
	plants[map['id']] = new Plant(map);
}

void addItemToInventory(Map map)
{	
	ImageElement img = new ImageElement(src:map['url']);
	img.onLoad.first.then((_)
	{
		//do some fancy 'put in bag' animation that I can't figure out right now
		//animate(img,map).then((_) => putInInventory(img,map));
		
		putInInventory(img,map);
	});
}

Future animate(ImageElement i, Map map)
{
	Completer c = new Completer();
	Element fromObject = querySelector("#${map['fromObject']}");
	DivElement item = new DivElement();
	
	num fromX = num.parse(fromObject.attributes['translatex']) - camera.getX();
	num fromY = num.parse(fromObject.attributes['translatey']) - camera.getY() - fromObject.clientHeight;
	item.className = "item";
	item.style.width = (i.naturalWidth/4).toString()+"px";
	item.style.height = i.naturalHeight.toString()+"px";
	item.style.transformOrigin = "50% 50%";
	item.style.backgroundImage = 'url(${map['url']})';
	item.style.transform = "translate(${fromX}px,${fromY}px)";
	print("from: " + item.style.transform);
	querySelector("#GameScreen").append(item);
	
	//animation seems to happen instantaneously if there isn't a delay
	//between adding the element to the document and changing its properties
	//even this 1 millisecond delay seems to fix that - strange
	new Timer(new Duration(milliseconds:1), ()
    {
		Element playerParent = querySelector(".playerParent");
		item.style.transform = "translate(${playerParent.attributes['translatex']}px,${playerParent.attributes['translatey']}px) scale(2)";
		print("to: " + item.style.transform);
    });
	new Timer(new Duration(seconds:2), ()
    {
		item.style.transform = "translate(${CurrentPlayer.posX}px,${CurrentPlayer.posY}px) scale(.5)";
		
		//wait 1 second for animation to finish and then remove
		new Timer(new Duration(seconds:1), ()
    	{
    		item.remove();
    		c.complete();
    	});
    });
	
	return c.future;
}

void putInInventory(ImageElement img, Map map)
{
	String name = map['name'];
	Element item;
	
	if(querySelector("#InventoryBar").querySelector(".item-$name") != null)
	{
		item = querySelector("#InventoryBar").querySelector(".item-$name");
		int count = int.parse(item.attributes['count']);
		count++;
		int offset = count;
		if(offset > 4)
			offset = 4;
		
		num width = int.parse(item.style.width.replaceAll("px", ""));
		item.style.backgroundPosition = "-${(offset-1)*width}px";
		item.attributes['count'] = count.toString();
		
		Element itemCount = item.parent.querySelector(".itemCount");
		if(itemCount != null)
			itemCount.text = count.toString();
		else
		{
			SpanElement itemCount = new SpanElement()
				..text = count.toString()
				..className = "itemCount";
			item.parent.append(itemCount);
		}
	}
	else
    {
		bool found = false;
		//find first free item slot
    	for(Element barSlot in querySelector("#InventoryBar").children)
    	{
    		if(barSlot.children.length == 0)
    		{
    			item = new DivElement();
				item.style.width = barSlot.contentEdge.width.toString()+"px";
				item.style.height = (img.height).toString()+"px";
				item.style.backgroundImage = 'url(${map['url']})';
				item.style.backgroundRepeat = 'no-repeat';
				item.style.backgroundSize = "400% ${item.style.height}";
				item.className = 'bounce item-'+map['name'];
    			item.attributes['name'] = map['name'];
    			item.attributes['count'] = "1";
    			barSlot.append(item);
    			found = true;
    			break;
    		}
    	}
    	
    	//there was no space in the player's pack, drop the item on the ground instead
    	if(!found)
    	{
    		
    	}
    }
}