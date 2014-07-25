part of coUclient;

String multiplayerServer = "ws://robertmcdermot.com:8080/playerUpdate";
String streetEventServer = "ws://localhost:8181/streetUpdate";
String joined = "";
WebSocket streetSocket;
bool reconnect = true;
Map<String,Player> otherPlayers = new Map();
Map<String,Quoin> quoins = new Map();
Map<String,Entity> entities = new Map();

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
		map["tsid"] = currentStreet._data['tsid'];
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
		if(map['itemsForSale'] != null)
		{
			showVendorWindow(map);
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
		(map["plants"] as List).forEach((Map plantMap)
		{
			String id = plantMap["id"];
            Element element = querySelector("#$id");
            Plant plant = entities[plantMap["id"]];
			if(element == null)
				addPlant(plantMap);
			if(plant != null && plant.state != plantMap['state'])
				plant.updateState(plantMap['state']);
		});
		(map["npcs"] as List).forEach((Map npcMap)
		{
			String id = npcMap["id"];
            Element element = querySelector("#$id");
            NPC npc = entities[npcMap["id"]];
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
		(map['groundItems'] as List).forEach((Map itemMap)
		{
			String id = itemMap['id'];
			Element element = querySelector("#$id");
			if(element == null)
				addItem(itemMap);
			else
			{
				if(itemMap['onGround'] == false)
					element.remove();
			}
		});
	});
	streetSocket.onClose.listen((_)
	{
		if(!reconnect)
		{
			reconnect = true;
			return;
		}
		
		joined = "";
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
		joined = "";
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
	
	entities[map['id']] = new NPC(map);
}

void addPlant(Map map)
{
	if(currentStreet == null)
		return;
	
	entities[map['id']] = new Plant(map);
}

void addItem(Map map)
{
	if(currentStreet == null)
		return;
	
	ImageElement item = new ImageElement(src:map['iconUrl']);
	item.onLoad.first.then((_)
	{
		item.style.transform = "translateX(${map['x']}px) translateY(${map['y']}px)";
		item.style.position = "absolute";
    	item.attributes['translatex'] = map['x'].toString();
    	item.attributes['translatey'] = map['y'].toString();
    	item.attributes['width'] = item.width.toString();
        item.attributes['height'] = item.height.toString();
    	item.attributes['type'] = map['name'];
    	item.attributes['actions'] = JSON.encode(map['actions']);
    	item.classes.add('groundItem');
    	item.classes.add('entity');
    	item.id = map['id'];
    	querySelector("#PlayerHolder").append(item);
	});
}

void addItemToInventory(Map map)
{	
	ImageElement img = new ImageElement(src:map['item']['spriteUrl']);
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
	Map i = map['item'];
	String name = i['name'];
	int stacksTo = i['stacksTo'];
	Element item;
	bool found = false;
	
	String cssName = name.replaceAll(" ","_");
	for(Element item in querySelector("#InventoryBar").querySelectorAll(".item-$cssName"))
	{
		int count = int.parse(item.attributes['count']);
		
		if(count < stacksTo)
		{
			count++;
    		int offset = count;
    		if(i['iconNum'] != null && i['iconNum'] < count)
    			offset = i['iconNum'];
    		
    		num width = img.width/i['iconNum'];
    		item.style.backgroundPosition = "calc(100% / ${i['iconNum'] - 1} * ${offset - 1}";
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
    		
    		found = true;
    		break;
		}
	}
	if(!found)
    {
		findNewSlot(item,map,img);
    }
}

findNewSlot(Element item, Map map, ImageElement img)
{
	bool found = false;
	Map i = map['item'];
	int stacksTo = i['stacksTo'];
	
	//find first free item slot
	for(Element barSlot in querySelector("#InventoryBar").children)
	{
		if(barSlot.children.length == 0)
		{
			String cssName = i['name'].replaceAll(" ","_");
			item = new DivElement();
			
			//determine what we need to scale the sprite image to in order to fit
			num scale = 1;
			if(img.height > img.width/i['iconNum'])
				scale = (barSlot.contentEdge.height-10)/img.height;
			else
				scale = (barSlot.contentEdge.width-10)/(img.width/i['iconNum']);
			
			item.style.width = (barSlot.contentEdge.width-10).toString()+"px";
			item.style.height = (barSlot.contentEdge.height-10).toString()+"px";
			item.style.backgroundImage = 'url(${i['spriteUrl']})';
			item.style.backgroundRepeat = 'no-repeat';
			item.style.backgroundSize = "${img.width*scale}px ${img.height*scale}px";
			item.style.backgroundPosition = "0 50%";
			item.style.margin = "auto";
			item.className = 'bounce item-$cssName';
			item.attributes['name'] = cssName;
			item.attributes['count'] = "1";
			barSlot.append(item);
			found = true;
			break;
		}
	}
	
	//there was no space in the player's pack, drop the item on the ground instead
	if(!found)
		dropItem(i);
}

void dropItem(Map item)
{
	Map dropMap = new Map()
		..['dropItem'] = item
		..['count'] = 1
		..['x'] = CurrentPlayer.posX
		..['y'] = CurrentPlayer.posY+CurrentPlayer.height/2
		..['streetName'] = currentStreet.label
		..['tsid'] = currentStreet._data['tsid'];
	
	streetSocket.send(JSON.encode(dropMap));
}

void showVendorWindow(Map map)
{
	TemplateElement vendorTemplate = querySelector("#VendorTemplate");
	document.body.append(vendorTemplate.content.clone(true));
	querySelector("#CloseVendor").onClick.first.then((_) => querySelector("#VendorWindow").remove());
	
	querySelector("#VendorTitle").text = map['vendorName'];
	Element content = querySelector("#VendorContent");
	for(Map item in map['itemsForSale'] as List)
	{
		DivElement parent = new DivElement()..className = "vendorItemParent";
		DivElement tooltip = new DivElement()..className = "vendorItemTooltip";
		ImageElement image = new ImageElement(src:item['iconUrl'])..className = "vendorItemPreview";
		DivElement price = new DivElement()..className = "vendorItemPrice";
		tooltip.text = item['name'];
		price.text = item['price'].toString() + "\u20a1";
		
		//if we can't afford it, color the price reddish
		if(item['price'] > getCurrants())
			price.classes.add("cantAfford");
		parent..append(tooltip)..append(image)..append(price);
		content.append(parent);
	}
}