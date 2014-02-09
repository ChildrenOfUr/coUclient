part of coUclient;

class ChatBubble
{
	String text;
	num timeToLive;
	DivElement bubble;
	SpanElement textElement;
	
	ChatBubble(this.text)
	{
		timeToLive = 5; //5 seconds
		bubble = new DivElement()
			..classes.add("PlayerChatBubble");
		textElement = new SpanElement()
			..style.display = "inline-block"
			..text = text;
		bubble.append(textElement);
	}
}