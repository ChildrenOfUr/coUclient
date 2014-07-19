part of couclient;

List<String> EMOTICONS;

List<Chat> openConversations = [];

class ChatManager extends Pump {

  ChatManager() {
    //load emoticons
    new Asset("packages/couclient/emoticons/emoticons.json").load().then((Asset asset) => EMOTICONS = asset.get()["names"]);    
    // Subscribe to the Bus
    EVENT_BUS > this;
  }
  
  @override
  process(Moment <Map> event) {
    // ChatEvents are drawn to their Conversation.
    if (event.isType('ChatEvent')) {
      for (Chat convo in openConversations) {
        if (convo.title == event()['channel']) convo.addMessage(event()['username'], event()['message']);
      }
    }
    // StartChat events start a Conversation
    if (event.isType('StartChat')) {
      Chat chat = new Chat(event());
      openConversations.add(chat);
    }
  }
}

// global functions
String getColorFromUsername(String username) {
  List<String> COLORS = ["aqua", "blue", "fuchsia", "gray", "green", "lime", "maroon", "navy", "olive", "orange", "purple", "red", "teal"];
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
    if (EMOTICONS.contains(match)) returnString += '<img style="height:1em;" class="Emoticon" src="packages/couclient/emoticons/$match.svg"></img>'; else returnString += m[0];
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
  List<String> connectedUsers = new List();
  List<String> inputHistory = new List();
  bool tabInserted = false;
  Chat(this.title) {
    // clone the template
    conversationElement = ui.chatTemplate.querySelector('.conversation').clone(true);
    Element title = conversationElement.querySelector('.title')..text = this.title;
    ui.panel.append(conversationElement);

    Stream minimize = conversationElement.querySelector('.fa-chevron-down').onClick;
    minimize.listen((_) => this.hide());

    processInput(conversationElement.querySelector('input'));

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
  hide() => conversationElement.hidden = true;
  show() => conversationElement.hidden = false;

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


  parseInput(String input) {
    Map map = new Map();
    // if its' not a command, send it through.
    if (parseCommand(input))
      return;
    else {
      map["username"] = ui.username;
      map["message"] = input;
      map["channel"] = title;
      //if (channelName == "Local Chat") map["street"] = currentStreet.label;
      new Moment('OutgoingChatEvent',map, 'parseInput');
    }
  }
}


class ChatMessage {
  String player, message;
  ChatMessage(this.player, this.message);
  String toHtml() {
    if (message is String == false) return '';    
    String html;
    
    message = parseUrl(message);
    message = parseEmoji(message);

    if (message.toLowerCase().contains(ui.username.toLowerCase())) {
      new Moment('PlaySound','mention');
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
      $player $message
      </p>
      ''';
    } else {
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
