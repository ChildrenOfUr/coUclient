part of couclient;

class ChatBubble {
	String text, bubbleClass;
	num timeToLive;
	DivElement bubble, parent, textElement, arrowElement;
	var hostObject;
	bool autoDismiss, removeParent;

	ChatBubble(this.text, this.hostObject, this.parent,
		{this.autoDismiss: true, this.removeParent: false, bool addUsername: false, Map gains: null, String buttons}) {
		if (autoDismiss) {
			timeToLive = (text.length * 0.05) + 3; //minimum 3s plus 0.05 per character

			if (timeToLive > 10) { //max 10s
				timeToLive = 10; //messages over 10s will only display for 10s
			}
		} else {
			timeToLive = 0;
		}

		bubble = new DivElement()
			..classes.add("chat-bubble");
		textElement = new DivElement()
			..classes.add("cb-content");

// Template for interactions:
//
// {{text}}
// <div class="awarded">
// 	<span class="energy">-0</span>
//	<span class="mood">+0</span>
//	<span class="img">+0</span>
//	<span class="currants">+0</span>
// </div>

		textElement.setInnerHtml(text, validator: Chat.VALIDATOR);

		if (buttons != null) {
			textElement.appendHtml('<br>', validator: Chat.VALIDATOR);

			buttons.split('|').forEach((String button) {
				String btnId = button.split(',')[0];
				String btnText = button.split(',')[1];

				ButtonElement btn = new ButtonElement()
					..text = btnText
					..onClick.first.then((_) {
						// Send id to server
						logmessage('Sending chat bubble action: $btnId');
						streetSocket.send(JSON.encode({'bubbleButton': btnId}));
					});
				textElement.append(btn);
			});
		}

		arrowElement = new DivElement()
			..classes.add("cb-arrow");

		if (gains != null) {
			DivElement awarded = new DivElement()
				..className = 'awarded';
			gains.forEach((String metabolic, int value) {
				if (value != 0) {
					SpanElement span = new SpanElement()
						..className = metabolic;
					String textValue = value > 0 ? '+' + value.toString() : value.toString();
					span.text = textValue;
					awarded.append(span);
				}
			});
			textElement.append(awarded);
		}

		bubble.append(textElement);
		bubble.append(arrowElement);

		//force a player update to be sent right now
		timeLast = 5.0;
	}

	update(double dt) {
		if(timeToLive <= 0 && autoDismiss) {
			removeBubble();
			//force a player update to be sent right now
			timeLast = 5.0;
		} else {
			timeToLive -= dt;
			parent.append(bubble);
		}
	}

	void removeBubble() {
		bubble.remove();
		hostObject.chatBubble = null;

		if (removeParent) {
			parent.remove();
		}
	}
}