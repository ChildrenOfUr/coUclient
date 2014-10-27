part of coUclient;

class Chat
{
	static List<String> _COLORS = ["#e85d72","#e06b56","#9d8eee","#a63924","#43761b","#4bbe2e","#d58247","#d55aef","#9b3b45","#4cc091"];
    static List<String> _EMOTICONS = [];
	bool _showJoinMessages = false, _playMentionSound = true;
	Map<String, TabContent> tabContentMap = new Map();
	String username = "testUser"; //TODO: get actual username of logged in user;
	final _chatServerUrl = "ws://$websocketServerAddress/chat";

	List<String> get EMOTICONS => _EMOTICONS;
	List<String> get COLORS => _COLORS;

	/**
	 * Determines if messages like "<user> has joined" are shown to the player.
	 *
	 * Sets the visibility of join messages to [visible]
	 */
	void setJoinMessagesVisibility(bool visible) {
		_showJoinMessages = visible;
		localStorage["showJoinMessages"] = visible.toString();
	}

	/**
	 * Returns the visibility of messages like "<user> has joined"
	 */
	bool getJoinMessagesVisibility() => _showJoinMessages;

	void setPlayMentionSound(bool enabled) {
		_playMentionSound = enabled;
		localStorage["playMentionSound"] = enabled.toString();
	}

	bool getPlayMentionSound() => _playMentionSound;

	init() {
		//load emoticons
		new Asset("assets/emoticons/emoticons.json").load().then((Asset asset) => _EMOTICONS = asset.get()["names"]);

		//assign temporary chat handle
		if (localStorage["username"] != null) username = localStorage["username"]; else {
			Random rand = new Random();
			username += rand.nextInt(10000).toString();
		}

		//TODO: change this when usernames are real
		setName(username);

		//listen for onChange events so that clicking the label or the checkbox will call this method
		querySelectorAll('.ChatSettingsCheckbox').onChange.listen((Event event) {
			CheckboxInputElement checkbox = event.target as CheckboxInputElement;
			if (checkbox.id == "ShowJoinMessages") setJoinMessagesVisibility(checkbox.checked);
			if (checkbox.id == "PlayMentionSound") setPlayMentionSound(checkbox.checked);
		});

		//setup saved variables
		if (localStorage["showJoinMessages"] != null) {
			//ugly because there is no method to parse bool from string in dart?
			if (localStorage["showJoinMessages"] == "true") setJoinMessagesVisibility(true); else setJoinMessagesVisibility(false);
		} else {
			localStorage["showJoinMessages"] = "false";
			setJoinMessagesVisibility(false);
		}
		querySelectorAll("#ShowJoinMessages").forEach((Element element) {
			(element as CheckboxInputElement).checked = getJoinMessagesVisibility();
		});

		if (localStorage["playMentionSound"] != null) {
			if (localStorage["playMentionSound"] == "true") setPlayMentionSound(true); else setPlayMentionSound(false);
		} else {
			localStorage["playMentionSound"] = "true";
			setJoinMessagesVisibility(true);
		}
		querySelectorAll("#PlayMentionSound").forEach((Element element) {
			(element as CheckboxInputElement).checked = getPlayMentionSound();
		});

		TabContent globalContent = addChatTab("Global Chat", true);
		TabContent otherContent = addChatTab("Other Chat", false);
		TabContent localContent = new TabContent("Local Chat", true);
		querySelector("#ChatPane").children.add(localContent.getDiv());

		WebSocket webSocket = setupWebSocket();
		globalContent.webSocket = webSocket;
		otherContent.webSocket = webSocket;
		localContent.webSocket = webSocket;

		//add touch scrolling to the channel list
		new TouchScroller(querySelector("#ChannelList"), TouchScroller.VERTICAL);
	}

	TabContent addChatTab(String channelName, bool checked) {
		TabContent tabContent = new TabContent(channelName, false);
		DivElement content = tabContent.getDiv()..className = "content";
		DivElement tab = new DivElement()..className = "tab";
		RadioButtonInputElement radioButton = new RadioButtonInputElement()
				..id = "tab-" + channelName.replaceAll(" ", "_")
				..name = "tabgroup" //only allow one to be selected at a time
				..checked = checked
				..onClick.listen(tabContent.resetMessages);
		LabelElement label = new LabelElement()
				..className = "tabLabel"
				..attributes['for'] = "tab-" + channelName.replaceAll(" ", "_")
				..id = "label-" + channelName.replaceAll(" ", "_")
				..text = channelName
				..style.cursor = "pointer";
		tab.children
				..add(radioButton)
				..add(label)
				..add(content);
		querySelector("#ChatTabs").children.add(tab);

		return tabContent;
	}

