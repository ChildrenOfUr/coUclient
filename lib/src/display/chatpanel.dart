part of couclient;

List<String> EMOTICONS;
List<String> COLORS = [
	"blue",
	"deepskyblue",
	"fuchsia",
	"gray",
	"green",
	"olivedrab",
	"maroon",
	"navy",
	"olive",
	"orange",
	"purple",
	"red",
	"teal"
];
List<Chat> openConversations = [];
List<String> chatToastBuffer = [];

// global functions

bool advanceChatFocus(KeyboardEvent k) {
	k.preventDefault();

	bool found = false;
	for (int i = 0; i < openConversations.length; i++) {
		Chat convo = openConversations[i];

		if (convo.focused) {
			if (i < openConversations.length - 1) {
				//unfocus the current
				convo.blur();

				//find the next non-archived conversation and focus it
				for (int j = i + 1; j < openConversations.length; j++) {
					if (!openConversations[j].archived) {
						openConversations[j].focus();
						found = true;
					}
				}

				if (found) {
					break;
				}
			} else {
				// last chat in list, focus game
				querySelector("#gameselector").focus();
				for (int i = 0; i < openConversations.length; i++) {
					openConversations[i].blur();
				}
				found = true;
			}
		}
	}

	if (!found) {
		// game is focused, focus first chat that is not archived
		for (Chat c in openConversations) {
			if (!c.archived) {
				c.focus();
				break;
			}
		}
	}

	return true;
}

String getColorFromUsername(String username) {
	int index = 0;
	for (int i = 0; i < username.length; i++) {
		index += username.codeUnitAt(i);
	}

	return COLORS[index % (COLORS.length - 1)];
}

String parseEmoji(String message) {
	String returnString = "";
	RegExp regex = new RegExp(":(.+?):");
	message.splitMapJoin(regex, onMatch: (Match m) {
		String match = m[1];
		if (EMOTICONS.contains(match)) {
			returnString += '<i class="emoticon emoticon-sm $match" title="$match"></i>';
		} else {
			returnString += m[0];
		}
	}, onNonMatch: (String s) => returnString += s);

	return returnString;
}

String parseUrl(String message) {
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
		if (!url.contains("http")) {
			url = "http://" + url;
		}
		returnString += '<a href="${url}" target="_blank" class="MessageLink">${m[0]}</a>';
	}, onNonMatch: (String s) => returnString += s);

	return returnString;
}

String parseFormat(String message) {
	List<md.InlineSyntax> allowed = [
		new md.TagSyntax(r'\*', tag: 'strong'),
		new md.TagSyntax(r'\/', tag: 'em')
	];
	String escaped = md.markdownToHtml(message, inlineSyntaxes: allowed, inlineOnly: true);
	return escaped.replaceAll("&lt;", "<").replaceAll("&gt;", ">");
}

// Chats and Chat functions
class Chat {
	String title, lastWord = "";
	bool online, focused = false, tabInserted = false;
	Element conversationElement, trigger;
	int unreadMessages = 0, tabSearchIndex = 0, numMessages = 0, inputHistoryPointer = 0, emoticonPointer = 0;
	static Chat otherChat = null, localChat = null;
	List<String> connectedUsers = new List(), inputHistory = new List();

	static NodeValidator validator = new NodeValidatorBuilder()
		..allowHtml5()
		..allowElement('span', attributes: ['style']) // Username colors
		..allowElement('a', attributes: ['href', 'title', 'target', 'class']) // Links
		..allowElement('strong') // [md] Bold
		..allowElement('em') // [md] italic
		..allowElement('i', attributes: ['class', 'title']) // Emoticons
		..allowElement('p', attributes: ['style']);

	// /me text

	// Emoticons

	bool get archived {
		return !conversationElement.classes.contains('conversation');
	}

	void focus() {
		this.focused = true;
		conversationElement.querySelector("input").focus();
	}

	void blur() {
		this.focused = false;
	}

