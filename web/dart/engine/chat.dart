part of coUclient;
//TODO: should we limit chat history so that it doesn't go on forever?

//TODO: make text wrapping work better
//TODO: make non-focused tab flash if message? or show counter?
//TODO: get list of people in chat
//TODO: allow names to have spaces? or give error message
//TODO: @ mentions - beep or blink or something?

class Chat
{
	bool _showJoinMessages = false;
	
	/**
	 * Determines if messages like "<user> has joined" are shown to the player.
	 * 
	 * Sets the visibility of join messages to [visible]
	 */
	void setJoinMessagesVisibility(bool visible)
	{
		_showJoinMessages = visible;
		localStorage["showJoinMessages"] = visible.toString();
	}
	
	/**
	 * Returns the visibility of messages like "<user> has joined"
	 */
	bool getJoinMessagesVisibility()
	{
		return _showJoinMessages;
	}
	
	init()
	{
		//handle chat settings menu
		Element chatMenu = querySelector("#ChatSettingsMenu");
		querySelector('#ChatSettingsIcon').onClick.listen((MouseEvent click)
		{
			if(chatMenu.hidden)
				chatMenu.hidden = false;
			else
				chatMenu.hidden = true;
		});
		
		//listen for onChange events so that clicking the label or the checkbox will call this method
		querySelectorAll('.ChatSettingsCheckbox').onChange.listen((Event event)
		{
			CheckboxInputElement checkbox = event.target as CheckboxInputElement;
			if(checkbox.id == "ShowJoinMessages")
				setJoinMessagesVisibility(checkbox.checked);
		});
	
		//setup saved variables
		if(localStorage["showJoinMessages"] != null)
		{
			//ugly because there is no method to parse bool from string in dart?
			if(localStorage["showJoinMessages"] == "true")
				setJoinMessagesVisibility(true);
			else
				setJoinMessagesVisibility(false);
			
			(querySelector("#ShowJoinMessages") as CheckboxInputElement).checked = getJoinMessagesVisibility();
		}
		
		addChatTab("Global Chat", true);
		addChatTab("Other Chat", false);
		querySelector("#ChatPane").children.add(new TabContent("Local Chat",true).getDiv());
	}
	
	void addChatTab(String channelName, bool checked)
	{
		DivElement content = new TabContent(channelName,false).getDiv()
			..className = "content";
		DivElement tab = new DivElement()
			..className = "tab";
		RadioButtonInputElement radioButton = new RadioButtonInputElement()
			..id = "tab-"+channelName
			..name = "tabgroup" //only allow one to be selected at a time
			..checked = checked;
		LabelElement label = new LabelElement()
			..attributes['for'] = "tab-"+channelName
			..text = channelName
			..style.cursor = "pointer";
		tab.children
			..add(radioButton)
			..add(label)
			..add(content);
		querySelector("#ChatTabs").children.add(tab);
	}
}

class TabContent
{
	List<String> _colors = ["aqua", "blue", "fuchsia", "gray", "green", "lime", "maroon", "navy", "olive", "orange", "purple", "red", "teal"];
	String _username = "testUser"; //TODO: get actual username of logged in user;
	String channelName;
	bool useSpanForTitle;
	WebSocket webSocket;
	final _chatServerUrl = "ws://couchatserver.herokuapp.com";
	
	TabContent(this.channelName, this.useSpanForTitle)
	{
		if(localStorage["username"] != null)
			_username = localStorage["username"];
		else
		{
			Random rand = new Random();
			_username += rand.nextInt(10000).toString();
		}
	}
	