	WebSocket setupWebSocket()
	{
		WebSocket webSocket = new WebSocket(_chatServerUrl);
		webSocket.onOpen.listen((_) {
			webSocket.send(JSON.encode({
				'clientVersion': clientVersion
			}));
			querySelector("#ChatDisconnected").hidden = true; //hide if visible
			querySelector("#ChatBubbleDisconnect").style.display = "none";
			querySelector("#ChatBubbleText")
					..text = "0"
					..hidden = false;

			//let server know that we connected
			Map map = new Map();
			map["username"] = chat.username;
			map["statusMessage"] = "join";
			map["street"] = currentStreet.label;
			map['channel'] = "Global Chat";
			webSocket.send(JSON.encode(map));

			//get list of all users connected
			map = new Map();
			map["hide"] = "true";
			map["username"] = chat.username;
			map["statusMessage"] = "list";
			map["channel"] = "Global Chat";
			webSocket.send(JSON.encode(map));
		});
		webSocket.onMessage.listen((MessageEvent messageEvent) {
			Map map = JSON.decode(messageEvent.data);
			if(map['channel'] != null)
			{
				if(map['channel'] == 'all')
					tabContentMap.forEach((String key, TabContent content) =>
							content.receiveMessage(map));
				else
					tabContentMap[map['channel']].receiveMessage(map);
			}
			else
				print('channel was null for $map');
		});
		webSocket.onClose.listen((CloseEvent event) {
			if (!reconnect) {
				reconnect = true;
				return;
			}

			//attempt to reconnect and display a message to the user stating so
			querySelector("#ChatDisconnected")
					..hidden = false
					..text = "Disconnected from Chat, attempting to reconnect...";
			//mobile
			querySelector("#ChatBubbleDisconnect").style.display = "inline-block";
			querySelector("#ChatBubbleText").hidden = true;

			//wait 5 seconds and try to reconnect
			new Timer(new Duration(seconds: 5), () {
				webSocket = setupWebSocket();
				tabContentMap.forEach((String tabName, TabContent value) => value.webSocket = webSocket);
			});
		});

		return webSocket;
	}
}

class TabContent {
	List<String> connectedUsers = new List();
	List<String> inputHistory = new List();
	String channelName,
			lastWord = "";
	bool useSpanForTitle,
			tabInserted = false;
	WebSocket webSocket;
	DivElement chatDiv, chatHistory;
	int unreadMessages = 0,
			tabSearchIndex = 0,
			numMessages = 0,
			inputHistoryPointer = 0,
			emoticonPointer = 0;

	TabContent(this.channelName, this.useSpanForTitle) {
		chat.tabContentMap[channelName] = this;

		//for mobile chat
		DivElement conversationStack = querySelector("#ConversationStack");
		DivElement conversation = new DivElement()
				..className = "Conversation"
				..id = "conversation-" + channelName.replaceAll(" ", "_");
		new TouchScroller(conversation, TouchScroller.VERTICAL);
		conversationStack.children.add(conversation);

		DivElement channelList = querySelector("#ChannelList");
		DivElement channel = new DivElement()
				..className = "ChannelName"
				..text = channelName
				..id = "channelName-" + channelName.replaceAll(" ", "_");
		channelList.children.add(channel);
	}

