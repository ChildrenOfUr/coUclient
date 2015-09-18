part of couclient;

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
    message = parseItemLinks(message);

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

// chat functions

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

String parseItemLinks(String message) {
  String returnString = "";
  RegExp regex = new RegExp("#(.+?)#");
  (message.splitMapJoin(regex, onMatch: (Match m) {
    String match = m[1];
    if (Item.isItem(itemType: match)) {
      String name = Item.getName(match);
      String iconUrl = Item.getIcon(itemType: match);
      returnString += '<a class="item-chat-link" title="View Item" href="#">'
      '<span class="item-chat-link-icon" '
      'style="background-image: url($iconUrl);">'
      '</span>$name</a>';
    } else {
      returnString += m[0];
    }
  }, onNonMatch: (String s) => returnString += s));

  return returnString;
}