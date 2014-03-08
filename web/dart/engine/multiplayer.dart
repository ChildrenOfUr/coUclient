part of coUclient;

String multiplayerServer = "ws://couserver.herokuapp.com/playerUpdate";
String streetEventServer = "ws://couserver.herokuapp.com/streetUpdate";
WebSocket streetSocket;

multiplayerInit()
{
	otherPlayers = new Map();
	_setupPlayerSocket();
}

streetSocketSetup(String streetName)
{
	if(streetSocket != null && streetSocket.readyState == WebSocket.OPEN)
	{
		//send one final leaving message
		Map map = new Map();
		map["username"] = chat.username;
		map["streetName"] = streetName;
		map["message"] = "left";
		streetSocket.send(JSON.encode(map));
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
    		if(querySelector("#$id") == null)
    		{
    			CssStyleSheet styleSheet = document.styleSheets[0] as CssStyleSheet;
    			try
    			{
    				//insert @-webkit-keyframes rule second so Firefox doesn't have a temper tantrum
    				String keyframes = map["keyframes"];
    				styleSheet.insertRule("@"+keyframes.substring(9),1);
    				styleSheet.insertRule(keyframes,1);
    			}
                catch(error){print(error);}
    			
    			addQuoin(map);
    		}
    		else if(querySelector("#$id").style.display == "none")
    			querySelector("#$id").style.display = "block";
		}
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
	
	updateOtherPlayer(map,otherPlayer);
	
	otherPlayers[map["username"]] = otherPlayer;
	querySelector("#PlayerHolder").append(otherPlayer.playerCanvas);
}

updateOtherPlayer(Map map, Player otherPlayer)
{
	otherPlayer.currentAnimation = CurrentPlayer.animations[map["animation"]];
	if(!otherPlayer.avatar.style.backgroundImage.contains(otherPlayer.currentAnimation.backgroundImage))
	{
		otherPlayer.avatar.style.backgroundImage = 'url('+otherPlayer.currentAnimation.backgroundImage+')';
		otherPlayer.avatar.style.width = otherPlayer.currentAnimation.width.toString()+'px';
		otherPlayer.avatar.style.height = otherPlayer.currentAnimation.height.toString()+'px';
		otherPlayer.avatar.style.animation = otherPlayer.currentAnimation.animationStyleString;
		otherPlayer.canvasHeight = otherPlayer.currentAnimation.height+50;
	}
	
	otherPlayer.playerCanvas.style.position = "absolute";
	otherPlayer.playerCanvas.id = "player-"+map["username"];
	

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
	element.className = map["type"];
	element.style.animation = map["animation"];
	element.style.position = "absolute";
	element.style.left = map["x"].toString()+"px";
	element.style.bottom = map["y"].toString()+"px";
	element.style.width = map["width"].toString()+"px";
	element.style.height = map["height"].toString()+"px";
	querySelector("#PlayerHolder").append(element);
	querySelector("#PlayerHolder").append(circle);
	querySelector("#PlayerHolder").append(parent);
}