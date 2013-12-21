part of coUclient;
//TODO: should we limit chat history so that it doesn't go on forever?
//TODO: should links be clickable?

//TODO: make text selectable
//TODO: make text wrapping work better
//TODO: make non-focused tab flash if message? or show counter?
//TODO: get list of people in chat
//TODO: allow names to have spaces? or give error message
//TODO: @ mentions
//TODO: setting to turn off joined messages
//TODO: right margin on the text could be wider (farther away from the scoll bar)
//TODO: only scroll down if you are the one to add a message
//TODO: reconnect if the connection drops

List<String> colors = ["aqua", "blue", "fuchsia", "gray", "green", "lime", "maroon", "navy", "olive", "orange", "purple", "red", "teal"];
String username = "testUser"; //TODO: get actual username of logged in user;
Storage localStorage = window.localStorage;

handleChat()
{
	if(localStorage["username"] != null)
		username = localStorage["username"];
	else
	{
		Random rand = new Random();
		username += rand.nextInt(10000).toString();
	}
	addChatTab("Global Chat", true);
	addChatTab("Other Chat", false);
	querySelector("#ChatPane").children.add(makeTabContent("Local Chat",true));
}


void addChatTab(String channelName, bool checked)
{
	DivElement content = makeTabContent(channelName,false)
		..className = "content";
	DivElement tab = new DivElement()
		..className = "tab";
	RadioButtonInputElement radioButton = new RadioButtonInputElement()
		..id = "tab-"+channelName
		..name = "tabgroup" //only allow one to be selected at a time
		..checked = checked;
	LabelElement label = new LabelElement()
		..attributes['for'] = "tab-"+channelName
		..text = channelName;
	tab.children
		..add(radioButton)
		..add(label)
		..add(content);
	querySelector("#ChatTabs").children.add(tab);
}

DivElement makeTabContent(String channelName, bool useSpanForTitle)
{
	DivElement chatDiv = new DivElement()
		..className = "ChatWindow";
	SpanElement span = new SpanElement()
		..text = channelName;
	DivElement chatHistory = new DivElement()
		..className = "ChatHistory";
	TextInputElement input = new TextInputElement()
		..className = "ChatInput";

	if(useSpanForTitle)
		chatDiv.children.add(span);
	chatDiv.children
		..add(chatHistory)
		..add(input);
	
	//TODO: remove this section when usernames are for real
	if(channelName == "Local Chat")
	{
		Map map = new Map();
		map["statusMessage"] = "hint";
		map["message"] = "Hint :\nYou can set your chat name by typing '/setname <name>'";
		addMessage(chatHistory,map);
	}
	//TODO: end section
	
	WebSocket webSocket = new WebSocket("ws://couchatserver.herokuapp.com");
	webSocket.onOpen.listen((_)
	{
		Map map = new Map();
		map["message"] = 'userName='+username;
		map["channel"] = channelName;
		if(channelName == "Local Chat")
			map["street"] = CurrentStreet.label;
		webSocket.send(JSON.encode(map));
	});
	webSocket.onMessage.listen((MessageEvent messageEvent)
	{
		Map map = JSON.decode(messageEvent.data);
		if(map["message"] == "ping") //only used to keep the connection alive, ignore
			return;
		
		if(map["channel"] == "all") //support for global messages (god mode messages)
		{
			addMessage(chatHistory, map);
		}
		//if we're talking in local, only talk to one street at a time
		else if(map["channel"] == "Local Chat" && map["channel"] == channelName)
		{
			if(map["statusMessage"] != null)
				addMessage(chatHistory, map);
			else if(map["street"] == CurrentStreet.label)
				addMessage(chatHistory, map);
		}
		else if(map["channel"] == channelName)
			addMessage(chatHistory, map);
	});
	webSocket.onClose.listen((_)
	{
		Map map = new Map();
		map["username"] = username;
		map["message"] = "left";
		map["channel"] = channelName;
		if(channelName == "Local Chat")
			map["street"] = CurrentStreet.label;
		webSocket.send(JSON.encode(map));
	});
	
	input.onKeyUp.listen((key)
	{
  		if (key.keyCode != 13) //listen for enter key
			return;
			
		if(input.value.trim().length == 0) //don't allow for blank messages
			return;
		
		Map map = new Map();
		if(input.value.split(" ")[0] == "/setname")
		{
			String prevName = username;
			map["statusMessage"] = "changeName";
			map["username"] = prevName;
			map["newUsername"] = input.value.split(" ")[1];
			map["channel"] = channelName;
		}
		else
		{
			map["username"] = username;
			map["message"] = input.value;
			map["channel"] = channelName;
			if(channelName == "Local Chat")
				map["street"] = CurrentStreet.label;
		}
		webSocket.send(JSON.encode(map));
		input.value = '';
	});
	
	return chatDiv;
}

void addMessage(DivElement chatHistory, Map map)
{
	print("got message: " + JSON.encode(map));
	SpanElement userElement = new SpanElement();
	SpanElement text = new SpanElement();
	DivElement chatString = new DivElement();
	if(map["statusMessage"] == null)
	{
		userElement.text = map["username"] + ": ";
		userElement.style.color = getColor(map["username"]); //hashes the username so as to get a random color but the same each time for a specific user
		text.text = map["message"];
		text.className = "MessageBody";
		
		chatString.children
		..add(userElement)
		..add(text);
	}
	//TODO: remove after real usernames happen
	if(map["statusMessage"] == "hint")
	{
		text.text = map["message"];
		text.className = "MessageBody";
		
		chatString.children.add(text);
	}
	if(map["statusMessage"] == "changeName")
	{
		text.text = map["message"];
		text.className = "MessageBody";
		text.style.paddingRight = "4px";
		
		if(map["success"] == "true")
		{
			SpanElement oldUsername = new SpanElement()
			..text = map["username"]
			..style.color = getColor(map["username"])
			..style.paddingRight = "4px";
			SpanElement newUsername = new SpanElement()
				..text = map["newUsername"]
				..style.color = getColor(map["newUsername"]);
			
			chatString.children
			..add(oldUsername)
			..add(text)
			..add(newUsername);
			
			if(map["username"] == username) //although this message is broadcast to everyone, only change usernames if we were the one to type /setname
			{
				username = map["newUsername"];
				localStorage["username"] = username;
			}
		}
		else
		{
			chatString.children.add(text);
		}
	}
	//TODO: end remove
	
	chatHistory.children.add(chatString);
	chatHistory.scrollTop = chatHistory.scrollHeight;
}

String getColor(String username)
{
	int index = 0;
	for(int i=0; i<username.length; i++)
	{
		index += username.codeUnitAt(i);
	}
	return colors[index%(colors.length-1)];
}

String timeStamp() => new DateTime.now().toString().substring(11,16);