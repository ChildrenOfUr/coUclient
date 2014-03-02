part of coUclient;

class ChatBubble
{
  String text;
  num timeToLive;
  DivElement bubble;
  SpanElement textElement;

  ChatBubble(this.text)
  {
    timeToLive = text.length * 0.1 + 3; //minimum 3s plus 0.1s per character
    if (timeToLive > 15) { //max 15s
      timeToLive = 15; //messages over 15s will only display for 15s
    }
    bubble = new DivElement()
      ..classes.add("PlayerChatBubble");
    textElement = new SpanElement()
      ..style.display = "inline-block"
      ..text = text;
    bubble.append(textElement);
  }
}
