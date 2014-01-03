part of coUclient;

class Chat
{
	bool _showJoinMessages = false, _playMentionSound = true;
	Map<String, TabContent> tabContentMap = new Map();
	
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
	bool getJoinMessagesVisibility() => _showJoinMessages;
	
	void setPlayMentionSound(bool enabled)
	{
		_playMentionSound = enabled;
		localStorage["playMentionSound"] = enabled.toString();
	}
	
	bool getPlayMentionSound() => _playMentionSound;
	
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
			if(checkbox.id == "PlayMentionSound")
				setPlayMentionSound(checkbox.checked);
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
		if(localStorage["playMentionSound"] != null)
		{
			if(localStorage["playMentionSound"] == "true")
				setPlayMentionSound(true);
			else
				setPlayMentionSound(false);
			
			(querySelector("#PlayMentionSound") as CheckboxInputElement).checked = getPlayMentionSound();
		}
		
		addChatTab("Global Chat", true);
		addChatTab("Other Chat", false);
		querySelector("#ChatPane").children.add(new TabContent("Local Chat",true).getDiv());
	}
	
	void addChatTab(String channelName, bool checked)
	{
		TabContent tabContent = new TabContent(channelName,false);
		DivElement content = tabContent.getDiv()
			..className = "content";
		DivElement tab = new DivElement()
			..className = "tab";
		RadioButtonInputElement radioButton = new RadioButtonInputElement()
			..id = "tab-"+channelName.replaceAll(" ", "_")
			..name = "tabgroup" //only allow one to be selected at a time
			..checked = checked
			..onClick.listen(tabContent.resetMessages);
		LabelElement label = new LabelElement()
			..attributes['for'] = "tab-"+channelName.replaceAll(" ", "_")
			..id = "label-"+channelName.replaceAll(" ", "_")
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
	static List<String> _COLORS = ["aqua", "blue", "fuchsia", "gray", "green", "lime", "maroon", "navy", "olive", "orange", "purple", "red", "teal"];
	List<String> connectedUsers = new List();
	String _username = "testUser"; //TODO: get actual username of logged in user;
	String channelName, lastWord = "";
	bool useSpanForTitle, tabInserted = false;
	WebSocket webSocket;
	DivElement chatDiv, chatHistory;
	int unreadMessages = 0, tabSearchIndex = 0, numMessages = 0;
	final _chatServerUrl = "ws://couchatserver.herokuapp.com";
	
	TabContent(this.channelName, this.useSpanForTitle)
	{
		chat.tabContentMap[channelName] = this;
		
		if(localStorage["username"] != null)
			_username = localStorage["username"];
		else
		{
			Random rand = new Random();
			_username += rand.nextInt(10000).toString();
		}
		
		//for mobile chat
		DivElement conversationStack = querySelector("#ConversationStack");
		DivElement conversation = new DivElement()
			..className = "Conversation"
			..id = "conversation-"+channelName.replaceAll(" ", "_");
		conversationStack.children.add(conversation);
		
		DivElement channelList = querySelector("#ChannelList");
		DivElement channel = new DivElement()
			..className = "ChannelName"
			..text = channelName;
		channelList.children.add(channel);
	}
	
	void resetMessages(MouseEvent event)
	{
		unreadMessages = 0;
		String selector = "#label-"+channelName.replaceAll(" ", "_");
		querySelector(selector).text = channelName;
	}
	
	DivElement getDiv()
	{
		chatDiv = new DivElement()
			..className = "ChatWindow";
		SpanElement span = new SpanElement()
			..text = channelName;
		chatHistory = new DivElement()
			..className = "ChatHistory";
		TextInputElement input = new TextInputElement()
			..classes.add("ChatInput")
			..classes.add("Typing");
	
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
			map["message"] = "Hint :\nYou can set your chat name by typing '/setname [name]'<br><br>You can get a list of people in this chat room by typing '/list'";
			_addmessage(map);
		}
		//TODO: end section
		
		setupWebSocket(chatHistory,channelName);
		
		processInput(input);
		
		return chatDiv;
	}
	
	void processInput(TextInputElement input, [DivElement sendButton])
	{
		input.onKeyDown.listen((KeyboardEvent key) //onKeyUp seems to be too late to prevent TAB's default behavior
		{
			if(key.keyCode == 9) //tab key, try to complete a user's name
			{
				key.preventDefault();
				int startIndex = input.value.lastIndexOf(" ") == -1 ? 0 : input.value.lastIndexOf(" ")+1;
				if(!tabInserted)
					lastWord = input.value.substring(startIndex);
				for(; tabSearchIndex < connectedUsers.length; tabSearchIndex++)
				{
					String username = connectedUsers.elementAt(tabSearchIndex);
					if(username.toLowerCase().startsWith(lastWord.toLowerCase()))
					{
						input.value = input.value.substring(0, input.value.lastIndexOf(" ")+1) + username;
						tabInserted = true;
						tabSearchIndex++;
						break;
					}
				}
				//if we didn't find it yet and the tabSearchIndex was not 0, let's look at the beginning of the array as well
				//otherwise the user will have to press the tab key again
				if(!tabInserted)
				{
					for(int index = 0; index < tabSearchIndex; index++)
					{
						String username = connectedUsers.elementAt(index);
						if(username.toLowerCase().startsWith(lastWord.toLowerCase()))
						{
							input.value = input.value.substring(0, input.value.lastIndexOf(" ")+1) + username;
							tabInserted = true;
							tabSearchIndex = index + 1;
							break;
						}
					}
				}
				
				if(tabSearchIndex == connectedUsers.length) //wrap around for next time
				tabSearchIndex = 0;
				
				return;
			}
		});
		
		input.onKeyUp.listen((KeyboardEvent key)
		{
			if(key.keyCode != 9)
				tabInserted = false;
			
			if (key.keyCode != 13) //listen for enter key
				return;
			
			if(input.value.trim().length == 0) //don't allow for blank messages
				return;
			
			parseInput(input.value);
			input.value = '';
		});
		
		if(sendButton != null)
		{
			sendButton.onClick.listen((_)
			{
				if(input.value.trim().length == 0) //don't allow for blank messages
					return;
				
				parseInput(input.value);
				input.value = '';
			});
		}
	}
	
	Map parseInput(String input)
	{
		Map map = new Map();
		if(input.split(" ")[0] == "/setname")
		{
			map["statusMessage"] = "changeName";
			map["username"] = _username;
			map["newUsername"] = input.substring(9);
			map["channel"] = channelName;
		}
		else if(input == "/list")
		{
			map["username"] = _username;
			map["statusMessage"] = "list";
			map["channel"] = channelName;
		}
		else
		{
			map["username"] = _username;
			map["message"] = input;
			map["channel"] = channelName;
			if(channelName == "Local Chat")
				map["street"] = CurrentStreet.label;
			_addmessage(map);
		}
		
		webSocket.send(JSON.encode(map));
	}
	
	void setupWebSocket(DivElement chatHistory, String channelName)
	{
		webSocket = new WebSocket(_chatServerUrl);
		webSocket.onOpen.listen((_)
		{
			querySelector("#ChatDisconnected").hidden = true; //hide if visible
		
			//let server know that we connected
			Map map = new Map();
			map["message"] = 'userName='+_username;
			map["channel"] = channelName;
			if(channelName == "Local Chat")
				map["street"] = CurrentStreet.label;
			webSocket.send(JSON.encode(map));
			
			//get list of all users connected
			map = new Map();
			map["hide"] = "true";
			map["username"] = _username;
			map["statusMessage"] = "list";
			map["channel"] = channelName;
			webSocket.send(JSON.encode(map));
		});
		webSocket.onMessage.listen((MessageEvent messageEvent)
		{
			Map map = JSON.decode(messageEvent.data);
			if(map["message"] == "ping") //only used to keep the connection alive, ignore
				return;
			
			if(map["message"] == " joined.")
			{
				if(!connectedUsers.contains(map["username"]))
					connectedUsers.add(map["username"]);
				if(!chat.getJoinMessagesVisibility()) //ignore join messages unless the user turns them on
					return;
			}
			
			if(map["message"] == " left.")
			{
				connectedUsers.remove(map["username"]);
				if(!chat.getJoinMessagesVisibility()) //ignore left messages unless the user turns them on
					return;
			}
			
			if(map["channel"] == "all")
			{
				_addmessage(map);
			}
			//if we're talking in local, only talk to one street at a time
			else if(map["channel"] == "Local Chat" && map["channel"] == channelName)
			{
				if(map["statusMessage"] != null)
					_addmessage(map);
				else if(map["username"] != _username && map["street"] == CurrentStreet.label)
					_addmessage(map);
			}
			else if(map["channel"] == channelName)
			{
				if(map["statusMessage"] == null)
				{
					String selector = "#tab-"+channelName.replaceAll(" ", "_"); //need to replace spaces to make CSS selector work
					RadioButtonInputElement tab = (querySelector("#tab-"+channelName) as RadioButtonInputElement);
					if(!(querySelector(selector) as RadioButtonInputElement).checked)
					{
						unreadMessages++;
						//find label related to this channel's tab and add the unread count to it
						String selector = "#label-"+channelName.replaceAll(" ", "_");
						querySelector(selector).innerHtml = '<span class="Counter">'+unreadMessages.toString()+'</span>' + " " + channelName;
					}
					if(map["username"] != _username)
						_addmessage(map);
				}
				else
					_addmessage(map);
			}
		});
		webSocket.onClose.listen((_)
		{
			//attempt to reconnect and display a message to the user stating so
			querySelector("#ChatDisconnected")
				..hidden = false
				..text = "Disconnected from Chat, attempting to reconnect...";
			new Timer(new Duration(seconds:5),() //wait 5 seconds and try to reconnect
			{
				setupWebSocket(chatHistory,channelName);
			});
		});
	}
	
	void _addmessage(Map map)
	{
		NodeValidator validator = new NodeValidatorBuilder()
  			..allowHtml5()
        	..allowElement('a', attributes: ['href','class',])
			..allowElement('span');
		
		numMessages++;
		if(numMessages > 100) //limit chat history (each pane is seperate) to 100 messages
		{
			chatHistory.children.removeAt(0);
			if(chatHistory.children.first.className == "RowSpacer") //if the top is a row spacer, remove that too
				chatHistory.children.removeAt(0);
		}
		
		bool atTheBottom = (chatHistory.scrollTop == chatHistory.scrollHeight);
		
		if(chat.getPlayMentionSound() && map["message"].toLowerCase().contains(_username.toLowerCase()) && int.parse(prevVolume) > 0 && isMuted == '0')
		{
			AudioElement mentionSound = new AudioElement('./assets/system/mention.ogg');
		    mentionSound.volume = int.parse(prevVolume)/100;
		    mentionSound.play();
		}
		SpanElement userElement = new SpanElement();
		SpanElement text = new SpanElement()
			..setInnerHtml(_parseForUrls(map["message"]), validator:validator)
			..className = "MessageBody";
		DivElement chatString = new DivElement();
		if(map["statusMessage"] == null || map["message"] == " joined.")
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
				
				connectedUsers.remove(map["username"]);
				connectedUsers.add(map["newUsername"]);
			}
			else
			{
				chatString.children.add(text);
			}
		}
		//TODO: end remove
		if(map["statusMessage"] == "list")
		{
			if(map["hide"] == "true") //for filling user list, do not show
			{
				connectedUsers = map["users"];
				return;
			}
			
			text.style.paddingRight = "4px";
			chatString.children.add(text);
			
			List users = map["users"];
			users.forEach((String username)
			{
				SpanElement user = new SpanElement()
				..text = username
				..style.color = _getColor(username)
				..style.paddingRight = "4px"
				..style.display = "inline-block";
				chatString.children.add(user);
			});
		}
		
		DivElement rowSpacer = new DivElement()
			..className = "RowSpacer";
		chatString.style.paddingRight = "2px";
		
		chatHistory.children.add(chatString);
		chatHistory.children.add(rowSpacer);
		chatHistory.scrollTop = chatHistory.scrollHeight;
		
		//for mobile version
		DivElement chatLine = new DivElement()
			..className = "bubble"
			..setInnerHtml(chatString.innerHtml, treeSanitizer: new NullTreeSanitizer());
		
		if(chatString.text.startsWith(_username))
			chatLine.classes.add("me");
		else
			chatLine.classes.add("you");
		
		DivElement chatRow = new DivElement()
			..className = "bubbleRow";
		chatRow.children.add(chatLine);
		
		querySelector('#conversation-'+channelName.replaceAll(" ","_")).children.add(chatRow);
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
		return _COLORS[index%(_COLORS.length-1)];
	}
	
	String _timeStamp() => new DateTime.now().toString().substring(11,16);
}

class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(node) {}
}