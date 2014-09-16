part of couclient;

List<String> EMOTICONS;
List<String> COLORS = ["aqua", "blue", "fuchsia", "gray", "green", "lime", "maroon", "navy", "olive", "orange", "purple", "red", "teal"];
List<Chat> openConversations = [];

// global functions
String getColorFromUsername(String username)
{
	int index = 0;
	for (int i = 0; i < username.length; i++)
		index += username.codeUnitAt(i);
  	
	return COLORS[index % (COLORS.length - 1)];
}

String parseEmoji(String message)
{
	String returnString = "";
	RegExp regex = new RegExp(":(.+?):");
	message.splitMapJoin(regex, onMatch: (Match m)
	{
    	String match = m[1];
    	if(EMOTICONS.contains(match))
    		returnString += '<img style="height:1em;" class="Emoticon" src="packages/couclient/emoticons/$match.svg"></img>';
    	else 
    		returnString += m[0];
  	}, 
  	onNonMatch: (String s) => returnString += s);

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
    if (!url.contains("http")) url = "http://" + url;
    returnString += '<a href="${url}" target="_blank" class="MessageLink">${m[0]}</a>';
  }, onNonMatch: (String s) => returnString += s);

  return returnString;
}

// Chats and Chat functions
class Chat {
  String title;
  bool online;
  List messages;
  String lastWord = "";
  var conversationElement;
  /// Events automatically are added to th
  int unreadMessages = 0,
      tabSearchIndex = 0,
      numMessages = 0,
      inputHistoryPointer = 0,
      emoticonPointer = 0;
  static Chat otherChat = null, localChat = null;
  List<String> connectedUsers = new List();
  List<String> inputHistory = new List();
  bool tabInserted = false;
  Chat(this.title) 
  {
	  title = title.trim();
	//look for an 'archived' version of this chat
	//otherwise create a new one
	conversationElement = getArchivedConversation(title);
	if(conversationElement == null)
  	{
  		// clone the template
		conversationElement = ui.chatTemplate.querySelector('.conversation').clone(true);
		conversationElement.querySelector('.title')..text = title;
		openConversations.add(this);
	}
    
    if(title != "Local Chat")
    {
    	if(otherChat != null)
    		otherChat.hide();
      	
    	if(localChat != null)
			ui.panel.insertBefore(conversationElement, localChat.conversationElement);
		else
			ui.panel.append(conversationElement);
    	
    	otherChat = this;
    }
    else if(localChat == null) //don't ever have 2 local chats
    {
    	localChat = this;
    	ui.panel.append(conversationElement);
    	//can't remove the local chat
    	conversationElement.querySelector('.fa-chevron-down').remove();
    }
    
    computePanelSize();

    Element minimize = conversationElement.querySelector('.fa-chevron-down');
    if(minimize != null)
    	minimize.onClick.listen((_) => this.hide());

    processInput(conversationElement.querySelector('input'));
  }

	processEvent(Map data)
	{
		if(data["message"] == " joined.")
		{
			if(!connectedUsers.contains(data["username"]))
				connectedUsers.add(data["username"]);
		}
	
		if(data["message"] == " left.")
		{
			connectedUsers.remove(data["username"]);
			removeOtherPlayer(data["username"]);
		}
		
		if(data["statusMessage"] == "changeName")
		{						
			if(data["success"] == "true")
			{
				connectedUsers.remove(data["username"]);
				removeOtherPlayer(data["username"]);
                connectedUsers.add(data["newUsername"]);
			}
		}
		addMessage(data['username'], data['message']);
	}
	
  addMessage(String player, String message) {
    ChatMessage chat = new ChatMessage(player, message);
    conversationElement.querySelector('.dialog').appendHtml(chat.toHtml());
    conversationElement.querySelector('.dialog').scrollTop = conversationElement.querySelector('.dialog').scrollHeight; //scroll to the bottom
  }
  addAlert(String alert) {
    String text = '''
      <p class="system">
      $alert
      </p>
      ''';
    conversationElement.querySelector('.dialog').appendHtml(text);
    conversationElement.querySelector('.dialog').scrollTop = conversationElement.querySelector('.dialog').scrollHeight; //scroll to the bottom
  }
  