	Chat(this.title) {
		title = title.trim();

		// find the link in the chat panel that opens the chat
		if (title != "Local Chat") {
			trigger = querySelectorAll("#rightSide *").where((Element e) => e.dataset["chat"] == title).first;
		}

		//look for an 'archived' version of this chat
		//otherwise create a new one
		conversationElement = getArchivedConversation(title);
		if (conversationElement == null) {

			// start a timer for the first global chat created that refreshes the sidebar player list
			if (title == "Global Chat") {
				refreshOnlinePlayers();
				new Timer.periodic(new Duration(seconds: 5), (_) => refreshOnlinePlayers());
			}

			// clone the template
			conversationElement = view.chatTemplate.querySelector('.conversation').clone(true);
			Map<String, dynamic> emoticonArgs = {
				"title": title,
				"input": conversationElement.querySelector("input")
			};
			conversationElement
				..querySelector('.title').text = title
				..querySelector(".insertemoji").onClick.listen((_) => transmit('insertEmoji', emoticonArgs))
				..id = "chat-$title";
			openConversations.insert(0, this);

			if (title == "Local Chat") {
				// Streets loaded, display a divider
				new Service(["gameLoaded", "streetLoaded"], (_) {
					this.addMessage("invalid_user", "LocationChangeEvent");
				});

				// First street loaded, init Local Chat
				new Service(["gameLoaded"], (_) {
          localChat = this;
          chatToastBuffer.forEach((String message) {
            this.addAlert(message, toast: true);
          });
				});
			}

			//handle chat input getting focused/unfocused so that the character doesn't move while typing
			InputElement chatInput = conversationElement.querySelector('input');
			chatInput.onFocus.listen((_) {
				inputManager.ignoreKeys = true;
				//need to set the focused variable to true and false for all the others
				openConversations.forEach((Chat c) => c.blur());
				focus();
				transmit("worldFocus", false);
			});
			chatInput.onBlur.listen((_) {
				inputManager.ignoreKeys = false;
				//we'll want to set the focused to false for this chat
				blur();
			});
		} else {
			// mark as read
			trigger.classes.remove("unread");
			NetChatManager.updateTabUnread();
		}

		if (title != "Local Chat") {
			if (localChat != null) {
				view.panel.insertBefore(conversationElement, localChat.conversationElement);
			} else {
				view.panel.append(conversationElement);
			}

			if (otherChat != null) {
				otherChat.archiveConversation();
				focus();
			}

			otherChat = this;
		}
		//don't ever have 2 local chats
		else if (localChat == null) {
			localChat = this;
			view.panel.append(conversationElement);
			//can't remove the local chat
			conversationElement.querySelector('.fa-chevron-down').remove();
		}

		computePanelSize();

		Element minimize = conversationElement.querySelector('.fa-chevron-down');
		if (minimize != null) {
			minimize.onClick.listen((_) => this.archiveConversation());
		}

		processInput(conversationElement.querySelector('input'));
	}

	void processEvent(Map data) {
		if (data["message"] == " joined.") {
			if (!connectedUsers.contains(data["username"])) {
				connectedUsers.add(data["username"]);
			}
		}

		if (data["message"] == " left.") {
			connectedUsers.remove(data["username"]);
			removeOtherPlayer(data["username"]);
		}

		if (data["statusMessage"] == "changeName") {
			if (data["success"] == "true") {
				removeOtherPlayer(data["username"]);

				//although this message is broadcast to everyone, only change usernames
				//if we were the one to type /setname
				if (data["newUsername"] == game.username) {
					CurrentPlayer.username = data['newUsername'];
					CurrentPlayer.loadAnimations();

					//clear our inventory so we can get the new one
					view.inventory.querySelectorAll('.box').forEach((Element box) => box.children.clear());
					firstConnect = true;
					joined = "";
					sendJoinedMessage(currentStreet.label);

					//warn multiplayer server that it will receive messages
					//from a new name but it should be the same person
					data['street'] = currentStreet.label;
					playerSocket.send(JSON.encode(data));

					timeLast = 5.0;
				}

				connectedUsers.remove(data["username"]);
				connectedUsers.add(data["newUsername"]);
			}
		} else {
			addMessage(data['username'], data['message']);
			if (archived) {
				trigger.classes.add("unread");
				NetChatManager.updateTabUnread();
			}
		}
	}

	void addMessage(String player, String message) {
		ChatMessage chat = new ChatMessage(player, message);
		Element dialog = conversationElement.querySelector('.dialog');
		dialog.appendHtml(chat.toHtml(), validator: Chat.validator);

		//scroll to the bottom
		dialog.scrollTop = dialog.scrollHeight;
	}

