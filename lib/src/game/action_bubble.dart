part of couclient;

class ActionBubble {
	int duration;

	SpanElement outline = new SpanElement();
	SpanElement fill = new SpanElement();

	ActionBubble(String actionName, this.duration) {
		// Position the action bubble
		num posX = CurrentPlayer.posX;
		num posY = CurrentPlayer.posY;
		int width = CurrentPlayer.width;

		String text = actionName;
		int x = posX.toInt() - width ~/ 2;
		int y = posY.toInt() - 60;

		outline
			..text = text
			..className = "border" + " " + actionName.toLowerCase().replaceAll(' ', '_')
			..style.top = '$y' 'px'
			..style.left = '$x' 'px'
			..style.zIndex = '99';
		fill
			..text = text
			..className = "fill" + " " + actionName.toLowerCase().replaceAll(' ', '_')
			..style.transition = "width ${duration / 1000}s linear"
			..style.top = '$y' 'px'
			..style.left = '$x' 'px'
			..style.zIndex = '99'
		..style.whiteSpace = 'nowrap';

		view.playerHolder
			..append(outline)
			..append(fill);

		//start the "fill animation"
		fill.style.width = outline.clientWidth.toString() + "px";
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
			if(k.keyCode == 27) {
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