	/**
 	* Archive the conversation (detach it from the chat panel) so that we may reattach
 	* it later with the history intact.
	**/
	hide()
	{
		conversationElement.classes.add("archive-${title.replaceAll(' ', '_')}");
		conversationElement.classes.remove("conversation");
		ui.conversationArchive.append(conversationElement);
		computePanelSize();
		otherChat = null;
	}
  
	/**
	* Find an archived conversation and return it
	* returns null if no conversation exists
	**/
	Element getArchivedConversation(String title)
	{
		Element conversationElement = ui.conversationArchive.querySelector('.archive-${title.replaceAll(' ', '_')}');
		if(conversationElement != null)
		{
			conversationElement.classes.remove('.archive-$title');
			conversationElement.classes.add("conversation");
		}
		return conversationElement;
	}
  
	void computePanelSize()
	{
		List<Element> conversations = ui.panel.querySelectorAll('.conversation').toList();
		int num = conversations.length-1;
    	conversations.forEach((Element conversation)
		{
    		if(conversation.hidden)
    			num--;          
		});
		conversations.forEach((Element conversation) 
    		=> conversation.style.height = "${100/num}%");
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
            input.value = value.substring(0, value.lastIndexOf(":") + 1) + EMOTICONS.elementAt(emoticonPointer) + ":";
            emoticonPointer++;
            if (emoticonPointer == EMOTICONS.length) emoticonPointer = 0;
          } else if (value.length > 1 && !value.substring(value.lastIndexOf(":") - 1).startsWith(" :")) //change existing emoticon choice
          {
            int lastColon = value.lastIndexOf(":"),
                count = 0;
            bool setNext = false;
            while (count < EMOTICONS.length * 2) {
              String name = EMOTICONS.elementAt(count % EMOTICONS.length);
              if (setNext) {
                input.value = value.substring(0, lastColon - EMOTICONS.elementAt(emoticonPointer).length) + name + ":";
                emoticonPointer++;
                if (emoticonPointer == EMOTICONS.length) emoticonPointer = 0;
                break;
              }

              if (value.substring(lastColon - name.length, lastColon) != -1 && value.substring(lastColon - name.length, lastColon) == name) {
                setNext = true;
                emoticonPointer = count % EMOTICONS.length;
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


	parseInput(String input) 
	{
	    // if its' not a command, send it through.
	    if (parseCommand(input)) 
	    	return;
	    else if(input.toLowerCase() == "/list")
        {
	    	Map map = {};
			map["username"] = ui.username;
			map["statusMessage"] = "list";
			map["channel"] = title;
			map["street"] = currentStreet.label;
			new Moment('OutgoingChatEvent', map, 'parseInput');
        }
	    else 
	    {
	    	Map map = new Map();
	    	map["username"] = ui.username;
	    	map["message"] = input;
	    	map["channel"] = title;
	    	if (title == "Local Chat") 
				map["street"] = currentStreet.label;
	
			new Moment('OutgoingChatEvent', map, 'parseInput');
	      
			//display chat bubble if we're talking in local (unless it's a /me message)
			if(map["channel"] == "Local Chat" && !(map["message"] as String).toLowerCase().startsWith("/me"))
			{
				//remove any existing bubble
				if(CurrentPlayer.chatBubble != null && CurrentPlayer.chatBubble.bubble != null)
					CurrentPlayer.chatBubble.bubble.remove();
				CurrentPlayer.chatBubble = new ChatBubble(parseEmoji(map["message"]));
			}
		}
	}
}

class ChatMessage 
{
	String player, message;
	ChatMessage(this.player, this.message);
	
	String toHtml()
	{
		if (message is String == false) return '';
		String html;

		message = parseUrl(message);
		message = parseEmoji(message);

		if (message.toLowerCase().contains(ui.username.toLowerCase()))
			new Moment('PlaySound', 'mention');

		if (player == null)
		{
			html = '''
			<p class="system">
			$message
			</p>
			''';
		}
		else if (message.startsWith('/me'))
		{
			message = message.replaceFirst('/me ', '');
			html = '''
			<p class="me" style="color:${getColorFromUsername(player)};">
			$player $message
			</p>
			''';
		}
		else 
		{
			html = '''
			<p>
			<span class="name" style="color:${getColorFromUsername(player)};">$player:</span>
			<span class="message">$message</span>
			</p>
			''';
		}
		
		return html;
	}
}