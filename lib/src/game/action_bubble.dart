part of couclient;

class ActionBubble {
	int duration;

	SpanElement outline = new SpanElement();
	SpanElement fill = new SpanElement();

	ActionBubble(String actionName, this.duration) {
		// Only the first word, ignore anything after the first space
		String text = actionName.split(" ")[0];

		outline
			..text = text
			..className = "border" + " " + actionName.toLowerCase().replaceAll(' ', '_')
			..style.zIndex = '99';
		fill
			..text = text
			..className = "fill" + " " + actionName.toLowerCase().replaceAll(' ', '_')
			..style.transition = "width ${duration / 1000}s linear"
			..style.zIndex = '99'
			..style.whiteSpace = 'nowrap';

		CurrentPlayer.superParentElement
			..append(outline)
			..append(fill);

		// Position the action bubble
		Rectangle outlineRect = outline.client;
		int outlineWidth = outlineRect.width;
		int outlineHeight = outlineRect.height;
		//print('width: $outlineWidth');
		num playerX = num.parse(CurrentPlayer.playerParentElement.attributes['translatex']);
		num playerY = num.parse(CurrentPlayer.playerParentElement.attributes['translatey']);
		int x = playerX~/1 -outlineWidth~/2 + CurrentPlayer.width ~/ 2;
		int y = playerY~/1 -outlineHeight - 25;

		fill
			..style.top = '${y}px'
			..style.left = '${x}px';
		outline
			..style.top = '${y}px'
			..style.left = '${x}px';

		//start the "fill animation"
		fill.style.width = '${outlineWidth}px';
	}

	Future<bool> get wait {
		Completer completer = new Completer();
		StreamSubscription escListener;
		Timer miningTimer = new Timer(new Duration(milliseconds:duration + 300), () {
			outline.remove();
			fill.remove();
			escListener.cancel();
			completer.complete(true);
		});

		escListener = document.onKeyUp.listen((KeyboardEvent k) {
			if (k.keyCode == 27) {
				outline.remove();
				fill.remove();
				escListener.cancel();
				miningTimer.cancel();
				completer.complete(false);
			}
		});
		return completer.future;
	}
}