	void receiveMessage(Map map)
	{
		if (map['error'] != null)
		{
			reconnect = false;
			print(map['error']);
			webSocket.close();
			return;
		}

		if (map["statusMessage"] == "ping") //used to keep the connection alive
		{
			webSocket.send(JSON.encode({'statusMessage':'pong'}));
			return;
		}

		if (map["message"] == " joined.")
		{
			if (!connectedUsers.contains(map["username"])) connectedUsers.add(map["username"]);
			if (!chat.getJoinMessagesVisibility()) //ignore join messages unless the user turns them on
			return;
		}

		if (map["message"] == " left.") {
			connectedUsers.remove(map["username"]);
			removeOtherPlayer(map["username"]);
			if (!chat.getJoinMessagesVisibility()) //ignore left messages unless the user turns them on
			return;
		}

		int prevUnread = unreadMessages;
		if (map["statusMessage"] == null && map["channel"] == channelName) unreadMessages++;

		//mobile
		if (map["username"] != chat.username && map["channel"] == channelName) {
			//if the conversation is not showing to the user, add an unread message to it
			if (querySelector("#conversation-" + channelName.replaceAll(" ", "_")).style.zIndex != "1") {
				if (prevUnread != unreadMessages) querySelector("#channelName-" + channelName.replaceAll(" ", "_")).innerHtml = channelName + " " + '<span class="Counter">' + unreadMessages.toString() + '</span>';
			} else unreadMessages--; //if it is showing, this is a read message, un-increment counter

			int totalUnread = 0;
			chat.tabContentMap.values.forEach((TabContent tabContent) {
				totalUnread += tabContent.unreadMessages;
			});
			querySelector('#ChatBubbleText').text = totalUnread.toString();
		}

		if (map["channel"] == "all") {
			_addmessage(map);
		} //if we're talking in local, only talk to one street at a time
		else if (map["channel"] == "Local Chat" && map["channel"] == channelName) {
			if (map["statusMessage"] != null) _addmessage(map); else if (map["username"] != chat.username && map["street"] == currentStreet.label) _addmessage(map);
		} else if (map["channel"] == channelName) {
			if (map["statusMessage"] == null) {
				//need to replace spaces to make CSS selector work
				String selector = "#tab-" + channelName.replaceAll(" ", "_");
				if (!(querySelector(selector) as RadioButtonInputElement).checked) {
					if (prevUnread != unreadMessages) {
						//find label related to this channel's tab and add the unread count to it
						String selector = "#label-" + channelName.replaceAll(" ", "_");
						querySelector(selector).innerHtml = '<span class="Counter">' + unreadMessages.toString() + '</span>' + " " + channelName;
					}
				}

				//don't add to history if the user said it
				//we already added it before we sent it to the server
				if (map["username"] != chat.username) _addmessage(map);
			} else _addmessage(map);
		}
	}

	void resetMessages([MouseEvent event]) {
		unreadMessages = 0;

		//mobile chat titles
		String selector = "#channelName-" + channelName.replaceAll(" ", "_");
		querySelector(selector).text = channelName;

		//desktop chat tab labels
		if (channelName != "Local Chat") //there is no counter for local chat on desktop
		{
			selector = "#label-" + channelName.replaceAll(" ", "_");
			querySelector(selector).text = channelName;
		}

		int totalUnread = 0;
		chat.tabContentMap.values.forEach((TabContent tabContent) {
			totalUnread += tabContent.unreadMessages;
		});
		querySelector('#ChatBubbleText').text = totalUnread.toString();
	}

	DivElement getDiv() {
		chatDiv = new DivElement()..className = "ChatWindow";
		SpanElement span = new SpanElement()..text = channelName;
		chatHistory = new DivElement()..className = "ChatHistory";
		TextInputElement input = new TextInputElement()
				..classes.add("ChatInput")
				..classes.add("Typing");

		if (useSpanForTitle) chatDiv.children.add(span);
		chatDiv.children
				..add(chatHistory)
				..add(input);

		//TODO: remove this section when usernames are for real
		if (channelName == "Local Chat") {
			Map map = new Map();
			map["statusMessage"] = "hint";
			map["message"] = 'For chat command help, click here: http://childrenofur.com/help/#commands';
			_addmessage(map);
		}
		//TODO: end section

		processInput(input);

		return chatDiv;
	}

