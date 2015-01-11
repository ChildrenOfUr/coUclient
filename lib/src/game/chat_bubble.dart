part of couclient;

class ChatBubble
{
	String text, bubbleClass;
	num timeToLive;
	DivElement bubble, parent, textElement, arrowElement;
	var hostObject;
	bool autoDismiss,removeParent;

	ChatBubble(this.text,this.hostObject,this.parent,{this.autoDismiss : true, this.removeParent : false, bool addUsername : false})
	{
		timeToLive = (text.length * 0.05) + 3; //minimum 3s plus 0.05 per character
		if(timeToLive > 10) //max 10s
			timeToLive = 10; //messages over 10s will only display for 10s

		NodeValidator validator = new NodeValidatorBuilder()
			..allowHtml5()
			..allowElement('span', attributes: ['style']);

		bubble = new DivElement()
			..classes.add("chat-bubble");
		textElement = new DivElement()
			..classes.add("cb-content");
		if(addUsername)
			textElement.setInnerHtml("${_getColoredUsername()}: $text", validator: validator);
		else
			textElement.innerHtml = text;
		arrowElement = new DivElement()
			..classes.add("cb-arrow");

		bubble.append(textElement);
		bubble.append(arrowElement);

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

	String _getColoredUsername()
	{
		return "<span style='color:${getUsernameColor(game.username)};paddingRight:4px;display:inline-block;'>${game.username}</span>";
	}
}