	DivElement getDiv()
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
			_addmessage(chatHistory,map);
		}
		//TODO: end section
		
		setupWebSocket(chatHistory,channelName);
		
		input.onKeyUp.listen((key)
		{
	  		if (key.keyCode != 13) //listen for enter key
				return;
				
			if(input.value.trim().length == 0) //don't allow for blank messages
				return;
			
			Map map = new Map();
			if(input.value.split(" ")[0] == "/setname")
			{
				String prevName = _username;
				map["statusMessage"] = "changeName";
				map["username"] = prevName;
				map["newUsername"] = input.value.substring(9);
				map["channel"] = channelName;
			}
			else
			{
				map["username"] = _username;
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
	
	void setupWebSocket(DivElement chatHistory, String channelName)
	{
		webSocket = new WebSocket(_chatServerUrl);
		webSocket.onOpen.listen((_)
		{
			Map map = new Map();
			map["message"] = 'userName='+_username;
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
			
			if(!chat.getJoinMessagesVisibility() && map["message"] == " joined.") //ignore join messages unless the user turns them on
				return;
			
			if(map["channel"] == "all") //support for global messages (god mode messages)
			{
				_addmessage(chatHistory, map);
			}
			//if we're talking in local, only talk to one street at a time
			else if(map["channel"] == "Local Chat" && map["channel"] == channelName)
			{
				if(map["statusMessage"] != null)
					_addmessage(chatHistory, map);
				else if(map["street"] == CurrentStreet.label)
					_addmessage(chatHistory, map);
			}
			else if(map["channel"] == channelName)
				_addmessage(chatHistory, map);
		});
		webSocket.onClose.listen((_)
		{
			//attempt to reconnect and display a message to the user stating so
			Map map = new Map();
			map["statusMessage"] = "hint";
			map["message"] = "Disconnected from Chat, attempting to reconnect...";
			_addmessage(chatHistory,map);
			setupWebSocket(chatHistory,channelName);
		});
		webSocket.onError.listen((_)
		{
			//attempt to reconnect and display a message to the user stating so
			Map map = new Map();
			map["statusMessage"] = "hint";
			map["message"] = "[Error] The chat server appears to be offline";
			_addmessage(chatHistory,map);
		});
	}
	
	void _addmessage(DivElement chatHistory, Map map)
	{
		bool atTheBottom = (chatHistory.scrollTop == chatHistory.scrollHeight);
		print("got message: " + JSON.encode(map)); //debugging purposes only
		
		SpanElement userElement = new SpanElement();
		SpanElement text = new SpanElement()
			..setInnerHtml(_parseForUrls(map["message"]), 
			validator: new NodeValidatorBuilder()
	  			..allowHtml5()
	        	..allowElement('a', attributes: ['href','class'])
	    )
			..className = "MessageBody";
		DivElement chatString = new DivElement();
		if(map["statusMessage"] == null)
		{
			userElement.text = map["username"] + ": ";
			userElement.style.color = _getColor(map["username"]); //hashes the username so as to get a random color but the same each time for a specific user
			
			chatString.children
			..add(userElement)
			..add(text);
		}
		//TODO: remove after real usernames happen
		if(map["statusMessage"] == "hint")
		{
			chatString.children.add(text);
		}
		if(map["statusMessage"] == "changeName")
		{
			text.style.paddingRight = "4px";
			
			if(map["success"] == "true")
			{
				SpanElement oldUsername = new SpanElement()
				..text = map["username"]
				..style.color = _getColor(map["username"])
				..style.paddingRight = "4px";
				SpanElement newUsername = new SpanElement()
					..text = map["newUsername"]
					..style.color = _getColor(map["newUsername"]);
				
				chatString.children
				..add(oldUsername)
				..add(text)
				..add(newUsername);
				
				if(map["username"] == _username) //although this message is broadcast to everyone, only change usernames if we were the one to type /setname
				{
					_username = map["newUsername"];
					localStorage["username"] = _username;
				}
			}
			else
			{
				chatString.children.add(text);
			}
		}
		//TODO: end remove
		
		DivElement rowSpacer = new DivElement()
			..className = "RowSpacer";
		chatString.style.paddingRight = "2px";
		
		chatHistory.children.add(chatString);
		chatHistory.children.add(rowSpacer);
		chatHistory.scrollTop = chatHistory.scrollHeight;
	}
	
	String _parseForUrls(String message)
	{
		/*
		(https?:\/\/)?                    : the http or https schemes (optional)
		[\w-]+(\.[\w-]+)+\.?              : domain name with at least two components;
		                                    allows a trailing dot
		(:\d+)?                           : the port (optional)
		(\/\S*)?                          : the path (optional)
		*/
		String regexString = r"((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)"; 
		//the r before the string makes dart interpret it as a raw string so that you don't have to escape characters like \
		
		String returnString = "";
		RegExp regex = new RegExp(regexString);
		message.splitMapJoin(regex, 
		onMatch: (Match m)
		{
			String url = m[0];
			if(!url.contains("http://"))
				url = "http://" + url;
			returnString += '<a href="${url}" target="_blank" class="MessageLink">${m[0]}</a>';
		},
		onNonMatch: (String s) => returnString += s);
		
		return returnString;
	}
	
	String _getColor(String username)
	{
		int index = 0;
		for(int i=0; i<username.length; i++)
		{
			index += username.codeUnitAt(i);
		}
		return _colors[index%(_colors.length-1)];
	}
	
	String _timeStamp() => new DateTime.now().toString().substring(11,16);
}