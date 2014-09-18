part of couclient;

class ChatBubble
{
	String text;
	num timeToLive;
	DivElement bubble, parent;
	SpanElement textElement;
	var hostObject;
	bool autoDismiss,removeParent;

	ChatBubble(this.text,this.hostObject,this.parent,{this.autoDismiss : true, this.removeParent : false})
	{
		timeToLive = text.length * 0.03 + 3; //minimum 3s plus 0.3s per character
		if(timeToLive > 10) //max 10s
			timeToLive = 10; //messages over 10s will only display for 10s

		bubble = new DivElement()
			..classes.add("PlayerChatBubble")
			..classes.add("ChatBubbleMax");
		textElement = new SpanElement()
			..classes.add("ChatBubbleMax") //prevent overflow
			..style.overflow = "hidden" //prevent overflow
			..style.display = "inline-block"
			..innerHtml = text; //uses default html tag sanitizer (allows img tags, does not allow links)

		bubble.append(textElement);

		//force a player update to be sent right now
		timeLast = 5.0;
	}

	update(double dt)
	{
		if(timeToLive <= 0 && autoDismiss)
		{
			removeBubble();
			//force a player update to be sent right now
			timeLast = 5.0;
		}
		else
		{
			timeToLive -= dt;
			parent.append(bubble);
		}
	}

	void removeBubble()
	{
		bubble.remove();
        hostObject.chatBubble = null;
        if(removeParent)
        	parent.remove();
	}
}