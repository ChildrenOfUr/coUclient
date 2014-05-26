part of coUclient;

String multiplayerServer = "ws://couserver.herokuapp.com/playerUpdate";
String streetEventServer = "ws://couserver.herokuapp.com/streetUpdate";
WebSocket streetSocket;
bool reconnect = true;
Map<String,Player> otherPlayers;
Map<String,NPC> npcs;

multiplayerInit()
{
	otherPlayers = new Map();
	npcs = new Map();
	_setupPlayerSocket();
	_setupStreetSocket(currentStreet.label);
}

_setupStreetSocket(String streetName)
{
	if(streetSocket != null && streetSocket.readyState == WebSocket.OPEN)
	{
		//send one final leaving message
		Map map = new Map();
		map["username"] = chat.username;
		map["streetName"] = streetName;
		map["message"] = "left";
		streetSocket.send(JSON.encode(map));
		reconnect = false;
		streetSocket.close();
	}
	
	streetSocket = new WebSocket(streetEventServer);
	streetSocket.onOpen.listen((_)
	{
		if(streetSocket.readyState == WebSocket.OPEN)
		{
			Map map = new Map();
			map["username"] = chat.username;
			map["streetName"] = streetName;
			map["message"] = "joined";
			streetSocket.send(JSON.encode(map));
		}
	});
	streetSocket.onMessage.listen((MessageEvent event)
	{
		Map map = JSON.decode(event.data);
		
		if(map["remove"] != null && querySelector("#${map["remove"]}") != null)
			querySelector("#${map["remove"]}").style.display = "none"; //.remove() is very slow
		else if(map["remove"] == null)
		{
			String id = map["id"];
			Element element = querySelector("#$id");
			if(id.startsWith("q"))
			{
        		if(element == null)
        		{
        			addQuoin(map);
        		}
        		else if(element.style.display == "none")
        		{
        			element.style.display = "block";
        		}
			}
			if(id.startsWith("n"))
			{
				NPC npc = null;
				if(npcs != null)
					npc = npcs[map["id"]];
				if(element == null)
				{
					addNPC(map);
				}
				else if(npc != null)
				{
					if(npc.img.src != map["url"]) //new animation
					{
						ImageElement img = new ImageElement();
    					img.src = map["url"];
    					img.onLoad.listen((_)
    					{
    						npcs[map["id"]].resetImage(img,map);
    					});
					}
					
					npc.facingRight = map["facingRight"];
				}
			}
		}
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

createOtherPlayer(Map map)
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
		otherPlayer.playerCanvas.append(otherPlayer.chatBubble.bubble);
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

removeOtherPlayer(String username)
{
	if(username == null)
		return;
	
	otherPlayers.remove(username);
	Element otherPlayer = querySelector("#player-"+username);
	if(otherPlayer != null)
		otherPlayer.remove();
}

addQuoin(Map map)
{
	//inserting rules can be messy - Firefox throws exceptions if you try to insert a @-webkit-keyframes rule
	//and chrome mobile (not desktop though) throws an exception the other way around
	CssStyleSheet styleSheet = document.styleSheets[0] as CssStyleSheet;
	String keyframes = map["keyframes"];
	try
	{
		styleSheet.insertRule(keyframes,1);
	}
	catch(error){}
	try
	{
		styleSheet.insertRule("@"+keyframes.substring(9),1);
	}
	catch(error){}
              
	String id = map["id"];
	DivElement element = new DivElement();
	DivElement circle = new DivElement()
		..id = "q"+id
		..className = "circle"
		..style.position = "absolute"
		..style.left = map["x"].toString()+"px"
		..style.bottom = map["y"].toString()+"px";
	DivElement parent = new DivElement()
		..id = "qq"+id
		..className = "parent"
		..style.position = "absolute"
		..style.left = map["x"].toString()+"px"
		..style.bottom = map["y"].toString()+"px";
	DivElement inner = new DivElement();
	inner.className = "inner";
	DivElement content = new DivElement();
	content.className = "quoinString";
	parent.append(inner);
	inner.append(content);
	
	element.style.backgroundImage = "url("+map["url"]+")";
	element.id = id;
	element.className = map["type"] + " quoin";
	element.style.animation = map["animation"];
	element.style.position = "absolute";
	element.style.left = map["x"].toString()+"px";
	element.style.bottom = map["y"].toString()+"px";
	element.style.width = map["width"].toString()+"px";
	element.style.height = map["height"].toString()+"px";
	
	//this causes the browser to paint each quoin seperately which seems better than if it paints
	//them all in one large block (8 70x75 < 1 2000x150 or whatever it turns out to be)
	element.style.transform += " translateZ(0)";
	
	querySelector("#PlayerHolder").append(element);
	querySelector("#PlayerHolder").append(circle);
	querySelector("#PlayerHolder").append(parent);
}

void addNPC(Map map)
{
	if(currentStreet == null)
		return;
	
	CanvasElement canvas = new CanvasElement();
	canvas.id = map["id"];
	canvas.classes.add("npc");
	canvas.width = map["width"];
	canvas.height = map["height"];
	canvas.style.position = "absolute";
	canvas.style.left = map["x"].toString()+"px";
	canvas.style.top = (currentStreet.bounds.height - 170).toString()+"px";
	ImageElement img = new ImageElement();
	img.src = map["url"];
	img.onLoad.listen((_) => npcs[map["id"]] = new NPC(canvas,img,map["numRows"],map["numColumns"],numFrames:map["numFrames"]));
	querySelector("#PlayerHolder").append(canvas);
}