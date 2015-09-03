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