  void addAlert(String alert, {bool toast: false}) {
    String classes = "system ";
    if (toast) {
      classes += "chat-toast ";
    }
    String text = '<p class="$classes">$alert</p>';
		Element dialog = conversationElement.querySelector('.dialog');
		dialog.appendHtml(text, validator: validator);

		//scroll to the bottom
		dialog.scrollTop = dialog.scrollHeight;
	}

	void displayList(List<String> users) {
		String alert = "Players in this channel:";

		for (int i = 0; i != users.length; i++) {
			users[i] = '<a href="http://childrenofur.com/profile?username=' +
			           users[i] +
			           '" target="_blank">' +
			           users[i] +
			           '</a>';
			alert = alert + " " + users[i];
		}

		String text = '<p class="system">$alert</p>';

		Element dialog = conversationElement.querySelector('.dialog');
		dialog.appendHtml(text, validator: validator);

		//scroll to the bottom
		dialog.scrollTop = dialog.scrollHeight;
	}

	/**
	 * Archive the conversation (detach it from the chat panel) so that we may reattach
	 * it later with the history intact.
	 **/
	void archiveConversation() {
		conversationElement.classes.add("archive-${title.replaceAll(' ', '_')}");
		conversationElement.classes.remove("conversation");
		view.conversationArchive.append(conversationElement);
		computePanelSize();
		otherChat = null;
	}

	/**
	 * Find an archived conversation and return it
	 * returns null if no conversation exists
	 **/
	Element getArchivedConversation(String title) {
		String archiveClass = '.archive-${title.replaceAll(' ', '_')}';
		Element conversationElement = view.conversationArchive.querySelector(archiveClass);
		if (conversationElement != null) {
			conversationElement.classes.remove(archiveClass);
			conversationElement.classes.add("conversation");

			//move this conversation to the front of the openConversations list
			for (Chat c in openConversations) {
				if (c.title == title) {
					openConversations.remove(c);
					openConversations.insert(0, c);
					break;
				}
			}
		}
		return conversationElement;
	}

	void computePanelSize() {
		List<Element> conversations =
		view.panel.querySelectorAll('.conversation').toList();
		int num = conversations.length - 1;
		conversations.forEach((Element conversation) {
			if (conversation.hidden) {
				num--;
			}
		});
		conversations.forEach((Element conversation) => conversation.style.height = "${100 / num}%");
	}

	void processInput(TextInputElement input) {
		//onKeyUp seems to be too late to prevent TAB's default behavior
		input.onKeyDown.listen((KeyboardEvent key) {
			//pressed up arrow
			if (key.keyCode == 38 && inputHistoryPointer < inputHistory.length) {
				input.value = inputHistory.elementAt(inputHistoryPointer);
				if (inputHistoryPointer < inputHistory.length - 1) {
					inputHistoryPointer++;
				}
			}
			//pressed down arrow
			if (key.keyCode == 40) {
				if (inputHistoryPointer > 0) {
					inputHistoryPointer--;
					input.value = inputHistory.elementAt(inputHistoryPointer);
				} else {
					input.value = "";
				}
			}
			//tab key, try to complete a user's name or an emoticon
			if (input.value != "" && key.keyCode == 9) {
				key.preventDefault();

				//look for an emoticon instead of a username
				if (input.value.endsWith(":")) {
					emoticonComplete(input, key);
					return;
				}

				//let's suggest players to tab complete
				tabComplete(input, key);

				return;
			}
		});

		input.onKeyUp.listen((KeyboardEvent key) {
			if (key.keyCode != 9) {
				tabInserted = false;
			}

			if (key.keyCode != 13) {
				//listen for enter key
				return;
			}

			if (input.value.trim().length == 0) {
				//don't allow for blank messages
				return;
			}

			parseInput(input.value);

			inputHistory.insert(0, input.value); //add to beginning of list
			inputHistoryPointer = 0; //point to beginning of list
			if (inputHistory.length > 50) {
				//don't allow the list to grow forever
				inputHistory.removeLast();
			}

			input.value = '';
		});
	}

