part of coUclient;

class ChatBubble
{
	String text;
	num timeToLive;
	DivElement bubble;
	SpanElement textElement;
	
	ChatBubble(this.text)
	{
		timeToLive = text.length * 0.1 + 3;
		bubble = new DivElement()
			..classes.add("PlayerChatBubble");
		textElement = new SpanElement()
			..style.display = "inline-block"
			..text = text;
		bubble.append(textElement);
	}

}