	void processInput(TextInputElement input) {
		input.onKeyDown.listen((KeyboardEvent key) //onKeyUp seems to be too late to prevent TAB's default behavior
		{
			if (key.keyCode == 38 && inputHistoryPointer < inputHistory.length) //pressed up arrow
			{
				input.value = inputHistory.elementAt(inputHistoryPointer);
				if (inputHistoryPointer < inputHistory.length - 1) inputHistoryPointer++;
			}
			if (key.keyCode == 40) //pressed down arrow
			{
				if (inputHistoryPointer > 0) {
					inputHistoryPointer--;
					input.value = inputHistory.elementAt(inputHistoryPointer);
				} else input.value = "";
			}
			if (key.keyCode == 9) //tab key, try to complete a user's name or an emoticon
			{
				key.preventDefault();

				if (input.value.endsWith(":")) //look for an emoticon instead of a username
				{
					String value = input.value;
					if (value.length > 1 && value.substring(value.lastIndexOf(":") - 1).startsWith(" :") || value.length == 1 && value.startsWith(":")) //start of new emoticon
					{
						input.value = value.substring(0, value.lastIndexOf(":") + 1) + chat.EMOTICONS.elementAt(emoticonPointer) + ":";
						emoticonPointer++;
						if (emoticonPointer == chat.EMOTICONS.length) emoticonPointer = 0;
					} else if (value.length > 1 && !value.substring(value.lastIndexOf(":") - 1).startsWith(" :")) //change existing emoticon choice
					{
						int lastColon = value.lastIndexOf(":"),
								count = 0;
						bool setNext = false;
						while (count < chat.EMOTICONS.length * 2) {
							String name = chat.EMOTICONS.elementAt(count % chat.EMOTICONS.length);
							if (setNext) {
								input.value = value.substring(0, lastColon - chat.EMOTICONS.elementAt(emoticonPointer).length) + name + ":";
								emoticonPointer++;
								if (emoticonPointer == chat.EMOTICONS.length) emoticonPointer = 0;
								break;
							}

							if (value.substring(lastColon - name.length, lastColon) != -1 && value.substring(lastColon - name.length, lastColon) == name) {
								setNext = true;
								emoticonPointer = count % chat.EMOTICONS.length;
							}
							count++;
						}
					}

					return;
				}

				int startIndex = input.value.lastIndexOf(" ") == -1 ? 0 : input.value.lastIndexOf(" ") + 1;
				for (int i = 0; i < connectedUsers.length; i++) {
					String name = connectedUsers.elementAt(i);
					if (input.value.endsWith(name)) {
						input.value = input.value.substring(0, input.value.lastIndexOf(name));
						break;
					}
				}
				if (!tabInserted) lastWord = input.value.substring(startIndex);
				for ( ; tabSearchIndex < connectedUsers.length; tabSearchIndex++) {
					String username = connectedUsers.elementAt(tabSearchIndex);
					if (username.toLowerCase().startsWith(lastWord.toLowerCase())) {
						input.value = input.value.substring(0, input.value.lastIndexOf(" ") + 1) + username;
						tabInserted = true;
						tabSearchIndex++;
						break;
					}
				}
				//if we didn't find it yet and the tabSearchIndex was not 0, let's look at the beginning of the array as well
				//otherwise the user will have to press the tab key again
				if (!tabInserted) {
					for (int index = 0; index < tabSearchIndex; index++) {
						String username = connectedUsers.elementAt(index);
						if (username.toLowerCase().startsWith(lastWord.toLowerCase())) {
							input.value = input.value.substring(0, input.value.lastIndexOf(" ") + 1) + username;
							tabInserted = true;
							tabSearchIndex = index + 1;
							break;
						}
					}
				}

				if (tabSearchIndex == connectedUsers.length) //wrap around for next time
				tabSearchIndex = 0;

				return;
			}
		});

		input.onKeyUp.listen((KeyboardEvent key) {
			if (key.keyCode != 9) tabInserted = false;

			if (key.keyCode != 13) //listen for enter key
			return;

			if (input.value.trim().length == 0) //don't allow for blank messages
			return;

			parseInput(input.value);

			inputHistory.insert(0, input.value); //add to beginning of list
			inputHistoryPointer = 0; //point to beginning of list
			if (inputHistory.length > 50) //don't allow the list to grow forever
			inputHistory.removeLast();

			input.value = '';
		});
	}

	parseInput(String input) {
		Map map = new Map();
		if (input.split(" ")[0].toLowerCase() == "/setname") {
			map["statusMessage"] = "changeName";
			map["username"] = chat.username;
			map["newUsername"] = input.substring(9);
			map["channel"] = channelName;
		} else if (input.toLowerCase() == "/list") {
			map["username"] = chat.username;
			map["statusMessage"] = "list";
			map["channel"] = channelName;
			map["street"] = currentStreet.label;
		} else if (input.split(" ")[0].toLowerCase() == "/setlocation" || input.split(" ")[0].toLowerCase() == "/go") {
			setLocation(input.split(" ")[1]);
			return;
		} else {
			map["username"] = chat.username;
			map["message"] = input;
			map["channel"] = channelName;
			if (channelName == "Local Chat") map["street"] = currentStreet.label;
			_addmessage(map);
		}

		webSocket.send(JSON.encode(map));
	}