	void emoticonComplete(InputElement input, KeyboardEvent k) {
		//don't allow a key like tab to change to a different chat
		//if we don't get a hit and k=[tab], we will re-fire
		k.stopImmediatePropagation();

		String value = input.value;
		bool emoticonInserted = false;

		//if the input is exactly one long (therefore it is just a colon)
		if (value.length == 1) {
			//String beforePart = value.substring(0,lastColon);
			input.value = ":${EMOTICONS.elementAt(emoticonPointer)}:";
			emoticonPointer++;
			emoticonInserted = true;
		}
		//if the input is more than 1 long and there's a space before the colon (word separation)
		else if (value.endsWith(" :")) {
			int lastColon = value.lastIndexOf(':');
			String beforePart = value.substring(0, lastColon);
			input.value = "$beforePart:${EMOTICONS.elementAt(emoticonPointer)}:";
			emoticonPointer++;
			emoticonInserted = true;
		}

		//if the input is more than 1 long and there is an emoticon that we should replace
		//to do this, we check if the value has 2 : and that the text between them
		//exactly matches an emoticon
		int previousColon = value.substring(0, value.length - 1).lastIndexOf(':');
		if (previousColon > -1) {
			String beforeSegment = value.substring(0, previousColon);
			String emoticonSegment = value.substring(previousColon, value.length);
			for (int i = 0; i < EMOTICONS.length; i++) {
				String emoticon = EMOTICONS[i];
				String emoticonNext;
				if (i < EMOTICONS.length - 1) {
					emoticonNext = EMOTICONS[i + 1];
				} else {
					emoticonNext = EMOTICONS[0];
				}
				if (emoticonSegment.contains(':$emoticon:')) {
					input.value = "$beforeSegment:$emoticonNext:";
					emoticonPointer++;
					emoticonInserted = true;
					break;
				}
			}
		}

		//make sure we don't point past the end of the array
		if (emoticonPointer >= EMOTICONS.length) {
			emoticonPointer = 0;
		}

		//if we didn't manage to insert an emoticon and tab was pressed...
		//try to advance chat focus because we stifled it earlier
		if (!emoticonInserted && k.keyCode == 9) {
			advanceChatFocus(k);
		}
	}

	Future tabComplete(TextInputElement input, KeyboardEvent k) async {
		//don't allow a key like tab to change to a different chat
		//if we don't get a hit and k=[tab], we will re-fire
		k.stopImmediatePropagation();

		String channel = 'Global Chat';
		bool inserted = false;

		if (title != channel) {
			channel = currentStreet.label;
		}
		String url = 'http://' + Configs.utilServerAddress + "/listUsers?channel=$channel";
		connectedUsers = JSON.decode(await HttpRequest.requestCrossOrigin(url));

		int startIndex = input.value.lastIndexOf(" ") == -1 ? 0 : input.value.lastIndexOf(" ") + 1;
		String localLastWord = input.value.substring(startIndex);
		if (!tabInserted) {
			lastWord = input.value.substring(startIndex);
		}

		for (; tabSearchIndex < connectedUsers.length; tabSearchIndex++) {
			String username = connectedUsers.elementAt(tabSearchIndex);
			if (username.toLowerCase().startsWith(lastWord.toLowerCase()) &&
			    username.toLowerCase() != localLastWord.toLowerCase()) {
				input.value = input.value.substring(0, input.value.lastIndexOf(" ") + 1) + username;
				tabInserted = true;
				inserted = true;
				tabSearchIndex++;
				break;
			}
		}
		//if we didn't find it yet and the tabSearchIndex was not 0, let's look at the beginning of the array as well
		//otherwise the user will have to press the tab key again
		if (!tabInserted) {
			for (int index = 0; index < tabSearchIndex; index++) {
				String username = connectedUsers.elementAt(index);
				if (username.toLowerCase().startsWith(lastWord.toLowerCase()) &&
				    username.toLowerCase() != localLastWord.toLowerCase()) {
					input.value = input.value.substring(0, input.value.lastIndexOf(" ") + 1) + username;
					tabInserted = true;
					inserted = true;
					tabSearchIndex = index + 1;
					break;
				}
			}
		}

		if (!inserted && k.keyCode == 9) {
			advanceChatFocus(k);
		}

		if (tabSearchIndex == connectedUsers.length) {
			//wrap around for next time
			tabSearchIndex = 0;
		}
	}

