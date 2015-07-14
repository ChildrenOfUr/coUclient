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

// global functions

bool advanceChatFocus(KeyboardEvent k) {
  k.preventDefault();

  bool found = false;
  for (int i = 0; i < openConversations.length; i++) {
    Chat convo = openConversations[i];
    if (convo.focused) {
      //unfocus the current
      convo.blur();
      if (i < openConversations.length - 1) {
        // not last chat in list
        openConversations[i + 1].focus();
      } else {
        // last chat in list
        // focus game
        querySelector("#gameselector").focus();
        for (int i = 0; i < openConversations.length; i++) {
          openConversations[i].blur();
        }
      }
      found = true;
      break;
    }
  }

  if (!found) {
    // game is focused, focus first chat
    openConversations[0].focus();
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
      returnString +=
          '<img style="height:1em;" class="Emoticon" src="files/emoticons/$match.svg"></img>';
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
    returnString +=
        '<a href="${url}" target="_blank" class="MessageLink">${m[0]}</a>';
  }, onNonMatch: (String s) => returnString += s);

  return returnString;
}

// Chats and Chat functions
class Chat {
  String title,
      lastWord = "";
  bool online,
      focused = false,
      tabInserted = false;
  List messages;
  Element conversationElement;
  int unreadMessages = 0,
      tabSearchIndex = 0,
      numMessages = 0,
      inputHistoryPointer = 0,
      emoticonPointer = 0;
  static Chat otherChat = null,
      localChat = null;
  List<String> connectedUsers = new List(),
      inputHistory = new List();

  void focus() {
    this.focused = true;
    conversationElement.querySelector("input").focus();
  }

  void blur() {
    this.focused = false;
  }

  Chat(this.title) {
    title = title.trim();
    //look for an 'archived' version of this chat
    //otherwise create a new one
    conversationElement = getArchivedConversation(title);
    if (conversationElement == null) {
      // clone the template
      conversationElement =
          view.chatTemplate.querySelector('.conversation').clone(true);
      conversationElement.querySelector('.title')..text = title;
      openConversations.add(this);

      //handle chat input getting focused/unfocused so that the character doesn't move while typing
      InputElement chatInput = conversationElement.querySelector('input');
      chatInput.onFocus.listen((_) {
        inputManager.ignoreKeys = true;
        //need to set the focued variable to true and false for all the others
        openConversations.forEach((Chat c) => c.blur());
        focus();
      });
      chatInput.onBlur.listen((_) {
        inputManager.ignoreKeys = false;
        //we'll want to set the focused to false for this chat
        blur();
      });
    }

    if (title != "Local Chat") {
      if (otherChat != null) {
        otherChat.hide();
      }

      if (localChat != null) {
        view.panel.insertBefore(
            conversationElement, localChat.conversationElement);
      } else {
        view.panel.append(conversationElement);
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
      minimize.onClick.listen((_) => this.hide());
    }

    processInput(conversationElement.querySelector('input'));
  }

  processEvent(Map data) {
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
          view.inventory
              .querySelectorAll('.box')
              .forEach((Element box) => box.children.clear());
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
    }
  }

  NodeValidator validator = new NodeValidatorBuilder()
    ..allowHtml5()
    ..allowElement('span', attributes: ['style'])
    ..allowElement('a', attributes: ['href']);

  addMessage(String player, String message) {
    ChatMessage chat = new ChatMessage(player, message);
    Element dialog = conversationElement.querySelector('.dialog');
    dialog.appendHtml(chat.toHtml(), validator: validator);
    dialog.scrollTop = dialog.scrollHeight;
    //scroll to the bottom
  }

  addAlert(String alert) {
    String text = '''
			<p class="system">
			$alert
			</p>
			''';
    Element dialog = conversationElement.querySelector('.dialog');
    dialog.appendHtml(text, validator: validator);
    dialog.scrollTop = dialog.scrollHeight;
    //scroll to the bottom
  }

