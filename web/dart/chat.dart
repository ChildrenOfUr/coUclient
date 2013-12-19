part of coUclient;

List<String> colors = ["aqua", "blue", "fuchsia", "gray", "green", "lime", "maroon", "navy", "olive", "orange", "purple", "red", "teal"];
String username = "testUser"; //TODO: get actual username of logged in user;

handleChat()
{
	addChatTab("Global Chat", true);
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
	
	input.onChange.listen((_)
	{
		Map map = new Map();
		if(input.value.split(" ")[0] == "/setname")
		{
			String prevName = username;
			username = input.value.split(" ")[1];
			map["statusMessage"] = "changeName";
			map["message"] = "is now known as";
			map["username"] = prevName;
			map["newUsername"] = username;
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
	SpanElement username = new SpanElement();
	SpanElement text = new SpanElement();
	DivElement chatString = new DivElement();
	if(map["statusMessage"] == null)
	{
		username.text = map["username"] + ": ";
		username.style.color = getColor(map["username"]); //hashes the username so as to get a random color but the same each time for a specific user
		text.text = map["message"];
		text.className = "MessageBody";
		
		chatString.children
		..add(username)
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
		SpanElement oldUsername = new SpanElement()
			..text = map["username"]
			..style.color = getColor(map["username"])
			..style.paddingRight = "4px";
		SpanElement newUsername = new SpanElement()
			..text = map["newUsername"]
			..style.color = getColor(map["newUsername"]);
		text.text = map["message"];
		text.className = "MessageBody";
		text.style.paddingRight = "4px";
		
		chatString.children
		..add(oldUsername)
		..add(text)
		..add(newUsername);
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