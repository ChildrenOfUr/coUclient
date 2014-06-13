part of coUclient;

String multiplayerServer = "ws://vps.robertmcdermot.com:8080/playerUpdate";//"ws://couserver.herokuapp.com/playerUpdate";
String streetEventServer = "ws://vps.robertmcdermot.com:8080/streetUpdate";//"ws://couserver.herokuapp.com/streetUpdate";
WebSocket streetSocket;
bool reconnect = true;
Map<String,Player> otherPlayers;
Map<String,NPC> npcs;
Map<String,Quoin> quoins;

multiplayerInit()
{
	otherPlayers = new Map();
	npcs = new Map();
	quoins = new Map();
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
	if(currentStreet == null)
    	return;
	
	quoins[map['id']] = new Quoin(map);
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
	ImageElement img = new ImageElement();
	img.src = map["url"];
	img.onLoad.listen((_)
	{
		NPC npc = new NPC(canvas,img,map["numRows"],map["numColumns"],numFrames:map["numFrames"]);
		npc.posX = map['x'].toDouble();
		npc.posY = (currentStreet.bounds.height - 170).toDouble();
		npcs[map["id"]] = npc;
	});
	querySelector("#PlayerHolder").append(canvas);
}