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
		if(timeToLive > 15) //max 15s
		{
			timeToLive = 15; //messages over 15s will only display for 15s
		}
		timeToLive = 5000;
		bubble = new DivElement()
			..classes.add("PlayerChatBubble")
			..classes.add("ChatBubbleMax");
		textElement = new SpanElement()
			..classes.add("ChatBubbleMax") //prevent overflow
			..style.overflow = "hidden" //prevent overflow
			..style.display = "inline-block"
			..innerHtml = text; //uses default html tag sanitizer (allows img tags, does not allow links)
		
		bubble.append(textElement);
	}
}