	void _addmessage(Map map) {
		bool chatFail;
		String message = (map["message"] as String);
		int messageLength = message.length;
		if (channelName == "Local Chat" && messageLength > 139) {
			print("Local chat message too long! Max 140 chars, " + messageLength.toString() + " chars used. Here's your message, in case you want to try again with a shorter version.");
			chatFail = true;
		} else if (channelName == "Global Chat" && messageLength > 279) {
			print("Global chat message too long! Max 280 chars, " + messageLength.toString() + " chars used. Here's your message, in case you want to try again with a shorter version.");
			chatFail = true;
		} else {
			chatFail = false;
		}

		if (!chatFail) {
			NodeValidator validator = new NodeValidatorBuilder()
					..allowHtml5()
					..allowElement('a', attributes: ['href', 'class',])
					..allowElement('span');

			numMessages++;
			if (numMessages > 100) //limit chat history (each pane is seperate) to 100 messages
			{
				chatHistory.children.removeAt(0);
				if (chatHistory.children.first.className == "RowSpacer") //if the top is a row spacer, remove that too
				chatHistory.children.removeAt(0);

				//mobile
				DivElement conversation = querySelector('#conversation-' + channelName.replaceAll(" ", "_"));
				conversation.children.removeAt(0);

				numMessages--;
			}

			if (chat.getPlayMentionSound() && map["message"].toLowerCase().contains(chat.username.toLowerCase()) && int.parse(prevVolume) > 0 && isMuted == '0') {
				playSound('mention');
			}
			SpanElement userElement = new SpanElement();
			SpanElement text = new SpanElement()
					..setInnerHtml(_parseForEmoticons(_parseForUrls(map["message"])), validator: validator)
					..classes.add("MessageBody");
			DivElement chatString = new DivElement();
			if (map["statusMessage"] == null || map["message"] == " joined.") {
				if (map["username"] != null && !(map["message"] as String).toLowerCase().startsWith("/me")) {
					userElement.text = map["username"] + ": ";
					userElement.style.color = getUsernameColor(map["username"]); //hashes the username so as to get a random color but the same each time for a specific user

					chatString.children
							..add(userElement)
							..add(text);
				}
				if ((map["message"] as String).toLowerCase().startsWith("/me")) {
					String message = (map["message"] as String).replaceFirst(new RegExp("\/me", caseSensitive: false), "");
					text.setInnerHtml("<i>" + map["username"] + " " + message + "</i>");
					chatString.children.add(text);
				}
			}
			if (map["statusMessage"] == "leftStreet") {
				//display "user has left for <street>" message with clickable street
				userElement.text = map["username"];
				userElement.style.color = getUsernameColor(map["username"]);

				AnchorElement streetElement = new AnchorElement()
						..text = map["streetName"]
						..className = "ClickableStreetLink"
						..onClick.listen((_) {
							setLocation(map["tsid"]);
						});
				chatString.children
						..add(userElement)
						..add(text)
						..add(streetElement);

				removeOtherPlayer(map["username"]);
			}
			//TODO: remove after real usernames happen
			if (map["statusMessage"] == "hint") {
				chatString.children.add(text);
			}
			if (map["statusMessage"] == "changeName") {
				text.style.paddingRight = "4px";

				if (map["success"] == "true") {
					SpanElement oldUsername = new SpanElement()
							..text = map["username"]
							..style.color = getUsernameColor(map["username"])
							..style.paddingRight = "4px";
					SpanElement newUsername = new SpanElement()
							..text = map["newUsername"]
							..style.color = getUsernameColor(map["newUsername"]);

					chatString.children
							..add(oldUsername)
							..add(text)
							..add(newUsername);

					if (map["username"] == chat.username) //although this message is broadcast to everyone, only change usernames if we were the one to type /setname
					{
						chat.username = map["newUsername"];
						localStorage["username"] = chat.username;

						//set name in upper left and above avatar
						CurrentPlayer.playerName.text = map["newUsername"];
						setName(map["newUsername"]);

						CurrentPlayer.username = map['newUsername'];
						CurrentPlayer.loadAnimations();

						//clear our inventory so we can get the new one
						querySelectorAll('.InventoryBox').forEach((Element box) => box.children.clear());
						firstConnect = true;
						joined = "";
						sendJoinedMessage(currentStreet.label);

						//warn multiplayer server that it will receive messages from a new name but it should be the same person
						map['street'] = currentStreet.label;
						playerSocket.send(JSON.encode(map));

						timeLast = 5.0;
					}

					connectedUsers.remove(map["username"]);
					connectedUsers.add(map["newUsername"]);
				} else {
					chatString.children.add(text);
				}
			}
			//TODO: end remove
			if (map["statusMessage"] == "list") {
				if (map["hide"] == "true") //for filling user list, do not show
				{
					connectedUsers = map["users"];
					return;
				}

				text.style.paddingRight = "4px";
				chatString.children.add(text);

				List users = map["users"];
				users.forEach((String username) {
					SpanElement user = new SpanElement()
							..text = username
							..style.color = getUsernameColor(username)
							..style.paddingRight = "4px"
							..style.display = "inline-block";
					chatString.children.add(user);
				});
			}

			DivElement rowSpacer = new DivElement()..className = "RowSpacer";
			chatString.style.paddingRight = "2px";

			bool atTheBottom = false;
			//if we're at the bottom before adding the incoming strings, scroll with them
			if ((querySelector("#MobileStyle") as LinkElement).disabled) {
				if ((chatHistory.scrollHeight - chatHistory.offsetHeight - chatHistory.scrollTop).abs() < 5) atTheBottom = true;
			}

			chatHistory.children.add(chatString);
			chatHistory.children.add(rowSpacer);

			if (atTheBottom || (map['username'] == chat.username || map['newUsername'] == chat.username)) chatHistory.scrollTop = chatHistory.scrollHeight;

			//for mobile version
			DivElement chatLine = new DivElement()
					..className = "bubble"
					..setInnerHtml(chatString.innerHtml, treeSanitizer: new NullTreeSanitizer());

			if (chatString.text.startsWith(chat.username)) chatLine.classes.add("me"); else chatLine.classes.add("you");

			DivElement chatRow = new DivElement()..className = "bubbleRow";
			chatRow.children.add(chatLine);

			DivElement conversation = querySelector('#conversation-' + channelName.replaceAll(" ", "_"));
			atTheBottom = false;
			if (!(querySelector("#MobileStyle") as LinkElement).disabled) {
				if ((conversation.scrollHeight - conversation.offsetHeight - conversation.scrollTop).abs() < 5) atTheBottom = true;
			}
			conversation.children.add(chatRow);
			if (atTheBottom || (map['username'] == chat.username || map['newUsername'] == chat.username)) conversation.scrollTop = conversation.scrollHeight;

			//display chat bubble if we're talking in local (unless it's a /me message)
			if (map["channel"] == "Local Chat" && map["username"] == chat.username && map["statusMessage"] == null && !(map["message"] as String).toLowerCase().startsWith("/me")) {
				//remove any existing bubble
				if (CurrentPlayer.chatBubble != null && CurrentPlayer.chatBubble.bubble != null) CurrentPlayer.chatBubble.bubble.remove();
				CurrentPlayer.chatBubble = new ChatBubble(_parseForEmoticons(map["message"]), CurrentPlayer, CurrentPlayer.playerParentElement, addUsername: true);
			}
		} else if (chatFail) {
			print(message);
		}
	}

	String _parseForUrls(String message) {
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
		message.splitMapJoin(regex, onMatch: (Match m) {
			String url = m[0];
			if (!url.contains("http")) url = "http://" + url;
			returnString += '<a href="${url}" target="_blank" class="MessageLink">${m[0]}</a>';
		}, onNonMatch: (String s) => returnString += s);

		return returnString;
	}

	String _parseForEmoticons(String message) {
		String returnString = "";
		RegExp regex = new RegExp(":(.+?):");
		message.splitMapJoin(regex, onMatch: (Match m) {
			String match = m[1];
			if (chat.EMOTICONS.contains(match)) returnString += "<img class ='Emoticon' src='assets/emoticons/$match.svg'></img>"; else returnString += m[0];
		}, onNonMatch: (String s) => returnString += s);

		return returnString;
	}
}

class NullTreeSanitizer implements NodeTreeSanitizer {
	void sanitizeTree(node) {}
}
