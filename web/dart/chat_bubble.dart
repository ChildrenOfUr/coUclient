part of coUclient;

class ChatBubble
{
	String text;
	num timeToLive;
	DivElement bubble;
	SpanElement textElement;

	ChatBubble(this.text)
	{
		timeToLive = text.length * 0.03 + 3; //minimum 3s plus 0.1s per character
		if(timeToLive > 10) //max 10s
		{
			timeToLive = 10; //messages over 10s will only display for 10s
		}
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