	void parseInput(String input) {
		// if its not a command, send it through.
		if (parseCommand(input)) {
			return;
		}
		else if (input.toLowerCase() == "/list") {
			Map map = {};
			map["username"] = game.username;
			map["statusMessage"] = "list";
			map["channel"] = title;
			map["street"] = currentStreet.label;
			transmit('outgoingChatEvent', map);
		} else {
			Map map = new Map();
			map["username"] = game.username;
			map["message"] = input;
			map["channel"] = title;
			if (title == "Local Chat") {
				map["street"] = currentStreet.label;
			}

			transmit('outgoingChatEvent', map);

			//display chat bubble if we're talking in local (unless it's a /me message)
			if (map["channel"] == "Local Chat" &&
			    !(map["message"] as String).toLowerCase().startsWith("/me")) {
				//remove any existing bubble
				if (CurrentPlayer.chatBubble != null &&
				    CurrentPlayer.chatBubble.bubble != null) {
					CurrentPlayer.chatBubble.bubble.remove();
				}
				CurrentPlayer.chatBubble = new ChatBubble(parseEmoji(map["message"]),
				CurrentPlayer, CurrentPlayer.playerParentElement);
			}
		}
	}

	// Update the list of online players in the sidebar
	Future<int> refreshOnlinePlayers() async {
		if (this.title != "Global Chat") {
			return -1;
		}

		// Ignore yourself (can't chat with yourself, either)
		List<String> users = JSON.decode(await HttpRequest.requestCrossOrigin('http://${ Configs.utilServerAddress}/listUsers?channel=Global Chat'));
		users.removeWhere((String username) => username == game.username);

		// Reset the list
		Element list = querySelector("#playerList");
		list.children.clear();

		if (users.length == 0) {
			// Nobody else is online
			Element message = new LIElement()
				..classes.addAll(["noChatSpawn"])
				..setInnerHtml('<i class="fa-li fa fa-square-o"></i> Nobody else here');
			list.append(message);
			return 0;
		} else {
			// Other players are online
			users.forEach((String username) {
				Element user = new LIElement()
					..classes.add("online")
					..style.pointerEvents = "none"
				//..classes.addAll(["online", "chatSpawn"])
				//..dataset["chat"] = username
					..setInnerHtml('<i class="fa-li fa fa-user"></i> $username');
				list.append(user);
			});
			return users.length;
		}
	}
}

class ChatMessage {
	String player, message;

	ChatMessage(this.player, this.message);

	String toHtml() {
		if (message is! String) {
			return '';
		}
		String html, displayName = player;

		message = parseUrl(message);
		message = parseEmoji(message);
		message = parseFormat(message);

		if (message.toLowerCase().contains(game.username.toLowerCase())) {
			transmit('playSound', 'mention');
		}

		// Apply labels
		String nameClass = "name ";
		if (player != null) {
			// You
			if (player == game.username) {
				nameClass += "you ";
			}
			// Dev/Guide
			if (game.devs.contains(player)) {
				nameClass += "dev ";
			} else if (game.guides.contains(player)) {
				nameClass += "guide ";
			}
		}

		if (game.username == player) {
			displayName = "You";
		}

		if (player == null) {
			// System message
			html = '<p class="system">$message</p>';
		} else if (message.startsWith('/me')) {
			// /me message
			message = message.replaceFirst('/me ', '');
			html =
			'<p class="me" style="color:${getColorFromUsername(player)};">'
			'<i><a class="noUnderline" href="http://childrenofur.com/profile?username=${player}" target="_blank" title="Open Profile Page">$player</a> $message</i>'
			'</p>';
		} else if (message == " joined." || message == " left.") {
			// Player joined or left
			if (game.username != player) {
				html =
				'<p class="chat-member-change-event">'
				'<span class="$nameClass" style="color: ${getColorFromUsername(player)};"><a class="noUnderline" href="http://childrenofur.com/profile?username=${player}" target="_blank" title="Open Profile Page">$displayName</a> </span>'
				'<span class="message">$message</span>'
				'</p>';
				if (player != game.username) {
					if (message == " joined.") {
						toast("$player has arrived");
					}
					if (message == " left.") {
						toast("$player left");
					}
				}
			} else {
				html = "";
			}
		} else if (message == "LocationChangeEvent" && player == "invalid_user") {
			// Switching streets message
			html =
			'<p class="chat-member-change-event">'
			'<span class="message">${currentStreet.label}</span>'
			'</p>';
		} else {
			// Normal message
			html =
			'<p>'
			'<span class="$nameClass" style="color: ${getColorFromUsername(player)};"><a class="noUnderline" href="http://childrenofur.com/profile?username=${player}" target="_blank" title="Open Profile Page">$displayName</a>: </span>'
			'<span class="message">$message</span>'
			'</p>';
		}

		return html;
	}
}