  displayList(List<String> users) {
    String alert = "Players in this channel:";

    for (int i = 0; i != users.length; i++) {
      users[i] = '<a href="http://childrenofur.com/profile?username=' +
          users[i] +
          '" target="_blank">' +
          users[i] +
          '</a>';
      alert = alert + " " + users[i];
    }

    String text = '''
			<p class="system">
			$alert
			</p>
			''';
    conversationElement.querySelector('.dialog').appendHtml(text,
        validator: validator);
    conversationElement.querySelector('.dialog').scrollTop = conversationElement
        .querySelector('.dialog').scrollHeight; //scroll to the bottom
  }

  /**
	 * Archive the conversation (detach it from the chat panel) so that we may reattach
	 * it later with the history intact.
	 **/
  hide() {
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
    Element conversationElement = view.conversationArchive
        .querySelector('.archive-${title.replaceAll(' ', '_')}');
    if (conversationElement != null) {
      conversationElement.classes
          .remove('.archive-${title.replaceAll(' ', '_')}');
      conversationElement.classes.add("conversation");
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
    conversations.forEach(
        (Element conversation) => conversation.style.height = "${100 / num}%");
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

  emoticonComplete(InputElement input, KeyboardEvent k) {
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

  tabComplete(TextInputElement input, KeyboardEvent k) async {
    //don't allow a key like tab to change to a different chat
    //if we don't get a hit and k=[tab], we will re-fire
    k.stopImmediatePropagation();

    String channel = 'Global Chat';
    bool inserted = false;

    if (title != channel) {
      channel = currentStreet.label;
    }
    String url =
        'http://' + Configs.utilServerAddress + "/listUsers?channel=$channel";
    connectedUsers = JSON.decode(await HttpRequest.requestCrossOrigin(url));

    int startIndex = input.value.lastIndexOf(" ") == -1
        ? 0
        : input.value.lastIndexOf(" ") + 1;
    String localLastWord = input.value.substring(startIndex);
    if (!tabInserted) {
      lastWord = input.value.substring(startIndex);
    }

    for (; tabSearchIndex < connectedUsers.length; tabSearchIndex++) {
      String username = connectedUsers.elementAt(tabSearchIndex);
      if (username.toLowerCase().startsWith(lastWord.toLowerCase()) &&
          username.toLowerCase() != localLastWord.toLowerCase()) {
        input.value = input.value.substring(
                0, input.value.lastIndexOf(" ") + 1) +
            username;
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
          input.value = input.value.substring(
                  0, input.value.lastIndexOf(" ") + 1) +
              username;
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

  parseInput(String input) {
    // if its not a command, send it through.
    if (parseCommand(input)) return;
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
}

class ChatMessage {
  String player, message;
  List<String> devs = [
	  // slack usernames
	  "courtneybreid",
	  "klikini",
	  "paul",
	  "robertmcdermot",
	  // game usernames
	  "lead",
	  "paal",
	  "thaderator"
  ];

  ChatMessage(this.player, this.message);

  String toHtml() {
    if (message is! String) {
      return '';
    }
    String html;

    message = parseUrl(message);
    message = parseEmoji(message);

    if (message.toLowerCase().contains(game.username.toLowerCase())) {
      transmit('playSound', 'mention');
    }

    if (player == null) {
      html = '''
		<p class="system">
			$message
		</p>
		''';
    } else if (message.startsWith('/me')) {
      message = message.replaceFirst('/me ', '');
      html = '''
		<p class="me" style="color:${getColorFromUsername(player)};">
			<i><a class="noUnderline" href="http://childrenofur.com/profile?username=${player}" target="_blank" title="Open Profile Page">$player</a> $message</i>
		</p>
				''';
    } else if (devs.contains(player.toLowerCase())) {
      html = '''
		<p>
			<span class="name dev" style="color:${getColorFromUsername(player)};"><a class="noUnderline" href="http://childrenofur.com/profile?username=${player}" target="_blank" title="Open Profile Page">$player</a>:</span>
			<span class="message">$message</span>
		</p>
		''';
    } else {
      html = '''
		<p>
			<span class="name" style="color:${getColorFromUsername(player)};"><a class="noUnderline" href="http://childrenofur.com/profile?username=${player}" target="_blank" title="Open Profile Page">$player</a>:</span>
			<span class="message">$message</span>
		</p>
		''';
    }

    return html;
  }
}
